-- Query 1
SELECT DISTINCT [Keyword_Value]
FROM  [dbo].[Data_Keywords_Summary]

-- Query 2
SELECT [Paper_Year]
      ,[Keyword_Value]
      ,[Count_Yearly]
      ,[Count_Total]
      ,[PCT_Total]
      ,[PCT_Yearly]
  FROM [dbo].[Data_Keywords_Summary]


-- Query 3
SELECT K.Keyword_Value, SUM(PD.Citations_Count) AS C_COUNT
FROM   Keywords AS K
       INNER JOIN Papers_Details AS PD 
	     ON (K.Paper_Id = PD.Paper_API_Id)
WHERE Paper_Order = 1 AND EXISTS (SELECT * FROM [dbo].[Data_Keywords_Summary] AS KS WHERE KS.Keyword_Value = K.Keyword_Value)
GROUP BY K.Keyword_Value;


