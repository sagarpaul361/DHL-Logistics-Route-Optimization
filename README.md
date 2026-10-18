# 🚚 DHL Logistics Optimization for Delivery Routes | SQL Project

## 📌 Project Overview

This project focuses on analyzing logistics and delivery operations using MySQL. It explores shipment delays, route efficiency, warehouse performance, delivery agent productivity, and shipment tracking to support data-driven operational decisions.

## 🎯 Project Objectives

- Analyze shipment delays and transit times across delivery routes.
- Identify routes with high delays and low delivery efficiency.
- Evaluate warehouse performance using delay and on-time delivery metrics.
- Rank delivery agents by on-time delivery performance.
- Analyze shipment status and delivery timelines.
- Generate insights to support logistics optimization.

## 🛠️ Tools & Technologies

- MySQL
- SQL
- Joins and Aggregate Functions
- Common Table Expressions (CTEs)
- Window Functions: RANK()
- CASE Statements
- Data Cleaning and Data Quality Checks
- Date and Time Analysis

## 📊 Analysis Performed

### 1. Data Quality Checks
- Checked for duplicate order and shipment IDs.
- Identified missing shipment delay values.
- Checked delivery and pickup dates.
- Validated relationships between orders, routes, warehouses, and shipments.

### 2. Route Performance Analysis
- Calculated average transit time and delay by route.
- Identified routes with the lowest distance-to-time efficiency.
- Analyzed routes with higher delayed-shipment percentages.

### 3. Warehouse Performance
- Identified warehouses with the highest average delays.
- Compared total and delayed shipments.
- Calculated on-time delivery percentages.
- Ranked warehouses using SQL window functions.

### 4. Delivery Agent Analysis
- Ranked delivery agents by on-time delivery percentage within each route.
- Identified agents with on-time delivery below 85%.
- Compared ratings and experience between top- and bottom-rated agents.

### 5. Shipment Tracking
- Retrieved shipment status and delivery dates.
- Calculated actual elapsed time between pickup and delivery.

## 💡 Business Recommendations

- Investigate routes with consistently high delivery delays.
- Monitor warehouses with lower on-time delivery performance.
- Provide targeted training and support to underperforming delivery agents.
- Recognize high-performing agents and review workload distribution.
- Monitor shipment timelines to identify operational bottlenecks.

## 📁 Project Files

- `DHL project.sql` — SQL queries used for data checks and logistics analysis.
- `DHL_Logistics_Route_Optimization.pptx` — Project presentation.

## 🚀 How to Use

1. Open MySQL Workbench.
2. Import the required project dataset and prepare the relevant tables.
3. Open `DHL project.sql`.
4. Execute the queries after verifying table names and column definitions.
5. Review the outputs to analyze delivery and logistics performance.

## 👨‍💻 Author

**Sagar**

Aspiring Data Analyst | Machine Learning Enthusiast

GitHub: [sagarpaul361](https://github.com/sagarpaul361)
