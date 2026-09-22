-- # Business Validation

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

-------------------------------------------------------------------------------------

-- Are there any suspicious or invalid age values?  
-- Is there any suspicious income value?
-- Is any date written in wrong format? That is, more than 12 months or more then 31 days.
-- Does time = 0 occur for any other event than 'offer received' or 'offer viewed'?
-- Is time consistent with the 30-day period defined in the dictionary?
-- Is value structure logical for the type of event?
-- Do offer_ids in value correspond to the ones in offers table?
-- Do 'reward' value in value column correspond to the ones in offers table, for specific offer_id?
-- Do difficulty, reward or duration have sense for given offer_type?
-- Does every offer completed event have a corresponding received event for the same customer and offer at the same or an earlier recorded time?
-- Does every offer viewed have a corresponding offer received for the same customer and offer_id at the same or an earlier recorded time?
-- Does every offer completed event have a corresponding offer viewed for the same customer and offer_id at the same or an earlier recorded time?
-- Does every offer completed event have a transaction for the same customer at the same recorded time?



-- Are there any suspicious or invalid age values?

SELECT
    MIN(age) as min_age,
    MAX(age) as max_age
FROM Customers
---- Age is in a valid range of 18 to 118.

SELECT
    age,
    COUNT(*) as cnt
FROM customers
WHERE gender is NULL
   OR income is NULL
GROUP BY age
ORDER BY age desc
---- HOWEVER, age 118 seems to exist only for the rows which contain NULL values

SELECT
    gender,
    income,
    COUNT(*) as cnt
FROM customers
WHERE age = 118
GROUP BY
    gender,
    income
---- and age 118 exists only with NULL values which most likely means that it's not a valid age.


SELECT
    age
FROM Customers
WHERE age < 118
ORDER BY age desc
---- Next rows contain ages as high as 101, then 100, 99 etc. 
---- The 17-year gap between 101 and 118, combined with missing gender and income,
---- Strongly suggests that age 118 is a placeholder for missing demographic data.



-- Is there any suspicious income value?

SELECT
    MIN(TRY_CAST(income as INT)) as min_income,
    MAX(TRY_CAST(income as INT)) as max_income
FROM Customers
---- Minimimum income = 30,000
---- Maximum income = 120,000
---- No obviously invalid income values found based on range.

SELECT
    AVG(TRY_CAST(income as INT)) as AverageIncome
FROM Customers
---- Average income = 65404
---- No obvious problem found based on the average


SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY TRY_CAST(income as INT)
    ) over () as MedianIncome
FROM Customers
WHERE income is NOT NULL
---- Median income = 64000
---- Median and average values are very close, appears reasonable
---- No obvious problem found based on the median


-- Is any date written in wrong format? That is, more than 12 months or more then 31 days.

WITH dates as (
SELECT 
    TRY_CONVERT(
    date,
    CONVERT(varchar(8), became_member_on),
    112) as became_member_on_valid
FROM Customers
)

SELECT 
*
FROM dates
WHERE became_member_on_valid is NULL
---- All values in became_member_on can be successfully converted to a valid date in YYYYMMDD format.

WITH dates as (
SELECT 
    TRY_CONVERT(
    date,
    CONVERT(varchar(8), became_member_on),
    112) as became_member_on_valid
FROM Customers
)

SELECT
    YEAR(became_member_on_valid) as membership_year,
    COUNT(*) as cnt
FROM dates
GROUP BY YEAR(became_member_on_valid)
ORDER BY membership_year desc
---- The customer count for years 2013 and 2014 is visibly smaller
---- This may reflect the early stage of the rewards program, but the dataset
---- does not provide enough context to confirm the reason.



-- Does time = 0 occur for any other event than 'offer received' or 'offer viewed'?
SELECT top 100
    time,
    event,
    COUNT(*)
FROM events
WHERE time = 0
group by time, event
---- Events occurring at time = 0 include multiple event types.
---- This is plausible because several customer actions may occur within
---- the first recorded hour of the observation period.


-- Is time consistent with the 30-day period defined in the dictionary?


SELECT
    MAX(TRY_CAST(time as INT)) / 24 as NumberOfPossibleDays
FROM events
-- max 714 hours, so 29 days what matched the definition in the dictionary







-- Is value structure logical for the type of event?

SELECT 
    event,
    COUNT(*) as cnt
FROM dbo.events
GROUP BY event


SELECT TOP 20
    event,
    value
FROM dbo.events
WHERE event = 'offer completed'
---- seems to contain offer_ID, reward

SELECT TOP 20
    event,
    value
FROM dbo.events
WHERE event = 'offer received'
---- seems to contain offer_ID only

SELECT TOP 20
    event,
    value
FROM dbo.events
WHERE event = 'offer viewed'
---- seems to contain offer_ID only

SELECT TOP 20
    event,
    value
FROM dbo.events
WHERE event = 'transaction'
---- seems to contain amount only

-- Does 'offer completed' event always icludes offer_ID and reward?
SELECT *
FROM Events
WHERE event = 'offer completed'
  AND (
      value NOT LIKE '%offer%'
      OR value NOT LIKE '%reward%'
  )
-- Yes



-- Does 'offer received' event always icludes offer_ID?
SELECT 
*
FROM Events
WHERE event = 'offer received'
  AND value NOT LIKE '%offer%'
---- Yes


-- Does 'offer viewed' event always icludes offer_ID?
SELECT 
*
FROM Events
WHERE event = 'offer viewed'
  AND value NOT LIKE '%offer%'
---- Yes


