#!/bin/sh
dropdb -U postgres --if-exists lending_club
createdb -U postgres lending_club
echo "\nCreating data types and tables..."
psql -U postgres -h localhost -d lending_club -f lc_create_tables.sql
echo "\nCreating functions..."
psql -U postgres -h localhost -d lending_club -f lc_create_functions.sql
echo "\nLoanding Lending Club data for 2012-present..."
python lc_fix_csv.py LoanStats3[b-z]*_securev1.csv | pgloader --load-from-stdin --load-to-table=loans -f,