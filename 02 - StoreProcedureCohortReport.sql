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

	drop table if exists tmp_baseCohort1;
	create table tmp_baseCohort1 as
	select unique_id client
		,to_char(signup_at,'YYYYMM') suscription_mnth 
		,to_char(t.trx_at,'YYYYMM') mnth_trx
		,to_char(t.trx_at,'YYYYMM')::integer - to_char(signup_at,'YYYYMM')::integer + 1  mnth --> extract month number, I'm going to use this value for create a dynamic script
	from tbl_user tu 
		left join tbl_transaction t using(unique_id)
	where t.trx_at >= tu.signup_at 
		order by 2,1;
	
	select count(1) into liCount
	from tmp_baseCohort1;
	
	RAISE NOTICE 'OK: tmp_baseCohort1 Created. Rows ->> %', liCount;

	select count(distinct(mnth)) into liCount  --> getting the quantity of months
	from tmp_baseCohort1;

	lsSql2 := 'create table tbl_cohort_report as '|| chr(10) || 
			   'with head as(
					select b.suscription_mnth 
						,count(distinct(client)) quantity
					from tmp_baseCohort1 b
						group by b.suscription_mnth
				),
				body as (	
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

	-- Starting with the dynamic query to complete the all sentence .
	
	for lrRec in execute lsSql loop

			if liIter != liCount then
			
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

		if liIter != liCount then
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
	execute lsSql2;
	
						
end; $$


