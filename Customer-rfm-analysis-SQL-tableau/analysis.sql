
#  MERGE TABLES INTO ONE SALES TABLE.

CREATE TABLE sales_2025 AS
SELECT * FROM sales2025_01
UNION ALL SELECT * FROM sales2025_02
UNION ALL SELECT * FROM sales2025_03
UNION ALL SELECT * FROM sales2025_04
UNION ALL SELECT * FROM sales2025_05
UNION ALL SELECT * FROM sales2025_06
UNION ALL SELECT * FROM sales2025_07
UNION ALL SELECT * FROM sales2025_08
UNION ALL SELECT * FROM sales2025_09
UNION ALL SELECT * FROM sales2025_10
UNION ALL SELECT * FROM sales2025_11
UNION ALL SELECT * FROM sales2025_12;

# CALCULATE RFM AND ASSIGN RANKS

CREATE VIEW sales2025_metrics AS
SELECT
    customer_id,
    MAX(orderDate) AS last_order_date,
    DATEDIFF('2026-04-15', MAX(orderDate)) AS recency,
    COUNT(*) AS frequency,
    SUM(OrderValue) AS monetary,
    ROW_NUMBER() OVER(
        ORDER BY DATEDIFF('2026-04-15', MAX(orderDate))
    ) AS r_rank,
    ROW_NUMBER() OVER(
        ORDER BY  COUNT(*)
    ) AS f_rank,
    ROW_NUMBER() OVER(
        ORDER BY SUM(OrderValue)
    ) AS m_rank
FROM sales_2025
GROUP BY customer_id;

####3
SELECT * FROM sales2025_metrics;

###3.1-Assigning Deciles

CREATE VIEW sales2025_scores AS
SELECT 
customer_id,
recency,
frequency,
monetary,
NTILE(10) OVER(ORDER BY r_rank DESC) AS r_score,
NTILE(10) OVER(ORDER BY f_rank DESC) AS f_score,
NTILE(10) OVER(ORDER BY m_rank DESC) AS m_score
FROM sales2025_metrics;

##3=results
SELECT * FROM sales2025_scores;

##4 ASSIGNING TOTAL SCORE
CREATE VIEW sales2025_total_scores AS
SELECT 
customer_id,
recency,
frequency,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) AS total_score
FROM sales2025_scores;

## 4 results
SELECT * FROM sales2025_total_scores;

##5 ASSIGNING SEGMENTS

CREATE VIEW sales2025_total_scores2 AS
SELECT 
customer_id,
recency,
frequency,
monetary,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) AS total_score
FROM sales2025_scores;
##

##ASSIGNING SEGMENTS
CREATE TABLE sales2025_segments AS
SELECT 
customer_id,
recency,
frequency,
monetary,
r_score,
f_score,
m_score,
total_score,
CASE
WHEN total_score >= 25 THEN 'champions'
WHEN total_score >= 20 THEN 'loyal VIPs'
WHEN total_score >= 15 THEN 'Potential loyalists'
WHEN total_score >= 10 THEN 'Engaged'
WHEN total_score >= 5 THEN 'at risk'
ELSE 'lost/inactive'
END AS rfm_segment
FROM sales2025_total_scores2
ORDER BY total_score;


#finalize fro visulization

SELECT * FROM sales2025_segments