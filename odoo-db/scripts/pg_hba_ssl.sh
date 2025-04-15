#!/bin/bash
# Only SSl connections
sed -i  's/host all all all scram-sha-256/hostssl all all all scram-sha-256/g' /var/lib/postgresql/data/pgdata/pg_hba.conf


