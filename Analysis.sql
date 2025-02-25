-- Data Cleaning 

-- Step 1: Standardize text fields
UPDATE consumer_behavior.purchases
   SET gender = LOWER(gender),
       item_purch = LOWER(item_purch),
	   category = LOWER(category),
       location = LOWER(location),
       size = UPPER(size),
       color = LOWER(color),
       season = LOWER(season),
       subscription_status = LOWER(subscription_status),
       shipping_type = LOWER(shipping_type),
       discount_applied = LOWER(discount_applied),
       promo_code_used = LOWER(promo_code_used),
       pay_method = LOWER(pay_method),
       purch_frequency = LOWER(purch_frequency);

-- Step 2: Verify binary fields
SELECT DISTINCT subscription_status, 
				discount_applied, 
                promo_code_used 
  FROM consumer_behavior.purchases 
 WHERE subscription_status NOT IN ('yes', 'no')
    OR discount_applied NOT IN ('yes', 'no')
    OR promo_code_used NOT IN ('yes', 'no');


-- Step 3: Verify numerical ranges
SELECT * 
  FROM consumer_behavior.purchases 
 WHERE age < 0 OR age > 120 
    OR purch_amount_usd < 0 
    OR review_rating < 1 OR review_rating > 5;

-- Step 4: Verify consistency in purch_frequency categories 
SELECT DISTINCT purch_frequency 
  FROM consumer_behavior.purchases;


-- Data Analysis 

-- Part 1: Customer Analysis

-- Step 1: Customer Regional Preferences 
SELECT location, 
       COUNT(*) AS total_purchases
  FROM consumer_behavior.purchases
 GROUP BY location
 ORDER BY total_purchases DESC;

-- Step 2: Effect of promo codes and discounts
SELECT discount_applied, 
	   promo_code_used, 
       COUNT(*) AS total_purchases, 
       AVG(purch_amount_usd) AS avg_purchase_amount
  FROM consumer_behavior.purchases
 GROUP BY discount_applied, promo_code_used
 ORDER BY total_purchases DESC;

-- Step 3: Liklihood of repeat customers after promo code is used
SELECT promo_code_used, 
       AVG(prev_purch) AS avg_previous_purchases,
       COUNT(*) AS total_customers
  FROM consumer_behavior.purchases
 GROUP BY promo_code_used
 ORDER BY avg_previous_purchases DESC;

-- Step 4: Subscription customers and purchase volume
SELECT 
    subscription_status, 
    AVG(purch_amount_usd) AS avg_purchase_amount, 
    AVG(prev_purch) AS avg_previous_purchases,
    SUM(purch_amount_usd) AS sales_revenue,
    (SUM(purch_amount_usd) * 100.0) / SUM(SUM(purch_amount_usd)) OVER () AS sales_rev_percentage
FROM consumer_behavior.purchases
GROUP BY subscription_status
ORDER BY avg_purchase_amount DESC;



-- Correlation between purchase frequency and purchase amount
SELECT purch_frequency, 
       AVG(purch_amount_usd) AS avg_purchase_amount, 
       COUNT(*) AS total_purchases
  FROM consumer_behavior.purchases
 GROUP BY purch_frequency
 ORDER BY avg_purchase_amount DESC;

-- Customer Demographics
SELECT age, 
       gender, 
       AVG(purch_amount_usd) AS avg_purchase_amount, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY age, gender
 ORDER BY avg_purchase_amount DESC;

-- Customer Demographics
SELECT age, 
       gender, 
	   AVG(purch_amount_usd) AS avg_purchase_amount, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY age, gender
 ORDER BY purchase_count DESC;

-- Subscription impact on purchase frequency
SELECT subscription_status, 
       purch_frequency, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY subscription_status, purch_frequency
 ORDER BY purchase_count DESC;

-- Subscription status and gender 
SELECT subscription_status, 
       gender, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY subscription_status, gender 
 ORDER BY purchase_count;

-- Avg previous purchases by purchase frequency 
SELECT purch_frequency, 
       AVG(prev_purch) AS avg_previous_purchases, 
       COUNT(*) AS total_customers
  FROM consumer_behavior.purchases
 GROUP BY purch_frequency
 ORDER BY avg_previous_purchases DESC;

