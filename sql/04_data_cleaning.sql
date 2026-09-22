-- # Data Cleaning

---- Tables context

SELECT TOP 100 *
FROM dbo.customers
-- customer_id, became_member_on, gender, age, income

SELECT TOP 100 *
FROM dbo.events
-- customer_id, event, value, time

SELECT *
FROM dbo.offers
-- offer_id, offer_type, difficulty, reward, duration, channels

---dictionary
select * from dbo.data_dictionary



-- Creating vw_customers_clean view

---- | Customers | `income` imported as `nvarchar` | Convert to numeric type |
---- | Customers | `became_member_on` imported as `int` in YYYYMMDD format | Convert to `date` |
---- | Customers | 2,175 missing `gender` values | Keep as NULL |
---- | Customers | 2,175 missing `income` values | Keep as NULL |
---- | Customers | `age = 118` occurs for the same 2,175 customers with missing gender and income | Treat 118 as missing age and convert to NULL |

CREATE VIEW vw_customers_clean as 
SELECT
    customer_id,
    CONVERT(date, CONVERT(varchar(8), became_member_on),
    112) as became_member_on,
    gender,
    NULLIF(age, 118) as age,
    CAST(income as INT) as income
FROM customers


-- Creating vw_events_clean view

---- | Events | `time` imported as `nvarchar` | Convert to `int` |
---- | Events | `value` is semi-structured | Extract `offer_id`, `reward` and `amount` into separate columns |
---- | Events | Offer ID key appears as both `offer id` and `offer_id` | Standardize into one `offer_id` column |
---- | Events | 397 duplicate `offer completed` rows | Remove duplicate rows |


CREATE VIEW vw_events_clean as
WITH DeduplicatedEvents as (
    SELECT DISTINCT
        customer_id,
        event,
        value,
        time
    FROM events
)

SELECT
    customer_id, 
    event, 
    COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id,
    TRY_CAST(
        JSON_VALUE(REPLACE(value, '''', '"'), '$.reward')
        as INT
    ) as reward,
    TRY_CAST(
        JSON_VALUE(REPLACE(value, '''', '"'), '$.amount')
        as DECIMAL(10,2)
    ) as amount,
    CAST(time as INT) as time
FROM DeduplicatedEvents



-- Creating vw_offers_clean

---- | Offers | `difficulty` imported as `nvarchar` | Convert to numeric type |
---- | Offers | `reward` imported as `nvarchar` | Convert to numeric type |
---- | Offers | `channels` contains multiple values in a single field | Split into separate channel indicator columns |

SELECT *
FROM dbo.offers
-- offer_id, offer_type, difficulty, reward, duration, channels

CREATE VIEW vw_offers_clean as
SELECT
    offer_id, 
    offer_type, 
    CAST(difficulty as INT) as difficulty,
    CAST(reward as INT) as reward,
    duration,
    channels,
    CASE WHEN channels LIKE '%email%' THEN 1 ELSE 0 END as has_email,
    CASE WHEN channels LIKE '%mobile%' THEN 1 ELSE 0 END as has_mobile,
    CASE WHEN channels LIKE '%social%' THEN 1 ELSE 0 END as has_social,
    CASE WHEN channels LIKE '%web%' THEN 1 ELSE 0 END as has_web
FROM offers




---- Final sanity check

SELECT TOP 20 *
FROM vw_customers_clean

SELECT TOP 20 *
FROM vw_offers_clean

SELECT TOP 20 *
FROM vw_events_clean
---- looks fine


SELECT COUNT(*) FROM customers
SELECT COUNT(*) FROM vw_customers_clean

SELECT COUNT(*) FROM offers
SELECT COUNT(*) FROM vw_offers_clean

SELECT COUNT(*) FROM events
SELECT COUNT(*) FROM vw_events_clean
SELECT 306534 - 306137
---- the counts are correct. event_clean count smaller by 397 extra rows.



SELECT
    event,
    COUNT(*) AS cnt,
    COUNT(offer_id) AS offer_id_count,
    COUNT(reward) AS reward_count,
    COUNT(amount) AS amount_count
FROM vw_events_clean
GROUP BY event
-- All offer_ids, rewards and amounts extracted properly