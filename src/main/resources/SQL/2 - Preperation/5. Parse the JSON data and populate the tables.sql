-- STEP A: Run before the rest of the script --
----------------------------------------------- 
INSERT INTO Papers_Details (Paper_Id, Paper_API_Id, Paper_Order)
	SELECT P.Paper_ID, P.Paper_ID, 1
	FROM   [dbo].[Papers_Academic_Info] AS P
	WHERE NOT EXISTS (SELECT * FROM Papers_Details AS Trgt WHERE P.Paper_ID = Trgt.Paper_API_Id)

-- STEP B                                    --
----------------------------------------------- 
UPDATE Papers_Details
SET    Paper_Year = X.P_Year
     , Paper_Date = X.P_Date
	 , Citations_Count = X.P_CC
	 , Est_Citations_Count = X.P_ECC
FROM
(
	SELECT P.Paper_ID, 2 AS O, Papers.*
	FROM   [dbo].[Papers_Academic_Info] AS P
		   CROSS APPLY OPENJSON([JSON_Acedemic_Info], '$.entities')
			WITH 
			(   
				P_Year    CHAR(4) '$.Y',  
				P_Date DATETIME '$.D',
				P_CC   INT  '$.CC',
				P_ECC   INT  '$.ECC'
			 ) AS Papers
) AS X
WHERE  X.Paper_ID = Papers_Details.Paper_Id


UPDATE Papers_Details
SET    Display_Name = X.Display_Name,
       Venue_Short_Name = X.Venue_Short_Name,
	   Venue_Full_Name = X.Venue_Full_Name,
	   DOI  = X.DOI,
	   Abstract = X.Abstract,
	   Abstract_Length = X.IndexLength
FROM   
(
	SELECT P.Paper_ID
	      , Extended_Info_Details.Display_Name
		  , Extended_Info_Details.Venue_Short_Name
		  , Extended_Info_Details.Venue_Full_Name
		  , Extended_Info_Details.DOI
		  , Extended_Info_Details.Abstract
		  , Inverted_Abstract_A.IndexLength
	FROM   [dbo].[Papers_Academic_Info] AS P
	CROSS APPLY OPENJSON(P.Extended_Academic_Info, '$.entities') 
	WITH 
	(   
		E    NVARCHAR(MAX) '$.E' 
	) AS Extended_Info
	CROSS APPLY OPENJSON(Extended_Info.E, '$')
    WITH 
	(   
		 Display_Name VARCHAR(1000)		'$.DN' 
		,Venue_Short_Name VARCHAR(1000)	'$.VSN' 
		,Venue_Full_Name VARCHAR(1000)	'$.VFN' 
		,DOI VARCHAR(100)				'$.DOI' 
		,Abstract VARCHAR(MAX)			'$.D' 
	) AS Extended_Info_Details
	OUTER APPLY OPENJSON(Extended_Info.E, '$.IA')
    WITH 
	(   
		 IndexLength INT	'$.IndexLength'
	) AS Inverted_Abstract_A

) AS X
WHERE X.Paper_ID = Papers_Details.Paper_Id

INSERT INTO Keywords (Paper_Id, Keyword_Value)
	SELECT DISTINCT
		   D.Paper_API_Id, Keywords.value
	FROM   [dbo].[Papers_Academic_Info] AS P 
		   INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
		   CROSS APPLY OPENJSON([JSON_Acedemic_Info], '$.entities') AS Entities
		   CROSS APPLY OPENJSON(Entities.value, '$.W') AS Keywords	

INSERT INTO Authors 
            (Paper_Id, Author_Name, Author_Id, Affiliation_Name, Affiliation_Id, Author_Position)
	SELECT D.Paper_API_Id, Authors.*
	FROM   [dbo].[Papers_Academic_Info] AS P
	       INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
		   CROSS APPLY OPENJSON([JSON_Acedemic_Info], '$.entities') AS Entities
		   CROSS APPLY OPENJSON(Entities.value, '$.AA')
			WITH 
			(   
				Author_Name    varchar(200) '$.AuN',  
				Author_Id varchar(200) '$.AuId',
				Affiliation_Name varchar(200) '$.AfN',
				Affiliation_Id varchar(200) '$.AfId',
				Author_Order INT '$.S'
			 ) AS Authors			 

