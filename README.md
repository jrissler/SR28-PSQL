# SR28-PSQL
Postgres script for the USDA's National Nutrient Database for Standard Reference, release 28

COPY command in the script will have to be updated with the location of the usda csv files (ending in txt).

# How to use script
psql -h localhost -d userstoreis -U admin -p 5432 -a -q -f /home/jobs/Desktop/resources/postgresql.sql

-h PostgreSQL server IP address
-d database name
-U user name
-p port which PostgreSQL server is listening on
-f path to SQL script

# What I did different
- Renamed table names to fit an elixir model
- Updating import files location relative to my project

# TODO
- Add indexes etc
