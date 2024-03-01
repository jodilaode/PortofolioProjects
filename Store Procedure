USE [AdventureWorksDW2022]
GO

/****** Object:  StoredProcedure [dbo].[OrdersReport]    Script Date: 01/03/2024 07:07:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create store procedure for looking TopN sales rank and N category product
-- database AdventureWorksDW2022

ALTER PROCEDURE [dbo].[OrdersReport](@TopN INT, @MyInput VARCHAR(100))

AS

BEGIN
	DECLARE @Ncategory VARCHAR(100)
	
	SET @Ncategory = (SELECT EnglishProductCategoryName FROM DimProductCategory WHERE EnglishProductCategoryName = @MyInput)
	
	IF @Ncategory = @MyInput
		BEGIN

			SELECT
			*
			FROM
				(
					SELECT
						 DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate),1) OrderDate					
						,pc.EnglishProductCategoryName Category
						,p.EnglishProductName Product
						,SUM(s.SalesAmount) SalesAmount
						,SUM(s.TaxAmt) TaxAmt
						,RankSales = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate),1), pc.EnglishProductCategoryName ORDER BY SUM(s.SalesAmount) DESC)
					FROM FactInternetSales s
					INNER JOIN DimProduct p
					ON s.ProductKey = p.ProductKey
					INNER JOIN DimProductSubcategory ps
					ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
					INNER JOIN DimProductCategory pc
					ON ps.ProductCategoryKey = pc.ProductCategoryKey
					GROUP BY p.EnglishProductName, s.OrderDate, pc.EnglishProductCategoryName
				)x
			WHERE x.RankSales <= @TopN AND x.Category = @MyInput
		END
	ELSE
			SELECT
			*
			FROM
				(
					SELECT						
						 DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate),1) OrderDate
						,pc.EnglishProductCategoryName Category
						,p.EnglishProductName Product
						,SUM(s.SalesAmount) SalesAmount
						,SUM(s.TaxAmt) TaxAmt
						,RankSales = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate),1), pc.EnglishProductCategoryName ORDER BY SUM(s.SalesAmount) DESC)
					FROM FactInternetSales s
					INNER JOIN DimProduct p
					ON s.ProductKey = p.ProductKey
					INNER JOIN DimProductSubcategory ps
					ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
					INNER JOIN DimProductCategory pc
					ON ps.ProductCategoryKey = pc.ProductCategoryKey
					GROUP BY p.EnglishProductName, s.OrderDate, pc.EnglishProductCategoryName
				)x
			WHERE x.RankSales <= @TopN AND x.Category <> @MyInput
END
GO
