# SQL Analysis

## Goal

The goal of this stage was to use the cleaned analytical layer to answer key business questions about promotional offer performance and customer behaviour.

The analysis focused on:
- offer engagement and completion,
- performance differences between offer types,
- performance of individual offers,
- customer spending behavior,
- differences between customer segments.

---

## 1. Overall Offer Funnel

The first analysis measured the number of offer events at each stage of the promotional funnel.

| Metric | Result |
|---|---|
| Offers received | 76,277 |
| Offers viewed | 57,725 |
| Offers completed | 33,182 |
| View rate | 75.68% |
| Completion rate | 43.50% |

### Insight

Approximately three quarters of received offers were viewed, while fewer than half were completed.

The difference between view rate and completion rate suggests that a significant share of customers engage with offers without ultimately completing them.

---

## 2. Offer Type Performance

Offer engagement and completion were compared across BOGO, discount and informational offers.

| Offer type | Received | Viewed | Completed | View rate | Completion rate |
|---|---|---|---|---|---|
| Discount | 30,543 | 21,445 | 17,681 | 70.21% | 57.89% |
| BOGO | 30,499 | 25,449 | 15,501 | 83.44% | 50.82% |
| Informational | 15,235 | 10,831 | 0 | 71.09% | N/A |

### Insights

- BOGO offers achieved the highest view rate at 83.44%.
- Discount offers achieved the highest completion rate at 57.89%.
- Informational offers do not generate completion events, therefore completion rate is not a meaningful performance metric for this offer type.
- BOGO offers appear stronger at generating initial engagement, while discount offers convert a larger share of received offers into completed offers.

---

## 3. Individual Offer Performance

Each offer was analyzed separately using:

- received count,
- viewed count,
- completed count,
- view rate,
- completion rate.

Window functions were used to rank individual offers by both view rate and completion rate.

`RANK()` was used to compare promotional performance across offers without removing informational offers from the analysis.

### Interpretation

The two rankings measure different parts of the funnel:

- `view_rank` identifies offers that generate the strongest initial engagement.
- `completion_rank` identifies offers that are most frequently completed after being received.

Completion ranking should only be interpreted for BOGO and discount offers because informational offers do not generate completion events.

---

## 4. Offer Completion With and Without Prior Viewing

Completed offers were divided into two groups:

- completed after the same offer had previously been viewed,
- completed without any earlier recorded view of the same offer.

| Completion status | Count | Share |
|---|---|---|
| Completed after viewed | 24,614 | 74.18% |
| Completed without viewed | 8,568 | 25.82% |

### Insight

Most completed offers were preceded by a recorded offer view.

However, more than one quarter of completed offers had no earlier recorded view of the same offer. This suggests that offer completion should not automatically be interpreted as evidence that the customer engaged with the promotional message beforehand.

These cases should be considered separately when evaluating offer effectiveness.

---

## 5. Customer Spending

Customer-level transaction behaviour was calculated using:

- total spend,
- transaction count,
- average transaction value.

The analysis showed substantial differences in spending behavior between customers and provided the basis for customer segmentation.

---

## 6. Spending by Income Group

Customers with available income data were divided into three approximately equal income groups using the 33rd and 67th percentiles.

Only customers with at least one transaction were included in the spending comparison.

| Income group | Customers | Average total spend | Average transaction value | Average transaction count |
|---|---|---|---|---|
| High | 5,022 | 170.57 | 25.25 | 6.75 |
| Medium | 4,661 | 112.61 | 12.43 | 9.06 |
| Low | 4,809 | 73.50 | 7.39 | 9.94 |

### Insights

- High-income customers generated the highest average total spend.
- Their average transaction value was more than three times higher than that of the low-income group.
- High-income customers made fewer transactions on average, but each transaction was substantially larger.
- Low-income customers made the highest number of transactions on average, but generated the lowest total spend.

This suggests that higher-income customers generate more value primarily through larger transaction sizes rather than higher purchase frequency.

---

## 7. Offer Engagement by Age Group

Customers were divided into four age groups (e.g group contains at least 13 years) and their offer engagement was compared.

| Age group | Customers | Received | Viewed | Completed | View rate | Completion rate |
|---|---|---|---|---|---|---|
| 18–29 | 1,574 | 7,095 | 4,913 | 2,670 | 69.25% | 37.63% |
| 30–44 | 2,551 | 11,452 | 8,605 | 5,062 | 75.14% | 44.20% |
| 45–59 | 4,825 | 21,623 | 16,490 | 10,889 | 76.26% | 50.36% |
| 60+ | 5,875 | 26,331 | 19,852 | 13,449 | 75.39% | 51.08% |

### Insights

- The youngest customer group had the lowest view rate and completion rate.
- Offer completion increased substantially with age, from 37.63% among customers aged 18–29 to 51.08% among customers aged 60+.
- View rate increased from 69.25% in the youngest group to approximately 75–76% among older groups.
- Customers aged 45+ showed the strongest offer completion behavior.

This suggests that older customer segments were more responsive to promotional offers during the observed period.

---

## SQL Techniques Used

This stage used several SQL techniques introduced beyond the initial data-cleaning workflow:

- Common Table Expressions (CTEs)
- INNER JOINs
- CASE expressions
- aggregate functions
- conditional aggregation
- EXISTS / NOT EXISTS
- window functions
- `RANK()`
- `PERCENTILE_CONT()`
- multi-level aggregation
- customer segmentation

---

## Summary

The analysis identified several clear behavioral patterns:

- Offer engagement is relatively high, but completion is substantially lower than viewing.
- BOGO offers generate stronger initial engagement, while discount offers achieve higher completion rates.
- Customer income is strongly associated with spending behavior.
- Higher-income customers spend more per transaction despite making fewer purchases.
- Offer completion should not always be interpreted as prior promotional engagement, because some offers are completed without a recorded earlier view.

These findings will be used as the foundation for the Power BI data model and dashboard design.