--Joins:
--(AdventureWorks)


--1. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the
--following.




--    Country                        Province
SELECT cr.Name Country, sp.Name Province
FROM Person.CountryRegion cr JOIN Person.StateProvince sp ON cr.CountryRegionCode = sp.CountryRegionCode



--2. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada.
--Join them and produce a result set similar to the following.




--    Country                        Province
SELECT cr.Name Country, sp.Name Province
FROM Person.CountryRegion cr JOIN Person.StateProvince sp ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE cr.Name IN ('Germany','Canada')



-- Using Northwind Database: (Use aliases for all the Joins)




--3. List all Products that has been sold at least once in last 25 years.
SELECT DISTINCT ods.ProductID,p.ProductName
FROM(SELECT od.OrderID, o.OrderDate, od.ProductID
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE DATEDIFF(year, GETDATE(), o.OrderDate) <=25) ods JOIN Products p on ods.ProductID = p.ProductID



--4. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT ShipPostalCode, ProductName, SumOfQuantity, RNK
FROM(SELECT ods.ShipPostalCode, ods.ProductID, p.ProductName, SUM(ods.Quantity) SumOfQuantity, RANK() OVER(PARTITION BY ods.ShipPostalCode ORDER BY SUM(ods.Quantity) DESC) RNK
FROM(SELECT od.OrderID OrderID, o.OrderDate OrderDate, o.ShipPostalCode ShipPostalCode, od.ProductID ProductID, od.Quantity
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE DATEDIFF(year, GETDATE(), o.OrderDate)<=25) ods JOIN Products p ON ods.ProductID = p.ProductID
GROUP BY ods.ShipPostalCode, ods.ProductID, p.ProductName) rnks
WHERE RNK <=5 AND ShipPostalCode IS NOT NULL


--5. List all city names and number of customers in that city.     
SELECT City, COUNT(ContactName) NumOfCustomer
FROM Customers
GROUP BY City

--6. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(ContactName) NumOfCustomer
FROM Customers
GROUP BY City
HAVING COUNT(ContactName) >2



--7. Display the names of all customers  along with the  count of products they bought
SELECT c.ContactName, ISNULL(inf.SumOfQuantity,0) SumOfQuantity
FROM(SELECT o.CustomerID, SUM(od.Quantity) SumOfQuantity
FROM [Order Details] od JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.CustomerID) inf RIGHT JOIN [Customers] c ON inf.CustomerID = c.CustomerID



--8. Display the customer ids who bought more than 100 Products with count of products.
SELECT c.CustomerID, ISNULL(inf.SumOfQuantity,0) SumOfQuantity
FROM(SELECT o.CustomerID, SUM(od.Quantity) SumOfQuantity
FROM [Order Details] od JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.CustomerID) inf RIGHT JOIN [Customers] c ON inf.CustomerID = c.CustomerID
WHERE inf.SumOfQuantity >100



--9. List all of the possible ways that suppliers can ship their products. Display the results as below
--    Supplier Company Name                Shipping Company Name
SELECT DISTINCT o.ShipName [Supplier Company Name], s.CompanyName [Shipping Company Name]
FROM Orders o JOIN Shippers s ON o.ShipVia = s.ShipperID




--10. Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID=p.ProductID
ORDER BY OrderDate



--11. Displays pairs of employees who have the same job title.

SELECT FirstName, LastName, Title
FROM Employees
WHERE Title IN 
(SELECT Title
FROM Employees
GROUP BY Title
HAVING COUNT(Title) > 1)



--12. Display all the Managers who have more than 2 employees reporting to them.
SELECT e.FirstName, e.LastName, rp.ReportsTo
FROM 
(SELECT ReportsTo, COUNT(ReportsTo)
FROM Employees
GROUP BY ReportsTo
HAVING COUNT(ReportsTo) > 2) AS rp JOIN Employees e ON rp.ReportsTo  = e.EmployeeID




--13. Display the customers and suppliers by city. The results should have the following columns
--City


--Name


--Contact Name,


--Type (Customer or Supplier)
--All scenarios are based on Database NORTHWIND.
SELECT City, CompanyName AS Name, ContactName, 'Customer' [Type (Customer or Supplier)]
FROM Customers
UNION
SELECT City, CompanyName AS Name, ContactName, 'Supplier' [Type (Customer or Supplier)]
FROM Suppliers 




--14. List all cities that have both Employees and Customers.
SELECT DISTINCT e.City
FROM Employees e 
JOIN (
SELECT DISTINCT City
FROM Customers ) c 
On e.City = c.City

--15. List all cities that have Customers but no Employee.
--a. 
-- Use
--sub-query
SELECT DISTINCT c.City CustomerCity, e.City EmployeeCity
FROM Employees e 
RIGHT JOIN (
SELECT DISTINCT City
FROM Customers ) c 
On e.City = c.City
WHERE e.City IS NULL

--b. 
-- Do
--not use sub-query
SELECT DISTINCT c.City, e.City
FROM Employees e RIGHT JOIN Customers c ON e.City = c.City
WHERE e.City IS NULL

--16. List all products and their total order quantities throughout all orders.
SELECT od.ProductID, p.ProductName,SUM(od.Quantity) SumOfQuantity
FROM [Order Details] od JOIN Products p ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName

--17. List all Customer Cities that have at least two customers.
--a. 
    
-- Use
--union
SELECT City, COUNT(CustomerID) NumOfCustomer
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
UNION
SELECT City, COUNT(CustomerID) NumOfCustomer
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 2

--b. 
    
-- Use
--no union
SELECT City, COUNT(CustomerID) NumOfCustomer
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >=2

--18. List all Customer Cities that have ordered at least two different kinds of products.
--Customers JOIN Orders, determine in which cities Orders are placed
--Orders JOIN Order Detail, COUNT ProductID according to city info in joined orders table
SELECT oc.City, COUNT(od.ProductID) NumOfProduct
FROM(SELECT o.OrderID,c.City
FROM Orders o LEFT JOIN Customers c ON o.CustomerID = c.CustomerID) oc JOIN [Order Details] od ON oc.OrderID = od.OrderID
GROUP BY oc.City
HAVING COUNT(od.ProductID) >=2


--19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
--Popular = Sum(ProductID), average price = AVE(UnitPrice) of all orders, city ordered most quantity = max(quantity) by city

 


--20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered
--from. (tip: join  sub-query)
--Order JOIN Employees by EmployeeID 
--Subquery rank order quantity sold, and rank product quantity sold
--Main query filter WHERE rank =1 and rank = 1



--21. How do you remove the duplicates record of a table?
--Use DISTINCT clause
