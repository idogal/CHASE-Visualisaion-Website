-- Unique authors
SELECT DISTINCT A.Author_Id, A.Author_Name
FROM   Authors AS A;

-- Each publication, with it's authors
SELECT PD.Paper_Id, PD.Paper_Year, PD.Citations_Count, PD.Display_Name
      ,PD.Venue_Full_Name, PD.Venue_Short_Name, PD.DOI
	  ,PD.Abstract
	  ,PD.Abstract_Length
	  ,A.Author_Name, A.Author_Position, A.Author_Id
	  ,A.Affiliation_Name
FROM   Authors AS A
       INNER JOIN Papers_Details AS PD 
	     ON (A.Paper_Id = PD.Paper_API_Id);

-- Affiliations and publications
SELECT A.Affiliation_Name, COUNT(*) AS Publications
FROM   Authors AS A
       INNER JOIN Papers_Details AS PD 
	     ON (A.Paper_Id = PD.Paper_API_Id)
GROUP BY A.Affiliation_Name;