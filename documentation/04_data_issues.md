# Data Issues indentified prior to cleaning

| Table | Issue | Planned action |
|---|---|---|
| Customers | `income` imported as `nvarchar` | Convert to numeric type |
| Customers | `became_member_on` imported as `int` in YYYYMMDD format | Convert to `date` |
| Customers | 2,175 missing `gender` values | Keep as NULL |
| Customers | 2,175 missing `income` values | Keep as NULL |
| Customers | `age = 118` occurs for the same 2,175 customers with missing gender and income | Treat 118 as missing age and convert to NULL |
| Events | `time` imported as `nvarchar` | Convert to `int` |
| Events | `value` is semi-structured | Extract `offer_id`, `reward` and `amount` into separate columns |
| Events | Offer ID key appears as both `offer id` and `offer_id` | Standardize into one `offer_id` column |
| Events | 397 duplicate `offer completed` rows | Remove duplicate rows |
| Offers | `difficulty` imported as `nvarchar` | Convert to numeric type |
| Offers | `reward` imported as `nvarchar` | Convert to numeric type |
| Offers | `channels` contains multiple values in a single field | Split into separate channel indicator columns |