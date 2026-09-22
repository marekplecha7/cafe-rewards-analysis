# Power BI Dashboard

## Goal

The goal was to create an interactive Power BI dashboard presenting the main findings from the Cafe Rewards dataset in a clear and business-friendly format.

The report contains three pages:

1. Overview
2. Offer Performance
3. Customer Segments

## 1. Overview

The Overview page provides a high-level summary of customer activity, revenue and promotional offer performance.

### Key elements

- Total Customers
- Total Revenue
- Total Transactions
- Average Transaction Value
- Completion Rate
- Offer funnel: Received → Viewed → Completed
- View Rate by Offer Type
- Completion Rate by Offer Type
- Revenue by Observation Day

![Overview Dashboard](/images/dashboard_overview.PNG)

## 2. Offer Performance

The Offer Performance page provides a more detailed comparison of individual promotional offers.

### Key elements

- Offers Received
- Offers Viewed
- Offers Completed
- View Rate by individual offer
- Completion Rate by individual offer
- Offer-level performance table
- Offer Type and Offer Label slicers
- Completed offers with and without a prior recorded view

The offer performance table also includes difficulty, reward and duration to provide additional context when comparing individual offers.

![Offer Performance Dashboard](/images/dashboard_offer_performance.PNG)

## 3. Customer Segments

The Customer Segments page focuses on differences in customer behavior across demographic and income groups.

### Key elements

- Revenue per Customer
- Average Transaction Value
- Transactions per Customer
- Completion Rate
- Average Transaction Value by Income Group
- Transactions per Customer by Income Group
- View Rate and Completion Rate by Age Group
- Revenue per Customer by Gender
- Gender, Age Group and Income Group slicers

Customers with unavailable demographic information were retained in the data model but excluded from demographic segment comparisons where appropriate.

![Customer Segments Dashboard](/images/dashboard_customer_segments.PNG)

## Design

A coffee-inspired color palette was used to reflect the Cafe Rewards theme and maintain visual consistency across the report.

Colors were used with a simple semantic structure:

- **Brown** – primary theme color, also used for offers received and neutral/general metrics
- **Blue** – offers viewed / View Rate
- **Green** – offers completed / Completion Rate
- **Orange** – customer-segment and behavioral metrics

Beige backgrounds, brown accents and subtle coffee-themed visual elements were used across all pages to support the overall design without distracting from the data.

## Interactivity

The dashboard uses slicers and cross-filtering to allow users to explore results across different customer and offer segments.

Filters were kept page-specific to preserve a clear analytical focus on each report page.
