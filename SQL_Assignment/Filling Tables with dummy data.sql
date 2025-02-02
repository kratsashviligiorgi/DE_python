--Customers Dummy Data
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Customer.customers (customer_ID,customer_name, email_address, country)
    VALUES 
    (	@i,
        'Customer' + CAST(@i AS VARCHAR(3)),
        'customer' + CAST(@i AS VARCHAR(3)) + '@example.com',
        CASE WHEN @i % 2 = 0 THEN 'Georgia' ELSE 'Sweden' END 
    );
    SET @i = @i + 1;
END;
GO

--Products Dummy Data
DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    INSERT INTO Product.products (product_ID,product_name, price, category)
    VALUES 
    (	@i,
        'Product' + CAST(@i AS VARCHAR(2)),
        ROUND(RAND() * (1000 - 100) + 10, 2),
        CASE 
            WHEN @i % 4 = 0 THEN 'Electronics'
            WHEN @i % 4 = 1 THEN 'Clothing'
			WHEN @i % 4 = 2 THEN 'Sports'
            ELSE 'Home Goods' 
        END  
    );
    SET @i = @i + 1;
END;
GO

--Transactions Dummy Data
DECLARE @i INT = 1;
DECLARE @start_date DATE = '2024-01-01'; 
DECLARE @end_date DATE = '2024-12-31'; 


WHILE @i <= 1000
BEGIN
    INSERT INTO Sales.sales_transactions (transaction_ID, customer_ID, product_ID, purchase_date, quantity)
    VALUES 
    (
        @i,  
        FLOOR(RAND() * 100) + 1, 
        FLOOR(RAND() * 50) + 1,  
        DATEADD(DAY, FLOOR(RAND() * DATEDIFF(DAY, @start_date, @end_date)), @start_date),
        FLOOR(RAND() * 5) + 1 
    );
    SET @i = @i + 1;
END;
GO

--Shipment Dummy Data
DECLARE @i INT = 1;

WHILE @i <= 1000
BEGIN
    DECLARE @transaction_date DATE;
    
    SELECT @transaction_date = purchase_date
    FROM Sales.sales_transactions 
    WHERE transaction_ID = @i;

	DECLARE @customer_country VARCHAR(100);

	SELECT @customer_country = CC.country 
	FROM Sales.sales_transactions ST
	LEFT JOIN Customer.customers CC
	  ON CC.customer_ID = ST.customer_ID
	WHERE ST.transaction_ID = @i
    
    INSERT INTO Sales.shipping_details (shipping_ID,transaction_ID, shipping_date, shipping_address, city, country)
    VALUES 
    (	@i,
        @i, 
        DATEADD(DAY, FLOOR(RAND() * 7) + 1, @transaction_date),
        'Address ' + CAST(@i AS VARCHAR(4)),  
        'City' + CAST(@i AS VARCHAR(4)),  
        @customer_country
    );
    
    SET @i = @i + 1;
END;
GO