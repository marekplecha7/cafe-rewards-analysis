# Data Cleaning

## Goal

The goal of this stage was to create a clean analytical layer without modifying the original source tables.

Clean SQL views were created and will be used as the source for further analysis and Power BI.

## Created Views

- `vw_customers_clean`
- `vw_offers_clean`
- `vw_events_clean`

## Transformations

| View | Transformation |
|---|---|
| `vw_customers_clean` | Converted `became_member_on` from integer `YYYYMMDD` format to `DATE` |
| `vw_customers_clean` | Converted `income` from text to `INT` |
| `vw_customers_clean` | Replaced placeholder `age = 118` with `NULL` |
| `vw_events_clean` | Removed exact duplicate event rows |
| `vw_events_clean` | Parsed the semi-structured `value` field into separate `offer_id`, `reward` and `amount` columns |
| `vw_events_clean` | Standardized inconsistent `offer id` / `offer_id` keys into one `offer_id` column |
| `vw_events_clean` | Converted `time` from text to `INT` |
| `vw_events_clean` | Converted transaction `amount` to `DECIMAL(10,2)` |
| `vw_offers_clean` | Converted `difficulty` and `reward` to numeric types |
| `vw_offers_clean` | Split the multi-value `channels` field into separate channel flags: email, mobile, social and web |

## Validation

After creating the views:

- Customer and offer row counts remained unchanged.
- Event row count decreased only by the previously identified duplicate records (397 extra rows).
- Parsed event fields were consistent with event types:
  - `transaction` → `amount`
  - `offer received` / `offer viewed` → `offer_id`
  - `offer completed` → `offer_id` and `reward`
- Original source tables were not modified.

## Result

The cleaned views provide a consistent analytical layer for the next stage of the project: SQL business analysis and Power BI modeling.