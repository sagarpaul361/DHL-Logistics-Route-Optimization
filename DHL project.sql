show tables;
DESCRIBE orders;
ALTER TABLE orders
CHANGE COLUMN `ï»¿Order_ID` Order_ID TEXT;
SHOW CREATE TABLE orders;
DESCRIBE orders;
SELECT Order_ID, COUNT(*) AS duplicate_count
FROM orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;

DESCRIBE shipments;
DESCRIBE routes;
DESCRIBE warehouses;
DESCRIBE delivery_agents;
SHOW COLUMNS FROM shipments;
ALTER TABLE shipments
CHANGE COLUMN `ï»¿Shipment_ID` Shipment_ID TEXT;
SHOW COLUMNS FROM routes;
ALTER TABLE routes
CHANGE COLUMN `ï»¿Route_ID` Route_ID TEXT;
SHOW COLUMNS FROM warehouses;
ALTER TABLE warehouses
CHANGE COLUMN `ï»¿Warehouse_ID` Warehouse_ID TEXT;
ALTER TABLE delivery_agents
CHANGE COLUMN `ï»¿Agent_ID` Agent_ID TEXT;

SELECT Shipment_ID, COUNT(*)
FROM shipments
GROUP BY Shipment_ID
HAVING COUNT(*) > 1;
SELECT *
FROM shipments
WHERE Delay_Hours IS NULL;
UPDATE shipments s
JOIN (
    SELECT Route_ID,
           AVG(Delay_Hours) AS avg_delay
    FROM shipments
    WHERE Delay_Hours IS NOT NULL
    GROUP BY Route_ID
) r
ON s.Route_ID = r.Route_ID
SET s.Delay_Hours = r.avg_delay
WHERE s.Delay_Hours IS NULL;
SELECT *
FROM shipments
WHERE Delivery_Date < Pickup_Date;

SELECT o.Order_ID
FROM orders o
LEFT JOIN routes r
ON o.Route_ID = r.Route_ID
WHERE r.Route_ID IS NULL;
SELECT o.Order_ID
FROM orders o
LEFT JOIN warehouses w
ON o.Warehouse_ID = w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL;
SELECT s.Shipment_ID
FROM shipments s
LEFT JOIN orders o
ON s.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;
DESCRIBE orders;
DESCRIBE shipments;
SELECT Order_Date
FROM orders
LIMIT 5;

SELECT
    Shipment_ID,
    Order_ID,
    Pickup_Date,
    Delivery_Date,
    ROUND(TIMESTAMPDIFF(MINUTE, Pickup_Date, Delivery_Date)/60,2) AS Actual_Delay_Hours
FROM shipments;

SELECT
    Route_ID,
    ROUND(AVG(Delay_Hours),2) AS Avg_Delay
FROM shipments
GROUP BY Route_ID
ORDER BY Avg_Delay DESC
LIMIT 10;

SELECT
    Shipment_ID,
    Warehouse_ID,
    Delay_Hours,
    RANK() OVER (
        PARTITION BY Warehouse_ID
        ORDER BY Delay_Hours DESC
    ) AS Delay_Rank
FROM shipments;

SELECT
    o.Delivery_Type,
    ROUND(AVG(s.Delay_Hours),2) AS Average_Delay
FROM orders o
INNER JOIN shipments s
ON TRIM(o.Order_ID) = TRIM(s.Order_ID)
GROUP BY o.Delivery_Type;

-- task 3
-- average transit time per route-- 

SELECT
    Route_ID,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)),2) AS Avg_Transit_Hours
FROM shipments
GROUP BY Route_ID;
-- average delay per route 
SELECT
    Route_ID,
    ROUND(AVG(Delay_Hours),2) AS Avg_Delay
FROM shipments
GROUP BY Route_ID
ORDER BY Avg_Delay DESC;
-- Distance-to-Time Efficiency Ratio
SELECT
    Route_ID,
    Distance_KM,
    Avg_Transit_Time_Hours,
    ROUND(Distance_KM / Avg_Transit_Time_Hours,2) AS Efficiency_Ratio
FROM routes;

-- Worst 3 Routes (Lowest Efficiency)
SELECT
    Route_ID,
    Distance_KM,
    Avg_Transit_Time_Hours,
    ROUND(Distance_KM / Avg_Transit_Time_Hours,2) AS Efficiency_Ratio
