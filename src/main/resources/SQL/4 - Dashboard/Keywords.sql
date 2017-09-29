-- Unique keywords
SELECT * FROM [Dim_Keywords]

-- A keywords records for each paper
SELECT * FROM [dbo].[Fact_Keywords]

-- Date dimension
SELECT * FROM DIMTIME

-- Summary data about keywords
SELECT * FROM Data_Keywords_Summary

-- Keywords, by citations
SELECT KW.Keyword_Value, SUM(PD.Citations_Count) AS  Citations_Count
FROM   Keywords AS KW 
       INNER JOIN Papers_Details AS PD
	     ON (KW.Paper_Id = PD.Paper_Id)
GROUP BY KW.Keyword_Value