-- Top customer categories 
  WITH RankedCustomers AS (
       SELECT cust_id,
              category,
              prev_purch,
              NTILE(10) OVER (ORDER BY prev_purch DESC) AS decile
	     FROM consumer_behavior.purchases
)
SELECT category, 
       COUNT(cust_id) AS top_repeat_customers
  FROM RankedCustomers
 WHERE decile = 1  
 GROUP BY category
 ORDER BY top_repeat_customers DESC;



-- Seasonality 
	-- Total sales by season 
SELECT season, 
       SUM(purch_amount_usd) AS total_sales
  FROM consumer_behavior.purchases
 GROUP BY season
 ORDER BY total_sales DESC;

	-- Average sales by season 
SELECT season, 
       AVG(purch_amount_usd) AS avg_sales
  FROM consumer_behavior.purchases
 GROUP BY season
 ORDER BY avg_sales DESC;

	-- Number of purchases by season 
SELECT season, 
       COUNT(*) AS total_purchases
  FROM consumer_behavior.purchases
 GROUP BY season
 ORDER BY total_purchases DESC;

	-- Sales by Season and Category 
SELECT season, 
       category, 
       SUM(purch_amount_usd) AS total_sales
  FROM consumer_behavior.purchases
 GROUP BY season, category
 ORDER BY season, total_sales DESC;


-- Part2: Product Analysis 

-- Most frequently bought items 
SELECT item_purch, 
	   COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY item_purch
 ORDER BY purchase_count DESC
 LIMIT 10;

-- Top selling items + size breakdown 
SELECT item_purch, 
       size, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY item_purch, size
 ORDER BY purchase_count DESC
 LIMIT 50;

-- Top selling categories 
SELECT category, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY category
 ORDER BY purchase_count DESC
 LIMIT 10;

-- Correlation between review rating and price 
SELECT review_rating, 
       AVG(purch_amount_usd) AS avg_price
  FROM consumer_behavior.purchases
 GROUP BY review_rating
 ORDER BY review_rating DESC;

-- Most popular colors by season 
SELECT season, 
       color, 
       COUNT(*) AS color_counthe 
  FROM consumer_behavior.purchases
 GROUP BY season, color
 ORDER BY season, color_count DESC;

-- Price range distribution of categories 
SELECT category, 
       MIN(purch_amount_usd) AS min_price, 
       AVG(purch_amount_usd) AS avg_price, 
       MAX(purch_amount_usd) AS max_price
  FROM consumer_behavior.purchases
 GROUP BY category
 ORDER BY avg_price DESC;

-- Seasonal trends for items purchased
SELECT season, 
       item_purch, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY season, item_purch
 ORDER BY season, purchase_count DESC;

-- Average review rating by category 
SELECT category, 
       AVG(review_rating) AS avg_review_rating
  FROM consumer_behavior.purchases
 GROUP BY category
 ORDER BY avg_review_rating DESC;

-- Popular colors by gender 
SELECT gender, 
       color, 
       COUNT(*) AS color_count
  FROM consumer_behavior.purchases
 GROUP BY gender, color
 ORDER BY gender, color_count DESC;

-- Popular categories by gender
SELECT gender, 
       category, 
       COUNT(*) AS category_count
  FROM consumer_behavior.purchases
 GROUP BY gender, category
 ORDER BY gender, category_count DESC;

-- Perferred sizes by gender 
SELECT gender, 
       size, 
       COUNT(*) AS size_count
  FROM consumer_behavior.purchases
 GROUP BY gender, size
 ORDER BY gender, size_count DESC;

-- Purchase frequency by gender 
SELECT gender, 
       purch_frequency, 
       COUNT(*) AS frequency_count
  FROM consumer_behavior.purchases
 GROUP BY gender, purch_frequency
 ORDER BY gender, frequency_count DESC;

-- Popular seasons by gender 
SELECT gender, 
       season, 
       COUNT(*) AS season_count
  FROM consumer_behavior.purchases
 GROUP BY gender, season
 ORDER BY gender, season_count DESC;

-- Top colors by categorys for each gender 
SELECT gender, 
       category, 
       color, 
       COUNT(*) AS color_count
  FROM consumer_behavior.purchases
 GROUP BY gender, category, color
 ORDER BY gender, category, color_count DESC;

