--Query 1
SELECT * 
FROM   [dbo].[Fact_Keywords_And_Fields]

-- Query 2
SELECT ROW_NUMBER() OVER (ORDER BY [Dim_Fields_Of_Study].[Field_Name]),
       [Field_Name]
  FROM [dbo].[Dim_Fields_Of_Study]

-- Query 3
SELECT ROW_NUMBER() OVER (ORDER BY [Dim_Keywords].[Keyword_Value]),
       [Keyword_Value]
  FROM [dbo].[Dim_Keywords]

-- Query 4
SELECT [TIME_ID], [TIME_YEAR]      
  FROM [dbo].[DIMTIME]