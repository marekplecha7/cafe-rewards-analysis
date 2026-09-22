-- # Analysis

---- Views context 

SELECT TOP 20 *
FROM vw_customers_clean
-- customer_id, became_member_on, gender, age, income

SELECT TOP 20 *
FROM vw_events_clean
-- customer_id, event, offer_id, reward, amount, time

SELECT TOP 20 *
FROM vw_offers_clean
-- offer_id, offer_type, difficulty, reward, duration, channels, has_email, has_mobile, has_social, has_web

---dictionary
select * from dbo.data_dictionary



-- How many offers were received, viewed and completed?

SELECT
event,
COUNT(*) as cnt
FROM vw_events_clean
WHERE event in ('offer received', 'offer viewed', 'offer completed')
GROUP BY event


-- Completion and view rate by offer

View Rate = viewed / received
Completion Rate = completed / received

received | viewed | completed | view_rate | completion_rate

WITH groups as (
SELECT 
	SUM(CASE WHEN event = 'offer received' THEN 1 ELSE 0 END) as received,
	SUM(CASE WHEN event = 'offer viewed' THEN 1 ELSE 0 END) as viewed,
	SUM(CASE WHEN event = 'offer completed' THEN 1 ELSE 0 END) as completed
FROM vw_events_clean
)

SELECT
	received,
	viewed,
	completed,
	CAST(viewed * 100.0 / received as DECIMAL(5,2)) as view_rate,
	CAST(completed * 100.0 / received as DECIMAL(5,2)) as completion_rate
FROM groups



-- Performance by offer type — BOGO vs discount vs informational

WITH OfferTypeStats as (
	SELECT
		o.offer_type,
		SUM(CASE WHEN e.event = 'offer received' THEN 1 ELSE 0 END) as received,
		SUM(CASE WHEN e.event = 'offer viewed' THEN 1 ELSE 0 END) as viewed,
		SUM(CASE WHEN e.event = 'offer completed' THEN 1 ELSE 0 END) as completed
	FROM vw_events_clean as e
	JOIN vw_offers_clean as o
		on e.offer_id = o.offer_id
	GROUP BY o.offer_type
)

SELECT
	offer_type,
	received,
	viewed,
	completed,
	CAST(viewed * 100.0 / received as DECIMAL(5,2)) as view_rate,
	CAST(completed * 100.0 / received as DECIMAL(5,2)) as completion_rate
FROM OfferTypeStats
ORDER BY completion_rate desc



-- Performance per individual offer


WITH OfferIDStats as (
	SELECT
		o.offer_id,
		o.offer_type,
		SUM(CASE WHEN e.event = 'offer received' THEN 1 ELSE 0 END) as received,
		SUM(CASE WHEN e.event = 'offer viewed' THEN 1 ELSE 0 END) as viewed,
		SUM(CASE WHEN e.event = 'offer completed' THEN 1 ELSE 0 END) as completed
	FROM vw_events_clean as e
	JOIN vw_offers_clean as o
		on e.offer_id = o.offer_id
	GROUP BY o.offer_id, o.offer_type
), Rates as (
	SELECT 
		offer_id,
		offer_type,
		received,
		viewed,
		completed,
		CAST(viewed * 100.0 / received as DECIMAL(5,2)) as view_rate,
		CAST(completed * 100.0 / received as DECIMAL(5,2)) as completion_rate
	FROM OfferIDStats
)

SELECT
	offer_id,
	offer_type,
	received,
	viewed,
	completed,
	view_rate,
	completion_rate,
	RANK() OVER (
		ORDER BY view_rate desc) as view_rank,
	RANK() OVER (
		ORDER BY completion_rate desc) as completion_rank
FROM Rates
ORDER BY completion_rank
---- view_rank includes all offer types, while completion_rank should only be interpreted 
---- for BOGO and discount offers because informational offers do not generate completion events.




-- completed after viewed vs completed without viewed

WITH CompletedOffers as (
    SELECT
        customer_id,
        offer_id,
        time
    FROM vw_events_clean
    WHERE event = 'offer completed'
),
ViewedOffers as (
    SELECT
        customer_id,
        offer_id,
        time
    FROM vw_events_clean
    WHERE event = 'offer viewed'
),
CompletedStatus as (
    SELECT
        c.customer_id,
        c.offer_id,
        c.time,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM ViewedOffers AS v
                WHERE v.customer_id = c.customer_id
                  AND v.offer_id = c.offer_id
                  AND v.time <= c.time
            )
            THEN 'Completed after viewed'
            ELSE 'Completed without viewed'
        END AS completion_status
    FROM CompletedOffers AS c
)

