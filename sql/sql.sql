SELECT date,country_value, max(value),type_of_indicator FROM CENTRAL_AMERICA_DEBT  where indicator="DT.DOD.DIMF.CD" GROUP by date ORDER by value DESC;


SELECT * FROM CENTRAL_AMERICA_DEBT where value="NULL";

-- =============================================
-- BLOCK 1: Most indebted CA country (absolute)
-- Skill demostrado: GROUP BY, ORDER, filtering
-- =============================================
select * from CENTRAL_AMERICA_DEBT where value is null;
Select country_value, value as debt from CENTRAL_AMERICA_DEBT where date=2023 and type_of_indicator ='total_external_debt' and value is not null order by value desc limit 1;
SELECT country_value,max(value),date from CENTRAL_AMERICA_DEBT where type_of_indicator = "total_external_debt" GROUP by date ORDER by date DESC;

Select country_value, value from CENTRAL_AMERICA_DEBT where type_of_indicator ='total_external_debt' and value is not null GROUP by date order by value desc;

select country_value,value, date from
 (select country_value,value, rank() over (PARTITION BY date  ORDER BY value DESC) as ranking, date
	from CENTRAL_AMERICA_DEBT 
		WHERE
			type_of_indicator='total_external_debt' and value is not null) where ranking =1 order by date desc;
			
			
			
-- =============================================
-- BLOCK 3: Honduras debt evolution 2000-2023
-- Skill demostrado: time series, year-over-year change
-- Pista: esto es donde los window functions entran
-- =============================================
-- Específicamente vas a necesitar: LAG(), diferencia absoluta, % cambio



-- =============================================
-- BLOCK 4: Honduras debt composition
-- Skill demostrado: aggregation por categoría, proportions
-- Pista: CASE WHEN o GROUP BY indicator_name dependiendo de cómo modelaste
-- =============================================



-- =============================================
-- BLOCK 5: Fastest growing debt (last 10 years)
-- Skill demostrado: CTEs, window functions, ranking
-- Pista: RANK() o DENSE_RANK() sobre un cálculo de crecimiento
-- =============================================
-- Estructura sugerida:
-- CTE 1: valor en año base (2013)
-- CTE 2: valor en año final (2023)
-- CTE 3: calcular growth rate, rankear



-- =============================================
-- BONUS BLOCK: El hallazgo no obvio
-- No te lo digo — lo vas a descubrir cuando veas los datos
-- Pista: compara la composición de deuda de Honduras vs Guatemala
-- =============================================