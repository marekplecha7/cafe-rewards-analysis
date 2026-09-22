USE DATABASE CafeRewards

-- # Data Understanding

---- Tables

SELECT TOP 100 *
FROM dbo.customers

SELECT *
FROM dbo.offers

--dictionary
select * from [dbo].[data_dictionary]

---- RowCounts

SELECT COUNT(*) as CustomersCount
FROM dbo.customers

SELECT COUNT(*) as EventsCount
FROM dbo.events

SELECT COUNT(*) as OffersCount
FROM dbo.offers


---- ColumnStructure

EXEC sp_help 'Customers'
EXEC sp_help 'Events'
EXEC sp_help 'Offers'

---- Identyfying incorrect column types

SELECT DISTINCT TOP 30 income
FROM Customers

SELECT DISTINCT TOP 30 became_member_on
FROM Customers



--checking if converting would create any problems
SELECT income
FROM Customers
WHERE TRY_CAST(income as INT) is NULL
  AND income is NOT NULL



SELECT became_member_on
FROM Customers
WHERE TRY_CONVERT(
    date,
    CONVERT(varchar(8), became_member_on),
    112
) IS NULL




-- Checking the count of values in categorical columns
SELECT event, COUNT(*) as cnt
FROM Events
GROUP BY event
ORDER BY cnt desc
---- transaction 138953, offer received 76277, offer viewed 57725, offer completed 33579

SELECT gender, COUNT(*) as cnt
FROM customers
GROUP BY gender
ORDER BY cnt desc
---- M 8482, F 6129, O 212 NULL 2175


SELECT offer_type, COUNT(*) as cnt
FROM Offers
GROUP BY offer_type
---- bobo 4, discount 4, informational 2



-- Checking ranges of numerical of values
SELECT
    MIN(age) as min_age,
    MAX(age) as max_age,
    MIN(TRY_CAST(income AS INT)) as min_income,
    MAX(TRY_CAST(income AS INT)) as max_income,
    MIN(became_member_on) as min_became_member_on,
    MAX(became_member_on) as max_became_member_on
FROM Customers


SELECT
    MIN(duration) AS min_duration,
    MAX(duration) AS max_duration,
    MIN(TRY_CAST(difficulty AS INT)) AS min_difficulty,
    MAX(TRY_CAST(difficulty AS INT)) AS max_difficulty,
    MIN(TRY_CAST(reward AS INT)) AS min_reward,
    MAX(TRY_CAST(reward AS INT)) AS max_reward
FROM Offers


SELECT
    MIN(TRY_CAST(time as INT)) as min_time,
    MAX(TRY_CAST(time as INT)) as max_time
FROM events