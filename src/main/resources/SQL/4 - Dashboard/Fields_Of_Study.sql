-- Fields Of Study, unique fields
SELECT DISTINCT F.Field_Id, F.Field_Name
FROM   Fields_Of_Study AS F;

-- Fields by Papers, each paper with all of it's fields of study
SELECT PD.Display_Name, Citations_Count, Paper_Year, Field_Id, Field_Name
FROM   Fields_Of_Study AS F
       INNER JOIN Papers_Details AS PD
	     ON (F.Paper_Id = PD.Paper_API_Id);