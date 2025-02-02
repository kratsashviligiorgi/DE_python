USE master;
GO

CREATE DATABASE Greenplum;
GO

USE Greenplum;
GO

CREATE SCHEMA Customer;
GO
CREATE SCHEMA Product;
GO
CREATE SCHEMA Sales;
GO
---------------------

--for customers table i used primary key constraint on constumer_ID 
--to ensure it would be UNIQUE and NOT NULL and for use as a foreign key in the sales_transactions table
--for customer name i used NVARCHAR datatype, 
--even though its heavier for international scalability it would be usefull
--added UNIQE constraing to email_address cause 
--i dont think we should have redundant email adresses for different customers, as a sort of a natural key
--multiple different customers cant have the same email adress

CREATE TABLE Customer.customers (
    customer_ID INT PRIMARY KEY,
    customer_name NVARCHAR(100) NOT NULL,
    email_address VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL
);


--Fro products table i added primary key on the product_ID to ensure
--its unieuqness and to restrain it from having null values 
--and also to use it as foreign key in transactions table
--was thinking of doing DECIMAL(10,2) datatype fro price
--but since thre will be precision needed for transactions i stuck with MONEY
--would be good to create a CLI table of categories in the Product schema 
--and leave only category_ID inside the products table for further scalability


CREATE TABLE Product.products (
    product_ID INT PRIMARY KEY, 
    product_name VARCHAR(100) NOT NULL, 
    price MONEY NOT NULL, 
    category VARCHAR(100)
);

--added primary key constaint to transaction_ID 
--added Foreign Key constraints to customer_ID and product_ID
--and referenced them to the tables where they are generated from
--added not null constraint to both of them 
--since transaction should always have a buyer and a product thats being bought
--also purchase date should always be present 
--in addition quantity cant be null and must be a positive number so i added a check for it

CREATE TABLE Sales.sales_transactions (
    transaction_ID INT PRIMARY KEY, 
    customer_ID INT NOT NULL,
    product_ID INT NOT NULL,
    purchase_date DATE NOT NULL,
    quantity INT NOT NULL,

    CONSTRAINT fk_customer FOREIGN KEY (customer_ID) REFERENCES Customer.customers(customer_ID),
    CONSTRAINT fk_product FOREIGN KEY (product_ID) REFERENCES Product.products(product_ID),
	CONSTRAINT chk_quantity_positive CHECK (quantity > 0)
);

--each transaction id for shipping should be unique,
--cause purchased products should be shipped together
--also a date must be present

CREATE TABLE Sales.shipping_details (
    shipping_ID INT PRIMARY KEY, 
    transaction_ID INT,
    shipping_date DATE NOT NULL,
    shipping_address VARCHAR(255) NOT NULL,  
    city VARCHAR(100) NOT NULL,  
    country VARCHAR(100) NOT NULL, 

    CONSTRAINT fk_transaction FOREIGN KEY (transaction_ID) REFERENCES Sales.sales_transactions(transaction_ID),
    CONSTRAINT uq_transaction_ID UNIQUE (transaction_ID)
);

--also would be a good idea to add currency_ID to the products table for further scalability of the business
--and to create a table for currencies in time, 
--which will have CurrencyAltKey,DateKey and rate 
--at which the different currencies were traded in that date in comparison to our main currency
--so we can join our sales_transactions table to the products table to get price, currency and date
--and calculate the amount of purchased goods from the sale with that dates rate of the currency

