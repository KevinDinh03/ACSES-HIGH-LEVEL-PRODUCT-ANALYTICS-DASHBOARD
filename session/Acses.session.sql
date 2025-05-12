
/*
The purpose for this step is to aggregate and manipulate the three datasets so that insightful
data can be explored within a dataset. The result for this step is to extract a csv file of the
final dataset that can help to visualise key product metrics, helping to answer the business 
questions of the task.

1) Loading the data
- I will load the CSV files into tables within the local Postgressql database.
- Because everything is done in VSCode without any built-in functions, Iwill have to 
create the tables first then I will use the copy function to input the data in the CSV file 
in there. */

--Create discount_data table and copy its dataset
CREATE TABLE discount_data (
    "Month" VARCHAR(50),
    "Discount_Band" VARCHAR(50),
    "Discount" INT
);

COPY discount_data
FROM '/Users/xuanquyetdinh/Desktop/Data Analysis Project November 2024 - Copy/discount_data.csv' 
DELIMITER ',' 
CSV HEADER;


--Create product_data table and copy its dataset
CREATE TABLE product_data (
    "Product_ID" VARCHAR(50),
    "Product" VARCHAR(50),
    "Category" VARCHAR(50),
    "Cost_Price" MONEY,
    "Sale_Price" MONEY,
    "Brand" VARCHAR(50),
    "Description" VARCHAR(250),
    "Image_url" VARCHAR(100)
);

COPY product_data
FROM '/Users/xuanquyetdinh/Desktop/Data Analysis Project November 2024 - Copy/Product_data.csv'
DELIMITER ','
CSV HEADER ENCODING 'WIN1252';



--Create product_sales table and copy its dataset 
/*Because the Date format in CSV is in "DD-MM-YYYY", storing the data directly as Date will 
cause the database to recognise it as "MM-DD-YYYY". So extra steps is needed to convert it to
the right format*/

CREATE TABLE product_sales_temp (
    "Date" TEXT,
    "Customer_Type" VARCHAR(50),
    "Country" VARCHAR(50),
    "Product" VARCHAR(50),
    "Discount_Band" VARCHAR(50),
    "Units_Sold" INT
);

COPY product_sales_temp
FROM '/Users/xuanquyetdinh/Desktop/Data Analysis Project November 2024 - Copy/product_sales.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE product_sales (
    "Date" DATE,
    "Customer_Type" VARCHAR(50),
    "Country" VARCHAR(50),
    "Product" VARCHAR(50),
    "Discount_Band" VARCHAR(50),
    "Units_Sold" INT
);

INSERT INTO product_sales ("Date", "Customer_Type", "Country", "Product", "Discount_Band",
"Units_Sold")
SELECT 
TO_DATE("Date", 'DD-MM-YYYY'),
"Customer_Type",
"Country",
"Product",
"Discount_Band",
"Units_Sold"
FROM product_sales_temp



/* 2) Now I will query our datasets to generate our desire result*/

--I will observe the full datasets --

Select * from product_data;

Select * from product_sales;

Select * from discount_data;

--Start developing the queries --

/* 
- Firstly, I will join two tables - "product_data" and "product_sales" - based on the Product_ID
from the product_data table and Product from the "product_sales" table. 

- Then, I will create two columns - Revenue and Total_cost - to gain some more insights from
these data

- Next, I will extract two extra columns - Month and Year - So that Ican join the aggregated
dataset with "discount_data" table 

- To make sure that the further joins are easier, I will store it as a 
Common Table Expression (CTE) using the With functions*/
WITH cte as(
SELECT     
pd."Product",
pd."Category",
pd."Cost_Price",
pd."Sale_Price",
pd."Brand",
pd."Description",
pd."Image_url",
ps."Date",
ps."Customer_Type",
ps."Country",
ps."Discount_Band",
ps."Units_Sold",
"Sale_Price" * "Units_Sold" as "Revenue",
"Cost_Price" * "Units_Sold" as "Total_cost",
TRIM(TO_CHAR("Date", 'Month')) as "Month",
TRIM(TO_CHAR("Date", 'YYYY')) as "Year"
FROM product_data pd
JOIN product_sales ps
ON pd."Product_ID" = ps."Product")

SELECT *, (1 - "Discount"*1.0/100) * "Revenue" AS "Discounted_Revenue"
FROM cte c
JOIN discount_data d
ON LOWER(c."Month") = LOWER(d."Month")
and LOWER(TRIM(c."Discount_Band")) = LOWER(TRIM(d."Discount_Band"))

/* 
- After cte has completed,I joined the "discount_data" with cte based on the "Month" columns
and the "Discount_Band" columns. I make sure that the join columns are normalised so that the
progress can be done seamlessly.
- After join the two tables, I added a Discounted_Revenue column to update the revenue after
discount for the products. After this step, the dataset is ready for further visualisations"
















