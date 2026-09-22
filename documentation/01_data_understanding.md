# Data Understanding

## Tables

### Customers 

- Rows: 17,000
- Potential key: customer_id
- Columns: customer_id, became_member_on, gender, age, income
- Potential issues noticed: 
    - income imported as nvarchar
    - became_member_on imported as int in YYYYMMDD format
    - income contains NULL values 
    - gender contains NULL values
- Likely relationships: customer_id to events.customer_id
- Other observations:
    - dimension table
    - caterogical columns and count: gender (M: 8482, F: 6129, O: 212 NULL: 2175)

#### Range of values: 

| min_age |	max_age	| min_income |	max_income	| min_became_member_on 	| max_became_member_on |
| -------- |-------- |--------|--------|--------|-------- |
| 18	| 118	| 30000	| 120000	| 20130729	| 20180726 |

----

### Events

- Rows: 306,534
- Potential key: no obvious natural primary key
- Grain: one customer event
- Columns: customer_id, event, value, time
- Potential issues noticed: 
    - column 'value' contains offer_id, but the text would need to me trimmed
    - time imported as nvarchar
- Likely relationships: customer_id to customers.customer_id, value to offers.offer_id (when 'offer recieved')
- Other observations:
    - doesn't contain NULL values
    - fact table
    - events.value is a semi-structured field containing either offer-related information or transaction amount depending on event type
    - caterogical columns and count: event (transaction: 138953, offer received: 76277, offer viewed: 57725, offer completed: 33579)

#### Range of values: 

| min_time |	max_time	|
| -------- |-------- |
| 0	| 714	|

---

### Offers

- Rows: 10
- Potential key: offer_id
- Columns: offer_id, offer_type, difficulty, reward, duration, channels
- Potential issues noticed: 
    - difficulty and reward imported as nvarchar values
- Likely relationships: offer_id to events.value
- Other observations:
    - possible need to divide channel column into 4 new ones: e-mail, web, mobile and social
    - dimension table
    - caterogical columns and count: offer_type (bobo: 4, discount: 4, informational: 2)

#### Range of values: 

| min_duration |	max_duration	| min_difficulty |	max_difficulty	| min_reward 	| max_reward |
| -------- |-------- |--------|--------|--------|-------- |
| 3	| 10	| 0	| 20	| 0	| 10 |
