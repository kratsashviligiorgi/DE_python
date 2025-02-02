--Calculate the total sales amount and the total number of transactions for each month.
--calculating data for sales in time analysis
SELECT YEAR(ST.purchase_date) as date_year,
	   DATENAME(MONTH, DATEFROMPARTS(2024, MONTH(ST.purchase_date), 1)) AS date_month,
	   COUNT(ST.transaction_ID) as amount_of_transactions,
	   SUM(PP.price*ST.quantity) as total_sales
FROM Sales.sales_transactions (NOLOCK) ST
LEFT JOIN Product.products (NOLOCK) PP
  ON PP.product_ID = ST.product_ID
GROUP BY YEAR(ST.purchase_date),MONTH(ST.purchase_date)
ORDER BY YEAR(ST.purchase_date),MONTH(ST.purchase_date);

--calculating data for months productivity analysis

SELECT DATENAME(MONTH, DATEFROMPARTS(2024, MONTH(ST.purchase_date), 1)) AS date_month,
	   COUNT(ST.transaction_ID) as amount_of_transactions,
	   SUM(PP.price*ST.quantity) as total_sales
FROM Sales.sales_transactions (NOLOCK) ST
LEFT JOIN Product.products (NOLOCK) PP
  ON PP.product_ID = ST.product_ID
GROUP BY MONTH(ST.purchase_date)
ORDER BY MONTH(ST.purchase_date);


--Calculate the 3-month moving average of sales amount for each month. The moving
--average should be calculated based on the sales data from the previous 3 months
--(including the current month).WITH Monthly_Sales AS (
    SELECT
        YEAR(ST.purchase_date) AS date_year,
        MONTH(ST.purchase_date) AS date_month,
        SUM(ST.quantity*PP.price) AS monthly_sales_amount
    FROM Sales.sales_transactions (NOLOCK) ST
	LEFT JOIN Product.products (NOLOCK) PP
	  ON PP.product_ID = ST.product_ID
    GROUP BY YEAR(ST.purchase_date), MONTH(ST.purchase_date)
)
SELECT
    date_year,
    DATENAME(MONTH, DATEFROMPARTS(date_year, date_month, 1)) as date_name_month,
    monthly_sales_amount,
    AVG(monthly_sales_amount) OVER (
        ORDER BY date_year, date_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average_3m
FROM Monthly_Sales
ORDER BY date_year, date_month;