INSERT INTO Fields_Of_Study 
            (Paper_Id, Field_Id, Field_Name)
	SELECT D.Paper_API_Id, Fields.Field_Id, Fields.Field_Name
	FROM   [dbo].[Papers_Academic_Info] AS P
	       INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
		   CROSS APPLY OPENJSON([JSON_Acedemic_Info], '$.entities') AS E
		   CROSS APPLY OPENJSON(E.value, '$.F') 
			WITH 
			(   
				Field_Id    varchar(200) '$.FId',  
				Field_Name varchar(200) '$.FN'
			 ) AS Fields


INSERT INTO Inverted_Abstract
           (Paper_ID, Word_Value, Word_Positions, Work_Checksum)
	SELECT	D.Paper_API_Id, Inverted_Abstract_B.[Key], Inverted_Abstract_B.[value], 
			CHECKSUM(Inverted_Abstract_B.[Key]) AS Work_Checksum
	FROM	[dbo].[Papers_Academic_Info] AS P
			INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
			CROSS APPLY OPENJSON(P.Extended_Academic_Info, '$.entities') 
			WITH 
			(   
				E    NVARCHAR(MAX) '$.E' 
			) AS Extended_Info
			CROSS APPLY OPENJSON(Extended_Info.E, '$.IA.InvertedIndex') AS Inverted_Abstract_B

INSERT INTO Citation_Contexts 
           (Paper_Id, Citation_ID, Citation_Value)
	SELECT D.Paper_API_Id, Citation_Contexts.[key], Citation_Contexts.[value]
	FROM   [dbo].[Papers_Academic_Info] AS P
			INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
			CROSS APPLY OPENJSON(P.Extended_Academic_Info, '$.entities') 
			WITH 
			(   
				E    NVARCHAR(MAX) '$.E' 
			) AS Extended_Info
			CROSS APPLY OPENJSON(Extended_Info.E, '$.CC') AS Citation_Contexts			

INSERT INTO DIMTIME (TIME_YEAR)
	SELECT DISTINCT Paper_Year
	FROM   Papers_Details

INSERT INTO Papers_References (Paper_Id, Reference_ID)
	SELECT DISTINCT D.Paper_API_Id, Ref.value AS Ref_Id	
	FROM   [dbo].[Papers_Academic_Info] AS P
	        INNER JOIN [dbo].Papers_Details AS D ON (P.Paper_ID = D.Paper_Id)
			CROSS APPLY OPENJSON(References_JSON_Info, '$.entities') AS E
			CROSS APPLY OPENJSON(E.value, '$.RId') AS Ref


-- This part isn't needed. Kept as a backup for now (July 17)
/*
INSERT INTO Papers_Details (Paper_Id, Paper_API_Id, Paper_Order)
	SELECT (227 + ROW_NUMBER() OVER (ORDER BY NEWID()))
	       ,Reference_ID, O
	FROM 
	(
	SELECT DISTINCT Reference_ID, 2 AS O
	FROM Papers_References AS PR
	) AS R
	WHERE NOT EXISTS (SELECT * FROM Papers_Details WHERE Paper_API_Id = Reference_ID);
	

INSERT INTO Authors 
        (Paper_Id, Author_Name, Author_Id, Affiliation_Name, Affiliation_Id, Author_Position)
	SELECT id, Author_Name, Author_Id, Affiliation_Name, Affiliation_Id, Author_Order
	FROM   [JSON_Data] AS Ref_Data
		   CROSS APPLY OPENJSON(JSON_Simple_Info, '$.entities') AS Entities
		   CROSS APPLY OPENJSON(Entities.value, '$.AA')
			WITH 
			(   
				Author_Name    varchar(200) '$.AuN',  
				Author_Id varchar(200) '$.AuId',
				Affiliation_Name varchar(200) '$.AfN',
				Affiliation_Id varchar(200) '$.AfId',
				Author_Order INT '$.S'
			 ) AS Authors
	WHERE Paper_Order = 2	
	      AND NOT EXISTS (SELECT * FROM Authors WHERE Authors.Paper_Id = Ref_Data.Id);

		  */