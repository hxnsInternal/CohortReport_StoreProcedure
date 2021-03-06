-- call sp_generate_cohort_report()

create or replace procedure sp_generate_cohort_report() 
language plpgsql
as $$
declare

	lsSql varchar;
	lsSql2 varchar;
	liCount integer;
	liIter integer := 1;
	lrRec record;
	
begin
	
	discard temp;

	drop table if exists tmp_baseCohort1; -->> Creating a ase table with the information of the login and transaction info.
	create table tmp_baseCohort1 as
	select unique_id client
		,to_char(signup_at,'YYYYMM') suscription_mnth 
		,to_char(t.trx_at,'YYYYMM') mnth_trx
		,to_char(t.trx_at,'YYYYMM')::integer - to_char(signup_at,'YYYYMM')::integer + 1  mnth --> extract month number, I'm going to use this value for create a dynamic script
	from tbl_user tu 
		left join tbl_transaction t using(unique_id)
	where t.trx_at >= tu.signup_at 
		order by 2,1;
	
	select count(1) into liCount		--> Getting the all rows of the table "tmp_baseCohort1"
	from tmp_baseCohort1;
	
	RAISE NOTICE 'OK: tmp_baseCohort1 Created. Rows ->> %', liCount;

	select count(distinct(mnth)) into liCount  --> getting the quantity of months
	from tmp_baseCohort1;

	lsSql2 := 'create table tbl_cohort_report as '|| chr(10) || 
			   'with head as(		-->> getting quantitys of the data
					select b.suscription_mnth 
						,count(distinct(client)) quantity
					from tmp_baseCohort1 b
						group by b.suscription_mnth
				),
				body as (		-->> Using a table pivot funtion to pivot the information.
					select *	
					from crosstab('' 		
					select suscription_mnth 
							,mnth 
							,count(distinct(client)) quantity_mnth
					from tmp_baseCohort1 b
						group by suscription_mnth
							,mnth
						order by 1'',
					''select m from generate_series(1,'|| liCount ||') m''
					) as (suscription_mnth varchar
			  ';
			 
	lsSql := 'select distinct mnth from tmp_baseCohort1 order by 1';

	-- Starting with the dynamic query to complete the all sentences, for generating a DDL definition for the report table
	
	for lrRec in execute lsSql loop

			if liIter != liCount then  --> It's just for not add a space line when is the last iteration
			
				lsSql2 := lsSql2 || ',mnth_'|| liIter ||' int' || chr(10);
			else
			
				lsSql2 := lsSql2 || ',mnth_'|| liIter ||' int';
			end if;
			
			liIter := liIter + 1;	
	end loop;

	liIter := 1;

	lsSql2 := lsSql2 ||
			')
			  ),
				baseCohort as(
				select e.suscription_mnth
					,e.quantity
			  ';
				 
	for lrRec in execute lsSql loop

		if liIter != liCount then	--> It's just for not add a space line when is the last iteration
			lsSql2 := lsSql2 || ',c.mnth_' || liIter || chr(10);
		else
			lsSql2 := lsSql2 || ',c.mnth_' || liIter;
		end if;
			
			liIter := liIter + 1;
	
	end loop;
	liIter := 1;
	
	lsSql2 := lsSql2 || chr(10)
			||'from head e
					join body c using(suscription_mnth) 
				)
				select b.*
				from basecohort b
				union		--> adding the summary
				select ''AVERAGE''
					,sum(quantity)
			';
	
	
	for lrRec in execute lsSql loop

		if liIter != liCount then
			lsSql2 := lsSql2 || ',sum(mnth_'|| liIter ||')' || chr(10);
		else
			lsSql2 := lsSql2 || ',sum(mnth_'|| liIter ||')';
		end if;
			
			liIter := liIter + 1;
	
	end loop;
	liIter := 1;

	lsSql2 := lsSql2 || '
				from basecohort
					order by 1';

	RAISE NOTICE 'Query: ->>> %', lsSql2;  --> Display the SQL Query for the CTAS report.	

	drop table if exists tbl_cohort_report;		
	execute lsSql2;		-->> Creating the new report table with the information of the report.
	
						
end; $$


/********************/
/*	-- ->> There's the dinamyc query generated by the store procedure.
	
	create table tbl_cohort_report as
	with head as(
					select b.suscription_mnth 
						,count(distinct(client)) quantity
					from tmp_baseCohort1 b
						group by b.suscription_mnth
				),
				body as (	
					select *
					from crosstab(' 		
					select suscription_mnth 
							,mnth 
							,count(distinct(client)) quantity_mnth
					from tmp_baseCohort1 b
						group by suscription_mnth
							,mnth
						order by 1',
					'select m from generate_series(1,8) m'
					) as (suscription_mnth varchar
			  ,mnth_1 int
			  ,mnth_2 int
			  ,mnth_3 int
			  ,mnth_4 int
			  ,mnth_5 int
			  ,mnth_6 int
			  ,mnth_7 int
			  ,mnth_8 int)
			  ),
				baseCohort as(
				select e.suscription_mnth
					,e.quantity
			  		,c.mnth_1
					,c.mnth_2
					,c.mnth_3
					,c.mnth_4
					,c.mnth_5
					,c.mnth_6
					,c.mnth_7
					,c.mnth_8
				from head e
					join body c using(suscription_mnth) 
				)
	select b.*
	from basecohort b
	union		--> adding the summary
	select 'AVERAGE'
		,sum(quantity)
		,sum(mnth_1)
		,sum(mnth_2)
		,sum(mnth_3)
		,sum(mnth_4)
		,sum(mnth_5)
		,sum(mnth_6)
		,sum(mnth_7)
		,sum(mnth_8)
	from basecohort
		order by 1;
*/

/********************/











