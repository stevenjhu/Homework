--Use Northwind database. All questions are based on assumptions described by the Database Diagram sent to you yesterday. When inserting, make up info if necessary. Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.

--1.      Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_hu
AS
SELECT p.ProductID,p.ProductName, ISNULL(SUM(od.Quantity),0) TotalQuantity
FROM Products p LEFT JOIN [Order Details] od ON p.ProductID=od.ProductID
GROUP BY p.ProductID,p.ProductName
GO
--2.      Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_hu
@id INT,
@tq INT OUT
AS
BEGIN
    SELECT @tq = TotalQuantity FROM view_product_order_hu WHERE ProductID = @id 
END
GO
--3.      Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_hu
@name VARCHAR(20)
AS
BEGIN
    SELECT TOP 5 od.ProductID, p.ProductName, SUM(Quantity) Quantity
    FROM [Order Details] od JOIN Products p
    ON od.ProductID = p.ProductID
    WHERE p.ProductName = @name
    GROUP BY od.ProductID,p.ProductName
    ORDER BY  SUM(Quantity) DESC
END
GO
--4.      Create 2 new tables “people_your_last_name” “city_your_last_name”. 
/*
City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. 
Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. 
Create a view “Packers_your_name” lists all people from Green Bay. 
If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
*/
CREATE TABLE  people_hu(
    Id INT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    City INT NOT NULL
)
GO
CREATE TABLE city_hu(
    Id INT PRIMARY KEY,
    City VARCHAR(20) NOT NULL
)
GO
INSERT INTO people_hu VALUES(1,'Aaron Rodgers',2)
INSERT INTO people_hu VALUES(2,'Russel Wilson',1)
INSERT INTO people_hu VALUES(3,'Jody Nelson',2)
INSERT INTO city_hu VALUES(1,'Seattle')
INSERT INTO city_hu VALUES(2,'Green Bay')
GO
UPDATE city_hu
SET City = 'Madison' 
WHERE City = 'Seattle'
GO
CREATE VIEW packers_hu
AS
SELECT * FROM people_hu WHERE City = 2
GO
DROP TABLE people_hu
DROP TABLE city_hu
DROP VIEW packers_hu
GO
--5.       Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. 
--(Make a screen shot) drop the table. Employee table should not be affected.
CREATE PROC sp_birthday_employees_hu
AS
BEGIN

    SELECT *
    INTO birthday_employees_hu
    FROM Employees
    WHERE MONTH(BirthDate) = 2
        
END
EXEC sp_birthday_employees_hu
GO
SELECT * FROM birthday_employees_hu
GO
DROP TABLE birthday_employees_hu
--6.How do you make sure two tables have the same data?
--First of all, check if the two tables have the same schema
--Then
--CREATE two identical tables
CREATE TABLE demo1(
    Id INT PRIMARY KEY
)
CREATE TABLE demo2(
    Id INT PRIMARY KEY
)
INSERT INTO demo1 VALUES(1)
INSERT INTO demo2 VALUES(1)
GO
--if the result set is empty, the two tables contain identical content
SELECT * FROM demo1
EXCEPT
SELECT * FROM demo2
GO
--if the result set is not empty, the difference in the two tables will show up in the result set
INSERT INTO demo1 VALUES(2)
GO
SELECT * FROM demo1
EXCEPT
SELECT * FROM demo2