-- Top sizes by seasons for each gender
SELECT gender, 
       season, 
       size, 
       COUNT(*) AS size_count
  FROM consumer_behavior.purchases
 GROUP BY gender, season, size
 ORDER BY gender, season, size_count DESC;

-- Avg purchase amount by category and gender 
SELECT gender, 
       category, 
       AVG(purch_amount_usd) AS avg_purchase_amount
  FROM consumer_behavior.purchases
 GROUP BY gender, category
 ORDER BY gender, avg_purchase_amount DESC;

-- Discount and promo code use by gender 
SELECT gender, 
       discount_applied, 
       promo_code_used, COUNT(*) AS usage_count
  FROM consumer_behavior.purchases
 GROUP BY gender, discount_applied, promo_code_used
 ORDER BY gender, usage_count DESC;

-- Subscription status by gender
SELECT gender, 
       subscription_status, 
       COUNT(*) AS subscription_count
  FROM consumer_behavior.purchases
 GROUP BY gender, subscription_status
 ORDER BY gender, subscription_count DESC;

SELECT 
    age, 
    gender, 
    CASE 
        -- Northeast States
        WHEN location IN ('connecticut', 'maine', 'massachusetts', 'new hampshire', 'rhode island', 'vermont', 'new jersey', 'new york', 'pennsylvania') THEN 'Northeast'
        
        -- South States
        WHEN location IN ('delaware', 'florida', 'georgia', 'maryland', 'north carolina', 'south carolina', 'virginia', 'west virginia', 'district of columbia', 
                          'alabama', 'kentucky', 'mississippi', 'tennessee', 'arkansas', 'louisiana', 'oklahoma', 'texas') THEN 'South'
        
        -- Midwest States
        WHEN location IN ('illinois', 'indiana', 'michigan', 'ohio', 'wisconsin', 'iowa', 'kansas', 'minnesota', 'missouri', 'nebraska', 'north dakota', 'south dakota') THEN 'Midwest'
        
        -- West States
        WHEN location IN ('alaska', 'arizona', 'california', 'colorado', 'hawaii', 'idaho', 'montana', 'nevada', 'new mexico', 'oregon', 'utah', 'washington', 'wyoming') THEN 'West'
        
        -- If the location doesn't match, label as 'Unknown' (optional)
        ELSE 'Unknown'
    END AS region,  
    AVG(purch_amount_usd) AS avg_purchase_amount, 
    COUNT(*) AS purchase_count
FROM consumer_behavior.purchases
GROUP BY age, gender, region
ORDER BY purchase_count, avg_purchase_amount DESC;

-- Purchase timing by gender 
SELECT gender, 
       season, 
       COUNT(*) AS season_purchase_count,
       AVG(purch_amount_usd) AS avg_purchase_amount
  FROM consumer_behavior.purchases
 GROUP BY gender, season
 ORDER BY gender, season_purchase_count DESC;

-- Repeat purchases by gender 
SELECT gender, 
	   AVG(prev_purch) AS avg_previous_purchases
  FROM consumer_behavior.purchases
 GROUP BY gender
 ORDER BY avg_previous_purchases DESC;

-- Price sensitivity by gender
SELECT gender, 
       discount_applied, 
       AVG(purch_amount_usd) AS avg_purchase_amount
  FROM consumer_behavior.purchases
 GROUP BY gender, discount_applied
 ORDER BY gender, avg_purchase_amount DESC;

-- Payment method preferences by gender 
SELECT gender, 
       pay_method, 
       COUNT(*) AS payment_method_count
  FROM consumer_behavior.purchases
 GROUP BY gender, pay_method
 ORDER BY gender, payment_method_count DESC;

-- Correlation between review ratings and purchase frequency by gender
SELECT gender, 
       purch_frequency, 
       AVG(review_rating) AS avg_review_rating
  FROM consumer_behavior.purchases
 GROUP BY gender, purch_frequency
 ORDER BY gender, avg_review_rating DESC;

