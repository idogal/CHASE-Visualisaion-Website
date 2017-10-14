;
WITH SIM_KEYWORDS
AS
(
	SELECT K1.Keyword_Value AS Keyword_1, K2.Keyword_Value AS Keyword_2, 
		   NTILE((SELECT COUNT(*) FROM [Keywords])) OVER (ORDER BY K1.Keyword_Value) AS RN
	FROM  [dbo].Dim_Keywords AS K1
		  CROSS JOIN [dbo].Dim_Keywords AS K2
	WHERE K1.Keyword_Value <> K2.Keyword_Value-- AND K1.Keyword_Value LIKE '%SUP%'  AND K2.Keyword_Value LIKE '%SUP%'
), 
 SIM_NO_DUPS
 AS
(
	SELECT K1.Keyword_1, K1.Keyword_2
	FROM   SIM_KEYWORDS AS K1
	WHERE  NOT EXISTS (SELECT * FROM SIM_KEYWORDS AS K2 WHERE K2.Keyword_2 = K1.Keyword_1 AND K2.Keyword_1 = K1.Keyword_2 AND K2.RN > K1.RN)
) ,
  SIM_NO_DUPS2
  AS
(
	SELECT DISTINCT
	       Keyword_1, Keyword_2,
			Sim_Levenshtein = (SELECT [CLRDB].[dbo].[StringUtils_Levenshtein] (Keyword_1, Keyword_2)),
			Sim_JaroWinkler = (SELECT [CLRDB].[dbo].StringUtils_JaroWinkler (Keyword_1, Keyword_2))
	FROM   SIM_NO_DUPS
)
--INSERT INTO Keywords_With_Similarity
SELECT * FROM SIM_NO_DUPS2 
WHERE Sim_Levenshtein > 0.85 AND Sim_JaroWinkler > 0.96
ORDER BY Keyword_1 ASC;

-- DELETE FROM Keywords_With_Similarity