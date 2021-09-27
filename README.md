# CohortReport_StoreProcedure
There is an example of the use of PL/PGSQL to generate a cohort report using dynamic querys in postgresSQL.

/************** Important *************/
In this file you have the instructions to run the Cohorts Analysis.

I use POSTGRESQL -> PostgreSQL 13.4, compiled by Visual C++ build 1914, 64-bit, 
available in the next link: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

/***************************************/


/*****************************************/

Steeps:

1 - Install PostgreSQL 13.4, compiled by Visual C++ build 1914, 64-bit

2 - Open and run "01 - CreationArtefacts.sql" file, to create the database "dbCohort", tables and extensions.

3 - Import data into tables:  tbl_user and tbl_transaction using files : "users.csv" and "trx.csv"

3 - Open and run "02 - StoreProcedureCohortReport.sql" file, to generate the report table cohort analysis -> "SignUp Month Cohort"


/*****************************************/

Thanks