-- Customer Lifetime Value analysis by gender 
  WITH TotalSalesVolume AS (
       SELECT SUM(purch_amount_usd) AS total_sales_volume
         FROM consumer_behavior.purchases
),
CategorySalesVolume AS (
       SELECT category, 
              SUM(purch_amount_usd) AS category_sales_volume, 
              AVG(purch_amount_usd) AS avg_price_per_category
         FROM consumer_behavior.purchases
        GROUP BY category
),
GlobalWeightedAvgPrice AS (
       SELECT SUM(c.avg_price_per_category * (c.category_sales_volume / t.total_sales_volume)) AS global_weighted_avg_price
         FROM CategorySalesVolume c
        CROSS JOIN TotalSalesVolume t
),
CustomerCLTV AS (
       SELECT p.cust_id, 
              p.gender, 
              p.prev_purch, 
              g.global_weighted_avg_price, 
              p.prev_purch * g.global_weighted_avg_price AS estimated_CLTV
         FROM consumer_behavior.purchases p
        CROSS JOIN GlobalWeightedAvgPrice g
)
SELECT cust_id, 
       gender,
       prev_purch, 
       global_weighted_avg_price, 
       estimated_CLTV
  FROM CustomerCLTV
 ORDER BY estimated_CLTV DESC;

-- Gender Based Segmentation w/ Window Funtions
  WITH GenderStats AS (
	   SELECT gender, 
              COUNT(*) AS total_purchases, 
              SUM(purch_amount_usd) AS total_revenue,
			  SUM(purch_amount_usd) * 1.0 / SUM(SUM(purch_amount_usd)) OVER () AS revenue_proportion,
              COUNT(*) * 1.0 / SUM(COUNT(*)) OVER () AS purchase_proportion
         FROM consumer_behavior.purchases
		GROUP BY gender
)
SELECT gender, 
       total_purchases, 
       total_revenue, 
       revenue_proportion, 
       purchase_proportion
  FROM GenderStats
 ORDER BY revenue_proportion DESC;

-- Revenue and avg spend by gender 
SELECT gender, 
       category, 
       SUM(purch_amount_usd) AS total_revenue, 
       AVG(purch_amount_usd) AS avg_spend_per_purchase,
       (SELECT AVG(purch_amount_usd) 
          FROM consumer_behavior.purchases p2 
         WHERE p2.gender = p1.gender) AS avg_gender_spend
  FROM consumer_behavior.purchases p1
 GROUP BY gender, category
 ORDER BY total_revenue DESC;

-- Rolling categoires over time 
SELECT gender, 
       category, 
       season, 
       SUM(purch_amount_usd) AS total_revenue,
	   ROW_NUMBER() OVER (PARTITION BY gender ORDER BY SUM(purch_amount_usd) DESC) AS revenue_rank
  FROM consumer_behavior.purchases
 GROUP BY gender, category, season
 ORDER BY gender, revenue_rank, total_revenue DESC;

-- Cross gender pair analysis 
SELECT p1.gender AS gender_1, 
       p2.gender AS gender_2, 
       p1.item_purch AS item_purchased, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases p1
  JOIN consumer_behavior.purchases p2
	   ON p1.item_purch = p2.item_purch 
       AND p1.cust_id <> p2.cust_id
       AND p1.gender = 'male' 
       AND p2.gender = 'female' 
 GROUP BY p1.gender, p2.gender, p1.item_purch
HAVING COUNT(*) > 10
 ORDER BY purchase_count DESC;

-- Cluster behavior analysis by purchase frequency
  WITH FrequencyBins AS (
       SELECT cust_id, 
              gender, 
              purch_frequency, 
              prev_purch,
              NTILE(4) OVER (PARTITION BY gender ORDER BY prev_purch DESC) AS frequency_quartile
         FROM consumer_behavior.purchases
)
SELECT gender, 
       frequency_quartile, 
       COUNT(*) AS customer_count, 
       AVG(prev_purch) AS avg_previous_purchases
  FROM FrequencyBins
 GROUP BY gender, frequency_quartile
 ORDER BY gender, frequency_quartile;

-- Multi-factor gender clustering 
SELECT gender, 
       category, 
       season, 
       discount_applied, 
       promo_code_used, 
       AVG(purch_amount_usd) AS avg_spending, 
       COUNT(*) AS purchase_count
  FROM consumer_behavior.purchases
 GROUP BY gender, category, season, discount_applied, promo_code_used
HAVING COUNT(*) > 10
 ORDER BY gender, purchase_count DESC;


-- Promotion strategy by gender 
SELECT gender,
       discount_applied,
       promo_code_used,
       COUNT(*) AS total_purchases,
       AVG(purch_amount_usd) AS avg_purchase_amount,
       SUM(purch_amount_usd) AS total_spent
  FROM consumer_behavior.purchases
 GROUP BY gender, discount_applied, promo_code_used
 ORDER BY gender, total_purchases DESC;

