DECLARE P_CURSOR CURSOR FOR 
	SELECT Id, Ti FROM ##CHASE_PAPERS_LIST

DECLARE @Current_Id BIGINT, @Current_Ti VARCHAR(MAX)

OPEN P_CURSOR
FETCH NEXT FROM P_CURSOR INTO @Current_Id, @Current_Ti

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
	   +'Id=' + CAST(@Current_Id AS VARCHAR(20))
	   +'&count=1000'
	   +
	   '&attributes=Ti,Id,Y,D,CC,ECC,W,AA.AuN,AA.AuId,AA.AfN,AA.AfId,A.S,F.FN,F.FId,J.JN,J.JId,C.CN,C.CId,E'

	EXECUTE [CLRDB].[dbo].[HttpUtilities_HttpRequest] 
	   @Http_Method = 'GET'
	  ,@Request_URI = @Request_Value
	  ,@Request_Body = ''
	  ,@Request_Content_Type = ''
	  ,@Header_Values  = 'Ocp-Apim-Subscription-Key,edd1731c7e5d48a1ac3f057a41726bfd'
	  ,@Response_Body = @Response_Body OUTPUT 
	  ,@Response_Status_Code = @Response_Status_Code OUTPUT
	  ,@Response_Status_Code_Text = @Response_Status_Code_Text OUTPUT	

	IF (@Response_Status_Code = '200')
	BEGIN
		--SELECT @Response_Body, @Response_Status_Code, @Response_Status_Code_Text

		IF (NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = @Current_Id))
			INSERT INTO Papers_Academic_Info ([Paper_ID], [Paper_Name], [JSON_Acedemic_Info], Extended_Academic_Info)		
		SELECT @Current_Id, @Current_Ti, @Response_Body, Extended_Info.E
		FROM   OPENJSON(@Response_Body, '$.entities') AS J
			   CROSS JOIN OPENJSON(@Response_Body, '$.entities')
				WITH 
				(   
					E    NVARCHAR(MAX) '$.E' 
				) AS Extended_Info

	END
	ELSE
	BEGIN
		RAISERROR (@Response_Body, 16, 1)
	END

	FETCH NEXT FROM P_CURSOR INTO @Current_Id, @Current_Ti
END

CLOSE P_CURSOR
DEALLOCATE P_CURSOR