-- Does transaction always include amount in value?
SELECT
*
FROM dbo.events
WHERE event = 'transaction'
AND value NOT LIKE '%amount%'
---- Yes


----------- HOWEVER
SELECT DISTINCT TOP 50
    event,
    value
FROM Events
WHERE event IN ('offer received', 'offer viewed', 'offer completed');


{'offer id': '9b98b8c7a33c4b65b9aebfe6a799e6d9'}


{'offer_id': '2906b810c7d4411798c6938adc9daaa5', 'reward': 2}

{'offer id': '3f207df678b143eea3cee63160fa8bed'}


{'offer id': '2906b810c7d4411798c6938adc9daaa5'}
----------- in value field there seem to be both 'offer_id' and 'offer id'



-- Do offer_ids in value correspond to the ones in offers table?

WITH ExtractedOffers as (
    SELECT
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event in ('offer received', 'offer viewed', 'offer completed')
)

SELECT DISTINCT
    eo.offer_id
FROM ExtractedOffers as eo
LEFT JOIN Offers as o
    ON eo.offer_id = o.offer_id
WHERE o.offer_id is NULL
---- Yes, all offer_id values extracted from events: ('offer completed', 'offer viewed', 'offer completed')
---- have matching records in the Offers table.




-- Do 'reward' value in value column correspond to the ones in offers table, for specific offer_id?


WITH ExtractedRecords as (
    SELECT
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id,
        TRY_CAST(
            JSON_VALUE(REPLACE(value, '''', '"'), '$.reward')
            as INT
        ) as reward
    FROM events
    WHERE event = 'offer completed'
)

SELECT DISTINCT
    er.offer_id,
    er.reward
FROM ExtractedRecords as er
LEFT JOIN Offers as o
    ON er.reward = TRY_CAST(o.reward as INT)
    AND er.offer_ID = o.offer_id
WHERE o.offer_ID is NULL

---- Yes, all rewards in events.value have a matching record in the Offers table
---- also matching for the corresponding offer_id





-- Do difficulty, reward or duration have sense for given offer_type?


SELECT
    offer_type,
    MIN(TRY_CAST(difficulty AS INT)) AS min_difficulty,
    MAX(TRY_CAST(difficulty AS INT)) AS max_difficulty,
    MIN(TRY_CAST(reward AS INT)) AS min_reward,
    MAX(TRY_CAST(reward AS INT)) AS max_reward,
    MIN(duration) AS min_duration,
    MAX(duration) AS max_duration
FROM Offers
GROUP BY offer_type

---- Informational offers do not require spending and do not provide a reward, which is consistent with their purpose.
---- All BOGO and discount offers require a positive spending threshold and provide a positive reward.




SELECT TOP 100 *
FROM dbo.events
-- customer_id, event, value, time


-- Does every offer completed event have a corresponding received event for the same customer and offer at the same or an earlier recorded time?

WITH CompletedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer completed'
), ReceivedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer received'
)

SELECT 
    *
FROM CompletedOffers as c
WHERE NOT EXISTS (
    SELECT 1
    FROM ReceivedOffers as  r
    WHERE r.customer_id = c.customer_id
      AND r.offer_id = c.offer_id
      AND r.time <= c.time
)
---- Every offer completed event has a corresponding offer received event for the same customer and offer_id at the same or an earlier recorded time.




-- Does every offer viewed have a corresponding offer received for the same customer and offer_id at the same or an earlier recorded time?

WITH ViewedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer viewed'
), ReceivedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer received'
)

SELECT 
    *
FROM ViewedOffers as v
WHERE NOT EXISTS (
    SELECT 1
    FROM ReceivedOffers as  r
    WHERE r.customer_id = v.customer_id
      AND r.offer_id = v.offer_id
      AND r.time <= v.time
)
---- Every offer viewed event has a corresponding offer received event for the same customer and offer at the same or an earlier recorded time.



-- Does every offer completed event have a corresponding offer viewed for the same customer and offer_id at the same or an earlier recorded time?


WITH ViewedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer viewed'
), CompletedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as time,
        COALESCE(
            JSON_VALUE(REPLACE(value, '''', '"'), '$."offer id"'),
            JSON_VALUE(REPLACE(value, '''', '"'), '$.offer_id')
        ) as offer_id
    FROM Events
    WHERE event = 'offer completed'
)

SELECT 
    *
FROM CompletedOffers as c
WHERE NOT EXISTS (
    SELECT 1
    FROM ViewedOffers as v
    WHERE c.customer_id = v.customer_id
      AND c.offer_id = v.offer_id
      AND v.time <= c.time
)
-- 8,649 completed offers were not viewed beforehand.
-- This is not necessarily a data quality issue and should be considered
-- during later analysis of offer effectiveness.





SELECT TOP 100 *
FROM dbo.events
-- customer_id, event, value, time




SELECT TOP 100 *
FROM dbo.events
WHERE event = 'transaction'
ORDER BY TRY_CAST(time as INT) desc




-- Does every offer completed event have a transaction for the same customer at the same recorded time?


WITH CompletedOffers as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as event_time
    FROM events
    WHERE event = 'offer completed'
), Transactions as (
    SELECT
        customer_id,
        TRY_CAST(time as INT) as event_time
    FROM events
    WHERE event = 'transaction'
)

SELECT 
*
FROM CompletedOffers as c
WHERE NOT EXISTS (
    SELECT 1
    FROM Transactions as t
    WHERE c.customer_id = t.customer_id
    AND c.event_time = t.event_time
)
---- Every offer completed event has a corresponding transaction for the same customer at the same recorded time.