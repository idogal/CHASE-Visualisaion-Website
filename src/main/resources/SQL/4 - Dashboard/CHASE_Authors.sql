-- Query 1
SELECT [Author_Name]
      ,[Aff_Name]
  FROM [dbo].[Authors_Proccessed]

-- Query 2
SELECT Author_Name, COUNT(*)
FROM   Authors AS A
WHERE EXISTS (SELECT * FROM Papers_Details AS PD WHERE PD.Paper_Order = 1 AND PD.Paper_API_Id = A.Paper_Id)
GROUP BY Author_Name

-- Each publication, with it's authors
SELECT PD.Paper_Id, PD.Paper_Year, PD.Citations_Count, PD.Display_Name
      , PD.Venue_Short_Name, PD.DOI
	  ,PD.Abstract
	  ,PD.Abstract_Length
	  ,A.Author_Name, A.Author_Position
	  ,A.Affiliation_Name, A.Author_Id
FROM   Authors AS A
       INNER JOIN Papers_Details AS PD 
	     ON (A.Paper_Id = PD.Paper_API_Id)
WHERE Paper_Order = 1 ;

-- Query 4
SELECT A.Author_Id, A.Author_Name, PD.Paper_Year, PD.Citations_Count
FROM   Authors AS A
       INNER JOIN Papers_Details AS PD 
	     ON (A.Paper_Id = PD.Paper_API_Id)
WHERE Paper_Order = 1 ;

-- Query 5
SELECT A.Affiliation_Name, COUNT(*)
FROM   Authors AS A
       INNER JOIN Papers_Details AS PD 
	     ON (A.Paper_Id = PD.Paper_API_Id)
WHERE Paper_Order = 1 AND A.Affiliation_Name IS NOT NULL
GROUP BY A.Affiliation_Name;