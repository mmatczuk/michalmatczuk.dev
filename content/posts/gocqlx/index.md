---
date: 2017-08-25
slug: gocqlx
tags:
  - scylla
  - gocqlx
title: "Gocqlx: A Productivity Toolkit for Scylla in Go"
---

*This blog post has been first published in [ScyllaDB blog](https://www.scylladb.com).*

[Gocqlx](https://github.com/scylladb/gocqlx) is an extension to the Go Scylla / Apache Cassandra driver Gocql.
It aims to boost developer productivity while not sacrificing query performance.
It’s inspired by [jmoiron/sqlx](https://github.com/jmoiron/sqlx), a tool for working with SQL databases, but it goes beyond what sqlx provides.


For this blog post, we will pretend we’re a microblogging service and use the following schema:

```cql
CREATE TABLE tweet (
    timeline text,
    id uuid,
    text text,
    in_reply_to_screen_name text,
    in_reply_to_user_id bigint,
    PRIMARY KEY (timeline, id)
);
```

Gocql is a very popular Cassandra driver for the Go programming language.
Usually working with it looks more or less like this:

```go
package main

import (
   "log"

   "github.com/gocql/gocql"
)

func connect() *gocql.Session {
   // connect to the cluster
   cluster := gocql.NewCluster("192.168.1.1", "192.168.1.2", "192.168.1.3")
   cluster.Keyspace = "example"
   cluster.Consistency = gocql.Quorum
   session, _ := cluster.CreateSession()

   return session
}

func main() {
   session := connect()
   defer session.Close()

   var id gocql.UUID
   var text string
  
   // list all tweets
   iter := session.Query(`SELECT id, text FROM tweet WHERE timeline = ?`, "me").Iter()
   for iter.Scan(&id, &text) {
       log.Println("Tweet:", id, text)
   }
   if err := iter.Close(); err != nil {
       log.Fatal(err)
   }
}
```

At first sight is looks OK, but there are some problems:

* Gocql does not provide you with named query parameters.
  This means that you will have to watch the parameters order while binding.
  This is not very flexible and can easily lead to errors detected only in runtime.
* Scanning a row into a struct field involves providing proper pointers to the Scan method.

  Like before, order matters, and you have to provide the exact list of columns in the query and keep it in sync with the Scan parameters.
  The lists can quickly become quite long in a production system.
* Loading data into memory involves writing scan loops that look almost the same except that the target type is different.

Gocqlx builds on top of gocql to eliminate those issues and provides:

* Builders for creating queries
* Support for named parameters in queries
* Support for binding parameters from struct fields, maps, or both
* Scanning query results into structs based on field names
* Convenience functions for common tasks like loading a single row into a struct or all rows into a slice (list) of structs

# Building queries

Gocqlx provides query builders for SELECT, INSERT, UPDATE, DELETE and BATCH statements.
The builders create a CQL query and a list of the named parameters used in it.
Let's take a look at the sample code for a builder: 

```go
package main

import (
   "log"

   "github.com/scylladb/gocqlx/qb"
)

func main() {
   stmt, names := qb.Select("tweet").
       Columns("id", "text").
       Where(qb.Eq("timeline")).
       ToCql()

   log.Println(stmt)  // SELECT id,text FROM tweet WHERE timeline=?
   log.Println(names) // [timeline]
}
```

The builders promote the use of named parameters.
The produced CQL does not contain constants or values which allow us to leverage the gocql prepared statement cache.
Gocqlx implements the full spec of SELECT, INSERT, UPDATE, DELETE, BATCH and can build advanced queries, but for the sake of this blog post, we try to keep things simple.

Gocqlx also supports queries with named parameters (':' identifier).
Such queries are automatically rewritten to standard gocql queries and parameter names are extracted.
Building queries, however, should be preferred to compiling as it’s more flexible and faster.

```go
package main

import (
   "log"

   "github.com/scylladb/gocqlx"
)

func main() {
   stmtx := []byte("SELECT id,text FROM tweet WHERE timeline=:timeline")
   stmt, names, _ := gocqlx.CompileNamedQuery(stmtx)

   log.Println(stmt)  // SELECT id,text FROM tweet WHERE timeline=?
   log.Println(names) // [timeline]
}
```

# Binding query parameters

Once we have a CQL query and a list of parameter names, gocqlx can help with binding the query parameters.
Gocqlx can bind parameters from struct fields, maps, or both (bind from struct and fallback to map).
Thanks to that, many operations become much simpler to implement.
For example updates:

```go
package main

import (
   "log"

   "github.com/scylladb/gocqlx"
   "github.com/scylladb/gocqlx/qb"
)

func main() {
   session := connect()
   defer session.Close()

   t := &Tweet{
       Timeline: "me",
       ID: id,
       Text: "tweet",
       InReplyToScreenName: "twitterapi",
       InReplyToUserID: 819797,
   }

   stmt, names := qb.Update("tweet").
       Set("text", "in_reply_to_screen_name", "in_reply_to_user_id").
       Where(qb.Eq("timeline"), qb.Eq("id")).
       ToCql()

   q := gocqlx.Query(session.Query(stmt), names)
   if err := q.BindStruct(t).Exec(); err != nil {
       log.Fatal(err)
   }
}
```

It’s worth to note that gocqlx by default maps camelcase Go struct field names to snake case database columns (i.e.
“InReplyToScreenName” to “in_reply_to_screen_name”) so there is no need for manual tagging.

# Scanning rows

Gocqlx provides two convenience functions: Get and Select.
The former scans the first query results into a struct.
The latter scans all the query results into a slice.
This greatly simplifies reading data into memory.

```go
package main

import (
   "log"

   "github.com/scylladb/gocqlx"
   "github.com/scylladb/gocqlx/qb"
)

func main() {
   session := connect()
   defer session.Close()

   stmt, _ := qb.Select("tweet").Where(qb.Eq("timeline")).ToCql()
   log.Println(stmt)  // SELECT * FROM tweet WHERE timeline=?

   // list all tweets
   var tweets []*Tweet
   if err := gocqlx.Select(&tweets, session.Query(stmt, "me")); err != nil {
       log.Fatal(err)
   }
}
```

If scanning all rows is not desired, one can use struct scanning on a query iterator.

```go
package main

import (
   "log"

   "github.com/scylladb/gocqlx"
   "github.com/scylladb/gocqlx/qb"
)

func main() {
   session := connect()
   defer session.Close()

   stmt, _ := qb.Select("tweet").Where(qb.Eq("timeline")).ToCql()
   log.Println(stmt)  // SELECT * FROM tweet WHERE timeline=?

   // list all tweets
   iter := gocqlx.Iter(session.Query(stmt, "me"))
   defer iter.ReleaseQuery()

   var t Tweet
   for iter.StructScan(&t) {
       log.Println(t)
   }
   if err := iter.Close(); err != nil {
       log.Fatal(err)
   }
}
```

# Performance

Unlike many ORMs, gocqlx is fast.
It uses the excellent [reflectx](https://github.com/jmoiron/sqlx/tree/master/reflectx) package (part of sqlx) for cached reflections.

For iterative rebinding of query parameters, i.e.
insert multiple rows into a table, gocqlx proved to be significantly faster than raw gocql.
That’s because gocqlx, compared to the traditional use of gocql, reuses memory for the values being bound.

Below is a result of a Go benchmark comparing INSERT, Get, and Select with gocqlx to plain gocql.

```shell
BenchmarkE2EGocqlInsert-4    500000   258434 ns/op   2627 B/op   59 allocs/op
BenchmarkE2EGocqlxInsert-4  1000000   120257 ns/op   1555 B/op   34 allocs/op
BenchmarkE2EGocqlGet-4      1000000   131424 ns/op   1970 B/op   55 allocs/op
BenchmarkE2EGocqlxGet-4     1000000   131981 ns/op   2322 B/op   58 allocs/op
BenchmarkE2EGocqlSelect-4     30000  2588562 ns/op  34605 B/op  946 allocs/op
BenchmarkE2EGocqlxSelect-4    30000  2637187 ns/op  27718 B/op  951 allocs/op
```

# Conclusions

Gocqlx gives you much flexibility and significantly simplifies working with a Scylla / Cassandra database.
The code is faster to write and easier to maintain and eliminates repetitive code and replaces it with more idiomatic constructs.
The modular and simple design enables gocqlx to live along with gocql and leverage it where gocql shines.
Gocqlx is fast and optimized.

# Availability

See the project website [https://github.com/scylladb/gocqlx](https://github.com/scylladb/gocqlx).
Gocqlx is licensed under [Apache License 2.0](https://github.com/scylladb/gocqlx/blob/master/LICENSE).
