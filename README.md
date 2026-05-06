# Central America External Debt Analysis

## Overview
This project analyzes external debt trends across Central American countries using data from the World Bank API. The analysis covers 2000–2023 and examines debt composition, growth rates, and cross-country comparisons using SQL on a SQLite database.

## Key Findings
With the following questions that are proved in the sql file i have concluded six findings.

1. The most indebted CA country in 2023 is Guatemala with a total external debt of 25662103251.
2. From the last 18 years the most indebted country in CA is Guatemala, then from 2005 to 2003 El salvador then Nicaragua for 2002 to 2000
3. The Honduras debt evolution from 2000 to 2023 was a consistent growth except 2005-2007, where debt dropped ~24% annually due to Honduras qualifying for HIPC debt relief initiative.
4. The Honduras debt composition on 2023 is made by Total external debt that decompouse to Long term debt, Short term debt and IMF credit, then long term debt is made by private and public debt. With that we have Long-term debt: 79.9%, Short-term: 11.6%, IMF credit: 8.5%. Within long-term debt, 85.2% is public guaranteed and 14.8% private.
5. By a diference of 26.6% and a total of 88% growing rate Honduras is the country that has the fastest growing rate (between 2013 and 2023), and El salvador is on second place with 61%
6. Guatemala is doing the inverse of Honduras as they have more Private debt thant public, this means that they are weaker to a change in private market, instead Honduras is weak on any politics change as they are centered in the public.


## Technical Decisions
I used the World Bank API instead of a static CSV ensures the dataset can be refreshed by running a single script. This makes the pipeline reproducible and maintainable so a team could schedule it to update automatically if desired.
SQLite was chosen over a full database server because it requires zero configuration and runs locally without dependencies. For a dataset of this size (1,008 rows), it provides all the querying power needed without added complexity.


## How to Reproduce
1. Clone the repo
2. Install requirements: pip install -r requirements.txt
3. Run scripts/fetch_data.py
4. Run scripts/load_to_db.py
5. Open database_central_america_debt/debt.db in DB Browser for SQLite. This file is created once you run load_to_db.py
6. Open sql/analysis.sql in DB Browser for SQLite

## Data Source
World Bank International Debt Statistics API
https://datahelpdesk.worldbank.org/knowledgebase/articles/889392
Indicators: DT.DOD.DECT.CD, DT.DOD.DLXF.CD, DT.DOD.DSTC.CD, DT.DOD.DPPG.CD, DT.DOD.DPNG.CD, DT.DOD.DIMF.CD

## Limitations
Costa Rica and Panama were excluded from the analysis in all areas because the world bank API only returns nulls in all indicators. They remain in the pipeline in case this changes.



## Visualization
The graphics and all the visualization can be found here
https://datastudio.google.com/reporting/227b91ac-d530-443a-a476-150c8ed75e82


