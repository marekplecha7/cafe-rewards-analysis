# Cafe Rewards Analysis

SQL and Power BI analysis of the Cafe Rewards dataset, focused on customer behavior, promotional offer performance and transaction patterns.

## Project Overview

The project follows a complete analytical workflow:

1. Data understanding
2. Data quality checks
3. Business validation
4. Data issue identification
5. Data cleaning
6. SQL analysis
7. Power BI data modeling
8. Dashboard development

The analysis was performed in Microsoft SQL Server, while the final interactive dashboard was built in Power BI.

## Dataset

The dataset contains three main tables:

- **Customers** – customer demographics and membership information
- **Offers** – promotional offer characteristics
- **Events** – transactions and offer-related customer events

A data dictionary provided with the dataset was used to understand column definitions, event types and business rules.

## Key Data Preparation Steps

Main transformations included:

- converting incorrectly imported data types
- standardizing date and numeric fields
- parsing semi-structured event values
- standardizing inconsistent offer ID keys
- removing exact duplicate event records
- handling placeholder demographic values
- preparing reusable SQL views for analysis and Power BI

## SQL Analysis

The SQL analysis covered:

- overall offer funnel performance
- offer performance by type
- ranking individual offers
- completed offers with and without prior viewing
- customer spending behavior
- customer segmentation by income
- offer engagement by age group

The project uses CTEs, joins, conditional aggregation, `EXISTS`, window functions, `RANK`, `PERCENTILE_CONT` and JSON parsing.

## Power BI Data Model

The core Power BI model follows a simple star schema:

- **Fact Events**
- **Dim Customers**
- **Dim Offers**

Additional supporting tables were used for DAX measures and offer completion-status analysis.

![Data Model](Images/data_model.png)

## Dashboard

The dashboard contains three pages:

### Overview

High-level view of revenue, customer activity and offer performance.

![Overview Dashboard](Images/dashboard_overview.png)

### Offer Performance

Detailed comparison of individual promotional offers, including view and completion rates.

![Offer Performance Dashboard](Images/dashboard_offer_performance.png)

### Customer Segments

Analysis of spending and offer engagement across income, age and gender segments.

![Customer Segments Dashboard](Images/dashboard_customer_segments.png)

## Key Findings

- 75.68% of received offers were viewed.
- 43.50% of received offers were completed.
- BOGO offers had the highest overall view rate, while discount offers had the highest completion rate.
- 74.18% of completed offers had a prior recorded view.
- Higher-income customer groups showed substantially higher average transaction values.
- Lower-income customers made more transactions on average, but at lower transaction values.
- Older customer groups showed higher offer completion rates during the observed period.


## Tools used

- **Microsoft SQL Server** – data querying, validation, cleaning and analysis
- **SQL Server Management Studio (SSMS)** – database management and SQL development
- **Power BI Desktop** – data modeling, DAX measures and dashboard development
- **DAX** – KPI calculations, customer segmentation and report logic
- **GitHub** – project documentation and version control

## Files

- `01_data_understanding.md` – dataset structure, columns and initial exploration
- `02_data_quality.md` – completeness, uniqueness, duplicates and referential integrity checks
- `03_business_validation.md` – validation of business rules and event logic
- `04_data_issues.md` – identified data quality and consistency issues
- `05_data_cleaning.md` – cleaning decisions and reusable SQL views
- `06_analysis.md` – SQL analysis and key findings
- `07_data_model.md` – Power BI model structure, relationships and measures
- `08_dashboard.md` – dashboard pages, visuals and design choices
- `sql/` – SQL scripts used throughout the project
- `images/` – data model and dashboard screenshots
- `powerbi/` – Power BI `.pbix` report
- `data/` – original data dictionary provided with the dataset