-- What men are buying with promocodes 
SELECT category,
       item_purch,
       COUNT(*) AS purchases_with_promo
  FROM consumer_behavior.purchases
 WHERE gender = 'male' AND promo_code_used = 'yes'
 GROUP BY category, item_purch
 ORDER BY purchases_with_promo DESC;

-- What women are buying without promo codes
SELECT category,
       item_purch,
       COUNT(*) AS purchases_without_promo
  FROM consumer_behavior.purchases
 WHERE gender = 'female' AND promo_code_used = 'no'
 GROUP BY category, item_purch
 ORDER BY purchases_without_promo DESC;

-- Idenfitying Promo Gaps: comparing genders
SELECT item_purch,
       SUM(CASE WHEN gender = 'male' AND promo_code_used = 'yes' THEN 1 ELSE 0 END) AS male_purchases_with_promo,
       SUM(CASE WHEN gender = 'female' AND promo_code_used = 'no' THEN 1 ELSE 0 END) AS female_purchases_without_promo
  FROM consumer_behavior.purchases
 GROUP BY item_purch
HAVING male_purchases_with_promo > 0 AND female_purchases_without_promo > 0
 ORDER BY female_purchases_without_promo DESC, male_purchases_with_promo DESC;

-- States with cash payments 
SELECT location AS state, 
	   COUNT(*) AS cash_payment_count
  FROM consumer_behavior.purchases
 WHERE pay_method = 'Cash'
 GROUP BY location
 ORDER BY cash_payment_count DESC;

-- % of male customers 
SELECT (COUNT(CASE WHEN gender = 'Male' THEN 1 END) * 100.0 / COUNT(*)) AS male_percentage
  FROM consumer_behavior.purchases;

-- Total sales revenue
SELECT SUM(purch_amount_usd) AS total_sales_revenue
  FROM consumer_behavior.purchases;

-- Total sales revenue by season
SELECT season,
       SUM(purch_amount_usd) AS total_sales_revenue
  FROM consumer_behavior.purchases
 GROUP BY season
 ORDER BY total_sales_revenue DESC;

-- Part 3: Women Promotion strategy 

-- Items purchased by women across seasons 
SELECT season,
       item_purch,
       COUNT(*) AS purchase_count,
       AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season, item_purch
 ORDER BY season, purchase_count DESC;

-- Items purchased by women by location
SELECT location,
       item_purch,
       COUNT(*) AS purchase_count,
       AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY location, item_purch
 ORDER BY location, purchase_count DESC;

-- Seasonal trends with frequency and spending analysis 
SELECT season,
       COUNT(*) AS total_purchases,
       AVG(purch_amount_usd) AS avg_spending,
       MAX(purch_amount_usd) AS max_spending,
       MIN(purch_amount_usd) AS min_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season
 ORDER BY total_purchases DESC;

-- Items purchased by women grouped by frequency
SELECT purch_frequency,
       item_purch,
       COUNT(*) AS purchase_count,
       AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY purch_frequency, item_purch
 ORDER BY purch_frequency, purchase_count DESC;

-- Probability of item purchase in each season
  WITH TotalPurchasesBySeason AS (
       SELECT season,
              COUNT(*) AS total_season_purchases
         FROM consumer_behavior.purchases
        WHERE gender = 'female'
        GROUP BY season
),
ItemPurchaseProbability AS (
       SELECT p.season,
              p.item_purch,
              COUNT(*) AS item_purchase_count,
              t.total_season_purchases,
              COUNT(*) * 1.0 / t.total_season_purchases AS purchase_probability
         FROM consumer_behavior.purchases p
         JOIN TotalPurchasesBySeason t ON p.season = t.season
		WHERE p.gender = 'female'
        GROUP BY p.season, p.item_purch, t.total_season_purchases
)
SELECT season,
       item_purch,
       item_purchase_count,
       total_season_purchases,
       purchase_probability
  FROM ItemPurchaseProbability
 ORDER BY season, purchase_probability DESC;

-- Location and seasonal correlation
SELECT season,
       location,
       COUNT(*) AS purchase_count,
       AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season, location
 ORDER BY season, purchase_count DESC;

