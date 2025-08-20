--*************************************************************************--
-- Title: Assignment06
-- Author: MBland
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-08-20,MBland,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MBland')
	 Begin 
	  Alter Database [Assignment06DB_MBland] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MBland;
	 End
	Create Database Assignment06DB_MBland;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MBland;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW vCategories
WITH SCHEMABINDING
	AS
	  SELECT 
		CategoryID,
		CategoryName
	  FROM dbo.Categories;
go

CREATE VIEW vProducts
WITH SCHEMABINDING
	AS
	  SELECT 
		ProductID,
		ProductName,
		CategoryID,
		UnitPrice
	  FROM dbo.Products;
go

CREATE VIEW vEmployees
WITH SCHEMABINDING
	AS
	  SELECT 
		EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
	  FROM dbo.Employees;
go

CREATE VIEW vInventories
WITH SCHEMABINDING
	AS
	  SELECT 
		InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		Count
	  FROM dbo.Inventories;
go
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny SELECT ON Categories to Public;
Deny SELECT ON Products to Public;
Deny SELECT ON Employees to Public;
Deny SELECT ON Inventories to Public;

Grant SELECT ON vCategories to Public;
Grant SELECT ON vProducts to Public;
Grant SELECT ON vEmployees to Public;
Grant SELECT ON vInventories to Public;

go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


CREATE OR ALTER VIEW vProductsByCategories
	AS
	  SELECT TOP 100000
		C.CategoryName,P.ProductName,P.UnitPrice 
	  FROM vCategories AS C JOIN vProducts AS p 
		ON C.CategoryID = P.CategoryID
  			ORDER BY C.CategoryName,P.ProductName;
go
Select CategoryName,ProductName,UnitPrice From vProductsByCategories;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE OR ALTER VIEW vInventoriesByProductsByDates
	AS
	  SELECT TOP 100000 
		P.ProductName,I.InventoryDate,I.Count 
	  FROM vProducts AS P JOIN Inventories AS I
		ON P.ProductID = I.ProductID
			ORDER BY P.ProductName,I.InventoryDate,I.Count;
go
Select ProductName,InventoryDate,Count From vInventoriesByProductsByDates;
go
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE OR ALTER VIEW vInventoriesByEmployeesByDates
	AS
	  SELECT DISTINCT
		InventoryDate,(EmployeeFirstName + EmployeeLastName) AS 'EmployeeName' 
	  FROM Inventories,Employees
		WHERE Inventories.EmployeeID = Employees.EmployeeID;
go
Select InventoryDate,EmployeeName From vInventoriesByEmployeesByDates;
go
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE OR ALTER VIEW vInventoriesByProductsByCategories
	AS
	  SELECT TOP 100000 
		C.CategoryName,P.ProductName,I.InventoryDate,I.Count 
	  FROM vCategories AS C JOIN vProducts AS P
		ON C.CategoryID = P.CategoryID
	  JOIN vInventories AS I
	    ON I.ProductID = P.ProductID
  			ORDER BY C.CategoryName,P.ProductName,I.InventoryDate,I.Count;
go
Select CategoryName,ProductName,InventoryDate,Count From vInventoriesByProductsByCategories;
go
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE OR ALTER VIEW vInventoriesByProductsByEmployees
	AS
	  SELECT TOP 100000 
		C.CategoryName,P.ProductName,I.InventoryDate,I.Count,(EmployeeFirstName + EmployeeLastName) AS EmployeeName
	  FROM vCategories AS C JOIN vProducts AS P
		ON C.CategoryID = P.CategoryID
	  JOIN vInventories AS I 
		ON I.ProductID = P.ProductID
	  JOIN vEmployees AS E
		ON E.EmployeeID = I.EmployeeID
  		 ORDER BY I.InventoryDate,C.CategoryName,P.ProductName,EmployeeName;
go
Select InventoryDate,CategoryName,ProductName,EmployeeName From vInventoriesByProductsByEmployees;
go
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE OR ALTER VIEW vInventoriesForChaiAndChangByEmployees
	AS
	  SELECT 
		C.CategoryName,P.ProductName,I.InventoryDate,I.Count,(EmployeeFirstName + EmployeeLastName) AS 'EmployeeName' 
	  FROM vCategories AS C JOIN vProducts AS P 
		ON C.CategoryID = P.CategoryID
	  JOIN vInventories AS I
		ON I.ProductID = P.ProductID
	  JOIN vEmployees AS E
		ON E.EmployeeID = I.EmployeeID
			WHERE P.ProductName in (SELECT ProductName FROM vProducts WHERE ProductName in ('Chai','Chang'));
		
go
Select CategoryName,ProductName,InventoryDate,Count,EmployeeName From vInventoriesForChaiAndChangByEmployees ORDER BY InventoryDate;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE OR ALTER VIEW vEmployeesByManager
	AS
	  SELECT TOP 100000
	    M.EmployeeFirstName + ' ' +M.EmployeeLastName AS Manager,
		E.EmployeeFirstName + ' ' +E.EmployeeLastName AS Employee
      FROM Employees AS E
		INNER JOIN Employees AS M
			ON E.ManagerID = M.EmployeeID
        ORDER BY Manager,Employee;
go
Select Manager,Employee FROM vEmployeesByManager;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE OR ALTER VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
	  SELECT TOP 100000
		C.CategoryID,
		C.CategoryName,
		P.ProductID,
		P.ProductName,
		P.UnitPrice,
		I.InventoryID,
		I.InventoryDate,
		I.Count,
		E.EmployeeID,
		E.EmployeeFirstName + ' ' +E.EmployeeLastName AS Employee,
		M.EmployeeFirstName + ' ' +M.EmployeeLastName AS Manager
	  FROM vCategories AS C JOIN vProducts AS P
		ON C.CategoryID = P.CategoryID 
	  JOIN vInventories AS I
		ON P.ProductID = I.ProductID
	  JOIN vEmployees AS E
		ON E.EmployeeID = I.EmployeeID 
	  JOIN vEmployees AS M
		ON E.ManagerID = M.EmployeeID
			ORDER BY C.CategoryName,P.ProductName,I.InventoryID,Employee;

go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/