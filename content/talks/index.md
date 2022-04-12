---
title: Talks
---

## [Reflection (slides)](https://go-talks.appspot.com/github.com/mmatczuk/talks/reflection/reflection.slide)

Tour of reflection, the good, the expensive, and the insecure.
This talk is based on my experience while working on [scylladb/gocqlx](https://github.com/scylladb/gocqlx), an ORM for Scylla (and Cassandra).
I also show 80-90% performance gain using "generics" (2019) in [scylladb/go-set](https://github.com/scylladb/go-set).

## [Adventures with SSH (slides)](https://go-talks.appspot.com/github.com/mmatczuk/talks/ssh/present.slide)

I present how to use SSH daemon as HTTP reverse proxy, and SSH as HTTP transport.
This setup was used in Scylla Manager 1.x and was removed in Scylla Manger 2.x as we needed to run code in Scylla nodes.
After that we open-sourced [scylladb/go-sshtools](https://github.com/scylladb/go-sshtools), a wrapper around SSH client.

## [HTTP Tunnels to localhost (YouTube)](https://www.youtube.com/watch?v=v7cBx1tY3lk)

I present [mmatczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel), HTTP/2 based ngrok clone.
The ideas here are based on my prior work on [koding/tunnel](https://github.com/koding/tunnel).
Now the project is little abandoned.
