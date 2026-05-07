-- =============================================
-- BLOCK 1:
-- QUESTION: What is the most indebted CA country in 2023 (absolute)?
-- ANSWER: The most indebted CA country in 2023 is Guatemala with a total external debt of 25662103251.6
-- NOTE: I used limit and order by instead of max because i wanted this sql to be able to reproduce not only in SQLite
-- Skills: filtering, ordering, LIMIT
-- =============================================



	SELECT country_value, country_id, value AS debt 
	FROM CENTRAL_AMERICA_DEBT 
	WHERE date = 2023 
	AND type_of_indicator = 'total_external_debt' 
	AND value IS NOT NULL 
	ORDER BY value DESC
	LIMIT 1;


-- =============================================
-- BLOCK 2: 
-- QUESTION: What is the most indebted CA country per year?
-- ANSWER: From the last 18 years it is Guatemala, then from 2005 to 2003 El salvador then Nicaragua for 2002 to 2000
-- NOTE: Use of ranking to separate and make a tier list of the years then I take the first on every year, in this way i can have more than the first 
---		 country by just a few modification
-- Skills: window functions, RANK(), PARTITION BY
-- =============================================

	SELECT country_value, value, date
	FROM (
		SELECT country_value, value, date,
			   RANK() OVER (PARTITION BY date ORDER BY value DESC) AS ranking
		FROM CENTRAL_AMERICA_DEBT
		WHERE type_of_indicator = 'total_external_debt' 
		AND value IS NOT NULL
	) 
	WHERE ranking = 1 
	ORDER BY date DESC;


-- =============================================
-- BLOCK 3: 
-- QUESTION: What is the Honduras debt evolution from 2000 to 2023?
-- ANSWER: There was a consistent growth except 2005-2007, where debt dropped ~24% annually 
--         due to Honduras qualifying for HIPC debt relief initiative.
-- NOTE: Used two cte in order to have a clear code and for future maintainence
-- Skill: time series, year-over-year change
-- =============================================


	WITH HnTotalDebt as (
	select country_value, value, date from CENTRAL_AMERICA_DEBT where country_id='HN' and type_of_indicator ='total_external_debt'
	)
	,
	diference_window as(
	select country_value,value,date, coalesce(value-lag(value) over (order by date ASC) ,0) as diference from HnTotalDebt
	)

	SELECT country_value, value, date, diference ,coalesce(diference/(value - diference)*100,0)as porcentage_of_change from diference_window order by date desc;



-- =============================================
-- BLOCK 4: 
-- QUESTION: What is the Honduras debt composition on 2023?
-- ANSWER: The composition is made by Total external debt that decompouse to Long term debt, Short term debt and IMF credit, then long
--		   term debt is made by private and public debt. With that we have long_term_debt = 79.9258789957895, short_term_debt = 11.5541623692459
--		   imf_credit = 8.5199586349646 and private_nonguaranteed_debt= 14.7763294601445, public_guaranteed_debt= 85.2236705398555
-- NOTE: Used a cte in order to extract the variables in this way i can used in other query that is showed latter
-- Skill: aggregation por categoría, proportions
-- =============================================


	with ReferenceVariables as(
			select max(case when type_of_indicator = 'total_external_debt'
									then value END) as total_debt,
				   max(case when type_of_indicator ='long_term_debt'
									then value end) as long_term_debt
			FROM CENTRAL_AMERICA_DEBT
			where country_id='HN' and date='2023' 
		)
		

	,Porcentage as (
		select c.country_value,c.country_id,c.value,c.type_of_indicator, case
																	WHEN c.type_of_indicator in ('imf_credit','long_term_debt','short_term_debt')
																		then coalesce(c.value/t.total_debt,0)*100
																	WHEN c.type_of_indicator = 'private_nonguaranteed_debt' or c.type_of_indicator = 'public_guaranteed_debt'
																			then coalesce(c.value/t.long_term_debt,0)*100
																	else 1 end
																	as porcentage,
			date from CENTRAL_AMERICA_DEBT c CROSS JOIN ReferenceVariables t where country_id='HN' and date='2023'
	)


	select country_value,value,type_of_indicator, porcentage ,date from Porcentage
		where country_id='HN' and date='2023' and type_of_indicator != 'total_external_debt' Order by value


-- ============================================= 
-- BLOCK 5: Fastest growing debt (last 10 years)
-- QUESTION: What is the Fastest growing debt in CA countries (last 10 years)?
-- ANSWER: By a diference of 26.6 the country that have the fastest growing debt in the last 10 years is Honduras
-- NOTE: used nullif to make sure that the query will not crash if divided
-- Skill: CTEs, window functions, ranking
-- =============================================



	with BaseYear as(
			select country_value,value,date as base_date from CENTRAL_AMERICA_DEBT where type_of_indicator='total_external_debt' and date='2013'
		),
		FinalYear as(
			select country_value,value,date as final_date from CENTRAL_AMERICA_DEBT where type_of_indicator='total_external_debt' and date='2023'
		),
		GrowingRate as(
			select b.country_value as c_value,coalesce(((f.value -b.value)/nullif(b.value,0)),0)*100 as growing_rate
			from BaseYear b INNER JOIN FinalYear f on b.country_value=f.country_value
		)
	
	
	select c_value,dense_rank() over (order by growing_rate DESC) as ranking, growing_rate from GrowingRate;
	
	
	
-- =============================================
-- BONUS 6:
-- QUESTION: Comparing Guatemala and Honduras what is the diference in the composition of the debt?
-- ANSWER: Guatemala is doing the inverse of Honduras as they have more Private debt thant public, this means that they are weaker to a change in 
-- 		   private market, instead Honduras is weak on any politics change as they are centered in the public.
-- NOTE: By the use of and old query i recycle it and get interesting results. 
-- =============================================

	with ReferenceVariables as(
			select country_id, max(case when type_of_indicator = 'total_external_debt'
									then value END) as total_debt,
				   max(case when type_of_indicator ='long_term_debt'
									then value end) as long_term_debt	
			FROM CENTRAL_AMERICA_DEBT
			where (country_id='HN' or country_id='GT') and date='2023' GROUP by country_id 
		)
		

	,Porcentage as (
		select c.country_value,c.country_id,c.value,c.type_of_indicator, case
																	WHEN c.type_of_indicator in ('imf_credit','long_term_debt','short_term_debt')
																		then coalesce(c.value/t.total_debt,0)*100
																	WHEN c.type_of_indicator = 'private_nonguaranteed_debt' or c.type_of_indicator = 'public_guaranteed_debt'
																			then coalesce(c.value/t.long_term_debt,0)*100
																	else 1 end
																	as porcentage,
			date from CENTRAL_AMERICA_DEBT c INNER JOIN ReferenceVariables t on c.country_id = t.country_id where (t.country_id='HN' or t.country_id='GT') and date='2023'
	)


	select country_value,value,type_of_indicator, porcentage,rank() over (PARTITION by type_of_indicator order by porcentage) as ranking ,date from Porcentage
		where (country_id='HN' or country_id='GT') and date='2023' and type_of_indicator != 'total_external_debt'
