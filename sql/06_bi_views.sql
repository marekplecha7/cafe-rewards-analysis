-- completed after viewed vs completed without viewed

CREATE OR ALTER VIEW vw_offer_completion_status as
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