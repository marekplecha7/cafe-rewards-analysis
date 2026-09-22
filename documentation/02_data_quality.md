# Data Quality Report

## Customers (17,000 rows)

### Uniqueness

```
| customer_id unique | ✅ Yes |
```
**valid primary key**


### Completeness
```
| customer_id NULL | 0 |
| became_member_on NULL | 0 |
| gender NULL | 2175 |
| age NULL | 0 |
| income NULL | 2175 |
```

##  Events (306,534 rows)


### Uniqueness

```
| any column unique | ❌ No |
```

```
| Duplicated rows | 396 |
| Extra rows (to remove) | 397 |
```

### Completeness
```
| customer_id NULL | 0 |
| event NULL | 0 |
| value NULL | 0 |
| time NULL | 0 |
```


## Offers (10 rows)

```
| offer_id unique | ✅ Yes |
```
**valid primary key**

### Completeness
```
| offer_id NULL | 0 |
| offer_type NULL | 0 |
| difficulty NULL | 0 |
| reward NULL | 0 |
| duration NULL | 0 |
| channels NULL | 0 |
```

## Referential integrity

`events.customer_id   →   customers.customer_id`

```
| events.customer_id exists in customers | ✅ Passed (0 orphan records) |
```


## Summary

- No duplicate customer_id values found
- No duplicate offer_id values found
- Missing values exist only in customer gender and income
- No missing values found in Events or Offers
- No orphan customer references found in Events
- 397 duplicate Event rows were identified. All duplicates occurred for offer completed events. These records will be reviewed and removed during data cleaning.