SELECT
    completion_status,
    COUNT(*) as completed_count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        as DECIMAL(5,2)
    ) as percentage
FROM CompletedStatus
GROUP BY completion_status


SELECT TOP 20 *
FROM vw_customers_clean
-- customer_id, became_member_on, gender, age, income

SELECT TOP 20 *
FROM vw_events_clean
-- customer_id, event, offer_id, reward, amount, time


-- Customer spend


SELECT
	customer_id,
	SUM(amount) as total_spend,
	COUNT(*) as transaction_count,
	CAST(AVG(amount) AS DECIMAL(10,2)) as average_transaction_value
FROM vw_events_clean
WHERE event = 'transaction'
GROUP BY customer_id
ORDER BY total_spend desc


-- Customer spend per segments (purchasing customers)

---- How does spending behavior differ across income groups among purchasing customers?
WITH incomegroups as (
SELECT
	*,
    PERCENTILE_CONT(0.33) WITHIN GROUP (
        ORDER BY income
    ) OVER () as p33,
    PERCENTILE_CONT(0.67) WITHIN GROUP (
        ORDER BY income
    ) OVER () as p67
FROM vw_customers_clean
WHERE income is NOT NULL
), CustomerIncome as (
	SELECT
		customer_id, 
		became_member_on, 
		gender, 
		age, 
		income,
		CASE
			WHEN income < p33 THEN 'Low'
			WHEN income < p67 THEN 'Medium'
			ELSE 'High'
		END as income_group
	FROM incomegroups
), CustomerSpending as (
	SELECT
		customer_id,
		SUM(amount) as total_spend,
		COUNT(*) as transaction_count
	FROM vw_events_clean
	WHERE event = 'transaction'
	GROUP BY customer_id
)

SELECT
	ci.income_group,
	COUNT(*) as customer_count,
	CAST(AVG(cs.total_spend) as DECIMAL(10,2)) as average_total_spend,
	CAST(SUM(cs.total_spend) / SUM(cs.transaction_count * 1.0)
        as DECIMAL(10,2)
    ) as average_transaction_value,
	CAST(AVG(cs.transaction_count * 1.0) as DECIMAL(10,2)) as average_transaction_count
FROM CustomerIncome as ci
JOIN CustomerSpending as cs
	on ci.customer_id = cs.customer_id
GROUP BY ci.income_group




---- Which age groups have the highest offer completion rates?

WITH AgeGroups as (
	SELECT
		customer_id,  
		CASE
			WHEN age BETWEEN 18 AND 29 THEN '18-29'
			WHEN age BETWEEN 30 AND 44 THEN '30-44'
			WHEN age BETWEEN 45 AND 59 THEN '45-59'
			WHEN age >= 60 THEN '60+'
		END AS age_group
	FROM vw_customers_clean
	WHERE age is NOT NULL
), OfferStats as (
	SELECT
		customer_id,
		SUM(CASE WHEN event = 'offer received' THEN 1 ELSE 0 END) as received,
		SUM(CASE WHEN event = 'offer viewed' THEN 1 ELSE 0 END) as viewed,
		SUM(CASE WHEN event = 'offer completed' THEN 1 ELSE 0 END) as completed
	FROM vw_events_clean
	GROUP BY Customer_ID
)

SELECT
	a.age_group,
	COUNT(DISTINCT a.customer_id) as customer_count,
	SUM(o.received) as received,
	SUM(o.viewed) as viewed,
	SUM(o.completed) as completed,
	CAST(SUM(o.viewed) * 100.0 / SUM(o.received)
        AS DECIMAL(5,2)
    ) AS view_rate,
	CAST(SUM(o.completed) * 100.0 / SUM(o.received)
        AS DECIMAL(5,2)
    ) as completion_rate
FROM AgeGroups as a
JOIN OfferStats as o
	on a.customer_id = o.customer_id
GROUP BY a.age_group
ORDER BY a.age_group