# Projects

## [mmatczuk/scylla-go-driver](https://github.com/mmatczuk/scylla-go-driver) ![shield](https://img.shields.io/github/stars/mmatczuk/scylla-go-driver) ![shield](https://img.shields.io/github/forks/mmatczuk/scylla-go-driver) ![shield](https://img.shields.io/github/contributors/mmatczuk/scylla-go-driver)

Experimental, high performance, ScyllaDB driver.
I'm leading a group of four [University of Warsaw (mimuw)](https://www.mimuw.edu.pl/en) students.
The work is their BS thesis.
The goal is to implement a lock-free driver with smart memory usage (GC sympathy).
Initial results [look very promising](https://twitter.com/michalmatczuk/status/1515095584306311168). 

## [mmatczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel/) ![shield](https://img.shields.io/github/stars/mmatczuk/go-http-tunnel) ![shield](https://img.shields.io/github/forks/mmatczuk/go-http-tunnel) ![shield](https://img.shields.io/github/contributors/mmatczuk/go-http-tunnel) 

Ngrok clone implemented with HTTP/2 streams.

{{< tweet user="kelseyhightower" id="950375855569514497" >}}

## [scylladb/scylla-manager](https://github.com/scylladb/scylla-manager) ![shield](https://img.shields.io/github/stars/scylladb/scylla-manager) ![shield](https://img.shields.io/github/forks/scylladb/scylla-manager) ![shield](https://img.shields.io/github/contributors/scylladb/scylla-manager)

The ScyllaDB cluster backup and repair solution used in virtually every ScyllaDB cluster!
See [the product website](https://www.scylladb.com/product/scylla-manager/) and [the docs](http://manager.docs.scylladb.com/).
It saves thousands of $ by deduplicating the sstable files.
It uses a novel method of parallel repairs, described in [this post]({{< relref "/posts/sm22" >}}).
As part of this project, my team and I, sent many patches to [rclone](https://rclone.org/):
* Adding context.Context to the whole project
* Adding fadvise to manage Linux page cache while coping TiB of files 
* Multiple bugfixes to s3 backend implementation

## [scylladb/gocqlx](https://github.com/scylladb/gocqlx) ![shield](https://img.shields.io/github/stars/scylladb/gocqlx) ![shield](https://img.shields.io/github/forks/scylladb/gocqlx) ![shield](https://img.shields.io/github/contributors/scylladb/gocqlx)

CQL query builder, reflection based ORM, and migration tool.
I started this project when I joined ScyllaDB in 2017.
It is used internally by Scylla Manager, externally by many ScyllaDB users, and over 60 projects on GitHub.
There are over 600 daily clones and 100-200 page views on GitHub.

## [scylladb/go-set](https://github.com/scylladb/go-set) ![shield](https://img.shields.io/github/stars/scylladb/go-set) ![shield](https://img.shields.io/github/forks/scylladb/go-set) ![shield](https://img.shields.io/github/contributors/scylladb/go-set) 

Pre Go generics type-safe, zero-allocation port of fatih/set package.
This project uses [mmatczuk/go_generics](https://github.com/mmatczuk/go_generics) a bazel-free version of [Google go_generics](https://github.com/google/gvisor/tree/master/tools/go_generics) tool released with gVisor project. 