FROM routes
ORDER BY Efficiency_Ratio ASC
LIMIT 3;
-- Routes with More Than 20% Delayed Shipments
SELECT
    s.Route_ID,
    COUNT(*) AS Total_Shipments,
    SUM(CASE WHEN TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) > r.Avg_Transit_Time_Hours
	THEN 1 ELSE 0 END) AS Delayed_Shipments, 
    ROUND(
        SUM(CASE WHEN TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) > r.Avg_Transit_Time_Hours
         THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Delay_Percentage FROM shipments s
JOIN routes r ON s.Route_ID = r.Route_ID GROUP BY s.Route_ID HAVING Delay_Percentage > 20;

-- task 4 
-- Top 3 Warehouses with Highest Average Delay-- 
SELECT
    Warehouse_ID,
    ROUND(AVG(Delay_Hours),2) AS Avg_Delay
FROM shipments
GROUP BY Warehouse_ID
ORDER BY Avg_Delay DESC
LIMIT 3;
-- Total vs Delayed Shipments-- 
 
SELECT
    Warehouse_ID,
    COUNT(*) AS Total_Shipments,
    SUM(CASE WHEN Delay_Hours > 0 THEN 1 ELSE 0 END) AS Delayed_Shipments
FROM shipments
GROUP BY Warehouse_ID;

-- Warehouses Above Global Average Delay (CTE)-- 
 WITH warehouse_delay AS (
SELECT Warehouse_ID, AVG(Delay_Hours) AS Avg_Delay
    FROM shipments GROUP BY Warehouse_ID),
global_avg AS (SELECT AVG(Delay_Hours) AS Overall_Avg FROM shipments)
SELECT wd.Warehouse_ID, ROUND(wd.Avg_Delay,2) AS Avg_Delay
FROM warehouse_delay wd CROSS JOIN global_avg g
WHERE wd.Avg_Delay > g.Overall_Avg;

-- Rank Warehouses by On-Time Delivery %-- 
SELECT
    Warehouse_ID,
    ROUND(
        SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS On_Time_Percentage,
    RANK() OVER (
        ORDER BY
        SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
    ) AS Warehouse_Rank
FROM shipments
GROUP BY Warehouse_ID;

-- task 5 
-- Rank Delivery Agents (Per Route) by On-Time Delivery %
SELECT s.Route_ID, s.Agent_ID,
    ROUND(
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2
    ) AS On_Time_Percentage,
    RANK() OVER ( PARTITION BY s.Route_ID ORDER BY
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
    ) AS Agent_Rank
FROM shipments s GROUP BY s.Route_ID, s.Agent_ID;

-- Agents with On-Time % Below 85%
SELECT
    s.Agent_ID,
    ROUND(
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS On_Time_Percentage
FROM shipments s
GROUP BY s.Agent_ID
HAVING On_Time_Percentage < 85; 

-- Compare Top 5 vs Bottom 5 Agents
(SELECT
    'Top 5 Agents' AS Category,
    ROUND(AVG(Avg_Rating),2) AS Avg_Rating,
    ROUND(AVG(Experience_Years),2) AS Avg_Experience
FROM ( SELECT * FROM delivery_agents
    ORDER BY Avg_Rating DESC LIMIT 5) t )
UNION ALL
(
SELECT
    'Bottom 5 Agents',
    ROUND(AVG(Avg_Rating),2), ROUND(AVG(Experience_Years),2)
FROM (
    SELECT * FROM delivery_agents ORDER BY Avg_Rating ASC LIMIT 5
) b );

-- Provide additional training to agents with on-time delivery below 85%.
-- Balance workload among delivery agents.
-- Reward high-performing agents.
-- Monitor routes assigned to low-performing agents.


-- task 6 Shipment Tracking Analytics
-- Latest Shipment Status 
SELECT
    Shipment_ID,
    Delivery_Status,
    Delivery_Date
FROM shipments
ORDER BY Delivery_Date DESC;

-- Routes with Majority of Shipments In Transit or Returned
SELECT
    Route_ID,
    Delivery_Status,
    COUNT(*) AS Total_Shipments
FROM shipments
WHERE Delivery_Status IN ('In Transit','Returned')
GROUP BY Route_ID, Delivery_Status
ORDER BY Total_Shipments DESC;

-- Most Frequent Delay Reasons
SELECT
    Delay_Reason,
    COUNT(*) AS Frequency
FROM shipments
GROUP BY Delay_Reason
ORDER BY Frequency DESC;


-- Orders with Delay > 120 Hours
SELECT
    Shipment_ID,
    Order_ID,
    Delay_Hours
FROM shipments
WHERE Delay_Hours > 120
ORDER BY Delay_Hours DESC;

-- Task 7 – Advanced KPI Reporting

SELECT
    r.Source_Country,
    ROUND(AVG(s.Delay_Hours),2) AS Average_Delay
FROM shipments s
JOIN routes r
ON s.Route_ID = r.Route_ID
GROUP BY r.Source_Country;

-- On-Time Delivery Percentage
SELECT
ROUND(
SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END)
*100.0/COUNT(*),2
) AS On_Time_Delivery_Percentage
FROM shipments;

-- Average Delay per Route
SELECT
Route_ID,
ROUND(AVG(Delay_Hours),2) AS Average_Delay
FROM shipments
GROUP BY Route_ID;

-- Warehouse Utilization %

SELECT
w.Warehouse_ID,
w.Capacity_per_day,
COUNT(s.Shipment_ID) AS Shipments_Handled,
ROUND(
COUNT(s.Shipment_ID)*100.0/
w.Capacity_per_day,2
) AS Utilization_Percentage
FROM warehouses w
JOIN shipments s
ON w.Warehouse_ID=s.Warehouse_ID
GROUP BY
w.Warehouse_ID,
w.Capacity_per_day;
