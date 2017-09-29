SELECT * 
FROM 
(
SELECT PD.Paper_API_Id, PD.Paper_Year, PD.Citations_Count, PD.Display_Name, PD.Venue_Short_Name, PD.DOI, PD.Abstract, PD.Abstract_Length
      ,A.Author_Name, A.Author_Position, A.Affiliation_Name, A.Author_Id
	  ,(SELECT dbo.ConcatAuthors(PD.Paper_API_Id)) AS All_Authors
FROM   Papers_Details AS PD
       INNER JOIN Authors AS A
	     ON (PD.Paper_API_Id = A.Paper_Id)
WHERE  PD.Paper_Order = 1
) AS Author_Publication
FOR XML AUTO, ELEMENTS, ROOT('Authors_Publications')