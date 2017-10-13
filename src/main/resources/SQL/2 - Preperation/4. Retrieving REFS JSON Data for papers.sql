DECLARE @Paper_Name VARCHAR(1000);
DECLARE @Paper_ID BIGINT;

DECLARE Papers_Cursor CURSOR FAST_FORWARD 
FOR
(
	SELECT TOP (100) PERCENT * 
	FROM (SELECT Id, Ti as Paper_Name FROM ##CHASE_PAPERS_LIST) AS [Papers_List]
	--WHERE NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = [Papers_List].ID)
);

OPEN Papers_Cursor;
FETCH NEXT FROM Papers_Cursor INTO @Paper_ID, @Paper_Name;

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	DECLARE @Request_Value VARCHAR(4000);
	DECLARE @Response_Body  NVARCHAR(MAX);
	DECLARE @Response_Status_Code   NVARCHAR(100);
	DECLARE @Response_Status_Code_Text   NVARCHAR(1000);

	SET @Request_Value = 
	   'https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?' 
	   +
	   'expr='
	   --+'And(Composite(C.CN=''icse''), Y=2017)'
	   +'Id=' + CAST(@Paper_ID AS VARCHAR(100))
	   +'&count=1000'
	   +
	   '&attributes=RId'

	EXECUTE [CLRDB].[dbo].[HttpUtilities_HttpRequest] 
	   @Http_Method = 'GET'
	  ,@Request_URI = @Request_Value
	  ,@Request_Body = ''
	  ,@Request_Content_Type = ''
	  ,@Header_Values  = 'Ocp-Apim-Subscription-Key,edd1731c7e5d48a1ac3f057a41726bfd'
	  ,@Response_Body = @Response_Body OUTPUT 
	  ,@Response_Status_Code = @Response_Status_Code OUTPUT
	  ,@Response_Status_Code_Text = @Response_Status_Code_Text OUTPUT



	  --SELECT @Response_Body, @Response_Status_Code, @Response_Status_Code_Text

    --IF (NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = @Paper_ID AND I.References_JSON_Info IS NOT NULL))
		UPDATE Papers_Academic_Info
		SET References_JSON_Info = @Response_Body
		WHERE Paper_ID = @Paper_ID;

	FETCH NEXT FROM Papers_Cursor INTO @Paper_ID, @Paper_Name;

	--WAITFOR DELAY '00:00:01';
END;

CLOSE Papers_Cursor;
DEALLOCATE Papers_Cursor;

--SELECT * FROM Papers_Academic_Info