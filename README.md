# Central America External Debt Analysis

## Overview
This project analyzes external debt trends across Central American countries using data from the World Bank API. The analysis covers 2000–2023 and examines debt composition, growth rates, and cross-country comparisons using SQL on a SQLite database.

## Key Findings

1. **Guatemala** is the most indebted Central American country in 2023, with a total external debt of $25.6B USD.
2. Guatemala has led regional debt for the last 18 years, preceded by El Salvador (2003–2005) and Nicaragua (2000–2002).
3. Honduras showed consistent debt growth from 2000–2023, with one notable exception: a ~24% annual drop between 2005–2007 due to qualifying for the HIPC debt relief initiative.
4. Honduras 2023 debt composition: Long-term debt 79.9%, Short-term 11.6%, IMF credit 8.5%. Within long-term debt, 85.2% is public guaranteed and 14.8% private.
5. Honduras had the fastest growing debt in the region between 2013–2023 at 88%, outpacing El Salvador (61%) by 26.6 percentage points.
6. Guatemala and Honduras show opposite debt structures. Guatemala's debt is primarily private, making it vulnerable to private market shifts. Honduras is heavily public, making it sensitive to political and policy changes.

## Technical Decisions
The World Bank API was used instead of a static CSV so the dataset can be refreshed by running a single script, making the pipeline reproducible and schedulable. SQLite was chosen over a full database server because it requires zero configuration and runs locally without dependencies. For a dataset of this size (1,008 rows) it provides all the querying power needed.

## How to Reproduce
1. Clone the repo
2. Install requirements: `pip install -r requirements.txt`
3. Run `scripts/fetch_data.py`
4. Run `scripts/load_to_db.py`
5. Open `database_central_america_debt/debt.db` in DB Browser for SQLite
6. Open `sql/analysis.sql` in DB Browser for SQLite

## Data Source
World Bank International Debt Statistics API  
https://datahelpdesk.worldbank.org/knowledgebase/articles/889392

**Indicators used:** DT.DOD.DECT.CD, DT.DOD.DLXF.CD, DT.DOD.DSTC.CD, DT.DOD.DPPG.CD, DT.DOD.DPNG.CD, DT.DOD.DIMF.CD

## Limitations
Costa Rica and Panama were excluded because the World Bank API returns null values for all indicators for these countries. They remain in the pipeline in case this changes.

## Visualization
Interactive dashboard available [here](https://datastudio.google.com/reporting/227b91ac-d530-443a-a476-150c8ed75e82).
