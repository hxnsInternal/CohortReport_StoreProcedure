--Creation Artefacts Script

/*
 Important!!!
 I assumed that we have POSTGRESQL -> (PostgreSQL 13.4, compiled by Visual C++ build 1914, 64-bit)  as database system.
*/

/**************	creating Database "dbCohort"	******************/

CREATE DATABASE "dbCohort"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

/**************	creating Database "dbCohort"	******************/
   

/************ Creating tables ******************/

drop table if exists tbl_user;
create table tbl_user(		 --> here we have data from File -> users.csv
	UNIQUE_ID varchar,	
	SIGNUP_AT timestamp
);

drop table if exists tbl_transaction;
create table tbl_transaction(		--> here we have data from File -> trx.csv				
	UNIQUE_ID varchar,	
	TRX_AT timestamp
);


/************ End creating tables ******************/


/*********** Creating TABLEFUNC Extension on our Database	****************/

CREATE extension tablefunc;

/*********** End creating TABLEFUNC Extension on our Database	****************/