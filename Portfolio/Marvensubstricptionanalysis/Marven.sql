SELECT *
FROM  marvensubscription
--|DATA CLEANING|
--change date format
SELECT created_date,CONVERT(date,created_date)
FROM marvensubscription
ALTER TABLE marvensubscription
ADD created_dateconv DATE
UPDATE marvensubscription
SET created_dateconv=CONVERT(date,created_date)
SELECT*
FROM marvensubscription
SELECT canceled_date,CONVERT(date,canceled_date)
FROM marvensubscription
ALTER TABLE marvensubscription
ADD canceled_dateconv DATE
UPDATE marvensubscription
SET canceled_dateconv=CONVERT(date,created_date)

--checkingforduplicates
SELECT customer_id,COUNT(*) as Duplicates
FROM marvensubscription
GROUP BY customer_id
HAVING COUNT(*)>1

--using CTEs and Partition 
WITH DuplicateRows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id,created_date,canceled_date ORDER BY customer_id) AS RowNum
    FROM marvensubscription
)
SELECT * FROM DuplicateRows WHERE RowNum > 1;
--here we see we have 3 customers we the same customerid and created_date hence we will remove the duplicates 
WITH DuplicateRows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS RowNum
    FROM marvensubscription
)
DELETE FROM DuplicateRows WHERE RowNum >1;
--checking for null values
--because its a table with few columns we will use CASE
SELECT
  COUNT(CASE WHEN customer_id IS NULL THEN 1 END) as customer_idnulls,
  COUNT(CASE WHEN created_date IS NULL THEN 1 END) as created_datenulls,
  COUNT(CASE WHEN canceled_date IS NULL THEN 1 END) as canceled_datenull,
  COUNT(CASE WHEN subscription_cost IS NULL THEN 1 END) as subscription_costnulls,
  COUNT(CASE WHEN subscription_interval IS NULL THEN 1 END) as subscription_intervalnulls,
  COUNT(CASE WHEN was_subscription_paid IS NULL THEN 1 END) as was_subscription_paidnulls
FROM marvensubscription
---only canceled_date has 961 null values 
--we will use COALESCE to replace null values with UNKNOWN 
UPDATE marvensubscription
SET canceled_date = COALESCE(CONVERT(date,canceled_date),'Unknown')
WHERE canceled_date IS NULL
UPDATE marvensubscription
SET canceled_date = ISNULL(CONVERT(date,canceled_date), 'Unknown');