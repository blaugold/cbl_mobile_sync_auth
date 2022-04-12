## Get Couchbase Server and Sync Gateway up and running

1. Run `docker-compose up -d couchbase-server`.
2. Open `http://localhost:8091` in your browser.
3. Follow the instruction to setup up a new Couchbase Server cluster.
4. Under `Buckets` create a bucket called `sg`.
5. Under `Security` create a user called `sg` with password `password` and
   `Application Access` to the `sg` bucket.
6. Under `Security` create a user called `sg-admin` with password `password` and
   `Full Admin` access.
7. Run `docker-compose up -d sync-gateway`.
8. Run `./sg-config.sh create-db` to create a database in the Sync Gateway.