-- Projecting promo code usage 
SELECT category,
       COUNT(*) AS total_purchases,
       AVG(purch_amount_usd) AS avg_spending,
       MAX(purch_amount_usd) AS max_spending,
       MIN(purch_amount_usd) AS min_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY category
 ORDER BY total_purchases DESC;
 
-- Colors and items bought by female customers each season 
SELECT season,
	   color,
	   item_purch,
	   COUNT(*) AS purchase_count,
	   AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season, color, item_purch
 ORDER BY season, purchase_count DESC;

-- Items bought by female customers by season 
SELECT season,
	   item_purch,
	   COUNT(*) AS purchase_count,
	   AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season, item_purch
 ORDER BY season, purchase_count DESC;

-- Colors by season for female customers 
SELECT season,
	   color,
	   COUNT(*) AS purchase_count,
	   AVG(purch_amount_usd) AS avg_spending
  FROM consumer_behavior.purchases
 WHERE gender = 'female'
 GROUP BY season, color
 ORDER BY season, purchase_count DESC;
 
 -- Popular items by season with gender cross-over appeal 
WITH GenderPopularity AS (
    SELECT 
        gender,
        season,
        item_purch,
        COUNT(*) AS purchase_count
    FROM consumer_behavior.purchases
    GROUP BY gender, season, item_purch
)
SELECT 
    gp_m.season,
    gp_m.item_purch,
    gp_m.purchase_count AS male_purchase_count,
    gp_f.purchase_count AS female_purchase_count
FROM GenderPopularity gp_m
JOIN GenderPopularity gp_f
    ON gp_m.item_purch = gp_f.item_purch
    AND gp_m.season = gp_f.season
WHERE gp_m.gender = 'male' AND gp_f.gender = 'female'
ORDER BY gp_m.season, (gp_m.purchase_count + gp_f.purchase_count) DESC;

-- purchase volume by shipping type
SELECT 
    shipping_type,
    COUNT(*) AS purchase_count,
    AVG(purch_amount_usd) AS avg_spending
FROM consumer_behavior.purchases
WHERE pay_method = 'cash'
GROUP BY shipping_type
ORDER BY purchase_count DESC;

-- promo/discount use by subscription status
SELECT 
    subscription_status,
    promo_code_used,
    discount_applied,
    COUNT(*) AS purchase_count,
    AVG(purch_amount_usd) AS avg_spending
FROM consumer_behavior.purchases
WHERE promo_code_used = 'yes' AND discount_applied = 'yes'
GROUP BY subscription_status, promo_code_used, discount_applied
ORDER BY subscription_status DESC, purchase_count DESC;

-- Subscriber vs Non-Subscriber metrics 
SELECT 
    subscription_status,
    COUNT(*) AS customer_count,
    AVG(prev_purch) AS avg_previous_purchases,
    MAX(prev_purch) AS max_previous_purchases,
    MIN(prev_purch) AS min_previous_purchases
FROM consumer_behavior.purchases
GROUP BY subscription_status
ORDER BY avg_previous_purchases DESC;

-- iteem purchase quanitity by gender
SELECT 
    gender,
    item_purch,
    COUNT(*) AS purchase_count
FROM consumer_behavior.purchases
GROUP BY gender, item_purch
ORDER BY purchase_count DESC;

-- Item purchase proportion within gender sales 
WITH TotalPurchasesByGender AS (
    SELECT 
        gender,
        COUNT(*) AS total_gender_purchases
    FROM consumer_behavior.purchases
    GROUP BY gender
)
SELECT 
    p.gender,
    p.item_purch,
    COUNT(*) AS item_purchase_count,
    tg.total_gender_purchases,
    (COUNT(*) * 100.0 / tg.total_gender_purchases) AS purchase_proportion
FROM consumer_behavior.purchases p
JOIN TotalPurchasesByGender tg
    ON p.gender = tg.gender
GROUP BY p.gender, p.item_purch, tg.total_gender_purchases
ORDER BY purchase_proportion DESC;

-- Purchase porportions of items for male customers
WITH TotalMalePurchases AS (
    SELECT 
        COUNT(*) AS total_male_purchases
    FROM consumer_behavior.purchases
    WHERE gender = 'male'
)
SELECT 
    item_purch,
    COUNT(*) AS male_item_purchase_count,
    tm.total_male_purchases,
    (COUNT(*) * 100.0 / tm.total_male_purchases) AS male_purchase_proportion
