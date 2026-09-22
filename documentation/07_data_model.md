# Data Model

## Goal

Create a simple and reusable Power BI data model supporting transaction analysis, promotional offer performance and customer segmentation.

## Model Structure

The core model follows a simple star schema with one fact table and two dimension tables:

- **Fact Events** – customer transactions and offer-related events
- **Dim Customers** – customer demographic and membership information
- **Dim Offers** – promotional offer attributes and distribution channels

Relationships:

- `Dim Customers[customer_id]` → `Fact Events[customer_id]` (1:*)
- `Dim Offers[offer_id]` → `Fact Events[offer_id]` (1:*)

Both relationships use single-direction filtering from the dimension tables to the fact table.

![Power BI Data Model](/images/data_model.PNG)

## Supporting Tables

Two additional tables were used outside the core star schema:

- **DAX Measures** – a dedicated table containing measures used across the report
- **Offer Completion Status** – a supporting analytical table used to compare completed offers with and without a prior recorded view

## Calculated Columns

Additional calculated columns were created in Power BI to support reporting and segmentation:

- **Observation Day** – converts event time into the corresponding observation day
- **Age Group** – groups customers into `18-29`, `30-44`, `45-59` and `60+`
- **Income Group** – groups customers into `Low`, `Medium` and `High` income segments using thresholds derived from SQL percentile analysis
- **Gender Label** – replaces abbreviated gender values with readable labels
- **Offer Label** – combines offer type with a shortened offer ID for clearer visualizations

Customers with missing demographic information were assigned to an `Unknown` category in the model and excluded where appropriate from demographic segment comparisons.

## DAX Measures

Core measures include:

- Total Revenue
- Total Customers
- Total Transactions
- Average Transaction Value
- Revenue per Customer
- Transactions per Customer
- Offers Received
- Offers Viewed
- Offers Completed
- View Rate
- Completion Rate

These measures are calculated dynamically based on the report filter context and are reused across dashboard pages.

![DAX Measures](/images/dax_measures.PNG)
