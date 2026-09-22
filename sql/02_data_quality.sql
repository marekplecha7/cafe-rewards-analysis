-- # Data Quality Checks


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
select * from [dbo].[data_dictionary]

-- ## Customers (dimension table)

---- CHECKING COMPLETENESS
SELECT
SUM(CASE WHEN customer_id is NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) as customer_id_Null,
SUM(CASE WHEN became_member_on is NULL THEN 1 ELSE 0 END) as became_member_on_Null,
SUM(CASE WHEN gender is NULL OR TRIM(gender) = '' THEN 1 ELSE 0 END) as gender_Null,
SUM(CASE WHEN age is NULL then 1 else 0 end) as age_Null,
SUM(CASE WHEN income is NULL OR TRIM(income) = '' THEN 1 ELSE 0 END) as income_null
FROM Customers
------ gender and income contain NULLs


---- CHECKING UNIQUENESS
SELECT COUNT(customer_id) as DuplicateCount, customer_id 
FROM customers
GROUP BY customer_id
HAVING COUNT(customer_id) > 1
------ customer_id in customers is UNIQUE, no row is shown, valid candidate for primary key



-- ## Events (fact table)


---- CHECKING COMPLETENESS
SELECT
SUM(CASE WHEN customer_id is NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) as customer_id_Null,
SUM(CASE WHEN event is NULL THEN 1 ELSE 0 END) as event_Null,
SUM(CASE WHEN value is NULL OR TRIM(value) = '' THEN 1 ELSE 0 END) as value_Null,
SUM(CASE WHEN time is NULL then 1 else 0 end) as time_Null
FROM events
------ Table 'events' doesn't contain NULLs

---- CHECKING UNIQUENESS
SELECT count(customer_id) as DuplicateCount, customer_id 
FROM events
GROUP BY customer_id
HAVING count(customer_id) > 1
------ no primary key, however events.customer_id might be foreign key to customers table


SELECT count(*) as DuplicateCount, customer_id, value
FROM events
GROUP BY customer_id, value
HAVING count(*) > 1
------ combination customer_id + value is not unique as well

SELECT
    customer_id,
    event,
    value,
    time,
    COUNT(*) as DuplicateCount
FROM Events
GROUP BY
    customer_id,
    event,
    value,
    time
HAVING COUNT(*) > 1
ORDER BY DuplicateCount desc
---- Found 396 rows with exactly the same values for each of the column

WITH Duplicates as (
    SELECT
        customer_id,
        event,
        value,
        time,
        COUNT(*) as DuplicateCount
    FROM Events
    GROUP BY
        customer_id,
        event,
        value,
        time
    HAVING COUNT(*) > 1
)

SELECT
    event,
    COUNT(*) AS DuplicateGroups,
    SUM(DuplicateCount - 1) as ExtraRows
FROM Duplicates
GROUP BY event
ORDER BY ExtraRows desc
---- Duplication exists only for 'offer completed' so seems like data quality problem --> to remove later on


-- ## Offers

---- CHECKING COMPLETENESS
SELECT
SUM(CASE WHEN offer_id is NULL OR TRIM(offer_id) = '' THEN 1 ELSE 0 END) as offer_id_Null,
SUM(CASE WHEN offer_type is NULL OR TRIM(offer_type) = '' THEN 1 ELSE 0 END) as offer_type_Null,
SUM(CASE WHEN difficulty is NULL OR TRIM(difficulty) = '' THEN 1 ELSE 0 END) as difficulty_Null,
SUM(CASE WHEN reward is NULL OR TRIM(reward) = '' then 1 else 0 end) as reward_Null,
SUM(CASE WHEN duration is NULL THEN 1 ELSE 0 END) as duration_null,
SUM(CASE WHEN channels is NULL OR TRIM(channels) = '' THEN 1 ELSE 0 END) as channels_null
FROM offers
------ Table 'offers' doesn't contain NULLs


---- CHECKING UNIQUENESS
SELECT count(offer_id) as DuplicateCount, offer_id 
FROM offers
GROUP BY offer_id
HAVING count(offer_id) > 1
------ offer_id in offers is UNIQUE, no row shown, valid candidate for primary key






-- CHECKING REFERENTIAL INTEGRITY

---- fact -> dimension
events.customer_id -> customers.customer_id

SELECT DISTINCT
    e.customer_id
FROM events as e
LEFT JOIN customers as c
    on e.customer_id = c.customer_id
WHERE c.customer_id is NULL
-- Every customer_id in Events has a corresponding record in Customers.