FROM consumer_behavior.purchases p
JOIN TotalMalePurchases tm
    ON 1 = 1 
WHERE p.gender = 'male'
GROUP BY item_purch, tm.total_male_purchases
ORDER BY male_purchase_proportion DESC;

-- purchase proportions of items for female customers
WITH TotalFemalePurchases AS (
    SELECT 
        COUNT(*) AS total_female_purchases
    FROM consumer_behavior.purchases
    WHERE gender = 'female'
)
SELECT 
    item_purch,
    COUNT(*) AS female_item_purchase_count,
    tf.total_female_purchases,
    (COUNT(*) * 100.0 / tf.total_female_purchases) AS female_purchase_proportion
FROM consumer_behavior.purchases p
JOIN TotalFemalePurchases tf
    ON 1 = 1 
WHERE p.gender = 'female'
GROUP BY item_purch, tf.total_female_purchases
ORDER BY female_purchase_proportion DESC;
-- (maybe redundant - check lines 730-747) Item purchase proportion within gender sales
WITH TotalSalesByGender AS (
    SELECT 
        gender,
        COUNT(*) AS total_gender_sales
    FROM consumer_behavior.purchases
    GROUP BY gender
),
ItemSalesProportion AS (
    SELECT 
        p.gender,
        p.item_purch,
        COUNT(*) AS item_sales_count,
        tg.total_gender_sales,
        (COUNT(*) * 1.0 / tg.total_gender_sales) AS proportion_of_sales
    FROM consumer_behavior.purchases p
    JOIN TotalSalesByGender tg
        ON p.gender = tg.gender
    GROUP BY p.gender, p.item_purch, tg.total_gender_sales
)
SELECT 
    gender,
    item_purch,
    proportion_of_sales
FROM ItemSalesProportion
ORDER BY gender;

-- General CLTV Analysis 
WITH AvgPurchasePrice AS (
    SELECT 
        cust_id,
        AVG(purch_amount_usd) AS avg_purchase_price
    FROM consumer_behavior.purchases
    GROUP BY cust_id
),
CLTVCalculation AS (
    SELECT 
        p.cust_id,
        ap.avg_purchase_price,
        p.prev_purch,
        (ap.avg_purchase_price * p.prev_purch) AS cltv
    FROM consumer_behavior.purchases p
    JOIN AvgPurchasePrice ap
        ON p.cust_id = ap.cust_id
)
SELECT 
    p.cust_id,
    p.age,
    c.cltv
FROM consumer_behavior.purchases p
JOIN CLTVCalculation c
    ON p.cust_id = c.cust_id
ORDER BY cust_id;

-- subscription and purchase frequency by purchase count
SELECT 
    subscription_status,
    purch_frequency,
    COUNT(*) AS purch_count
FROM consumer_behavior.purchases
GROUP BY subscription_status, purch_frequency
ORDER BY purch_count DESC;

-- CLTV with everything 
  WITH TotalSalesVolume AS (
       SELECT SUM(purch_amount_usd) AS total_sales_volume
         FROM consumer_behavior.purchases
),
CategorySalesVolume AS (
       SELECT category, 
              SUM(purch_amount_usd) AS category_sales_volume, 
              AVG(purch_amount_usd) AS avg_price_per_category
         FROM consumer_behavior.purchases
        GROUP BY category
),
GlobalWeightedAvgPrice AS (
       SELECT SUM(c.avg_price_per_category * (c.category_sales_volume / t.total_sales_volume)) AS global_weighted_avg_price
         FROM CategorySalesVolume c
        CROSS JOIN TotalSalesVolume t
),
CustomerCLTV AS (
   SELECT p.cust_id, 
          p.subscription_status, 
          p.gender, 
          p.age,
          p.location,
          p.prev_purch,
          p.item_purch,
          g.global_weighted_avg_price, 
          p.prev_purch * g.global_weighted_avg_price + purch_amount_usd AS est_cltv
   FROM consumer_behavior.purchases p
   CROSS JOIN GlobalWeightedAvgPrice g
)
SELECT 
    cust_id,
    subscription_status,
    gender,
    age,
    location,
    prev_purch,
    item_purch,
    ROUND(est_cltv, 2) AS estimate_cltv
FROM CustomerCLTV
ORDER BY estimate_cltv DESC;


