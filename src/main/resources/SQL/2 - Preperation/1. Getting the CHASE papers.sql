	CREATE TABLE ##CHASE_PAPERS_LIST (Id BIGINT, Ti VARCHAR(MAX))
	
	DECLARE @Request_Value VARCHAR(4000);
	DECLARE @Response_Body  NVARCHAR(MAX);
	DECLARE @Response_Status_Code   NVARCHAR(100);
	DECLARE @Response_Status_Code_Text   NVARCHAR(1000);

	SET @Request_Value = 
	   'https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?' 
	   +
	   'expr='
	   +'And(Composite(C.CN=''icse''), Y=2017)'
	   --+'Ti=''using gamification to orient and motivate students to contribute to oss projects'''
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

		INSERT INTO ##CHASE_PAPERS_LIST (Id, Ti)
		(
		SELECT Extended_Info.Id, Extended_Info.Ti
		FROM   OPENJSON(@Response_Body, '$.entities')
				WITH 
				(   
					Id   NVARCHAR(MAX) '$.Id',
					Ti   NVARCHAR(MAX) '$.Ti',
					E    NVARCHAR(MAX) '$.E' 
				) AS Extended_Info
				CROSS APPLY OPENJSON(Extended_Info.E, '$') AS Extended_Info_Objects
		WHERE   Extended_Info_Objects.[key] = 'DOI' AND Extended_Info_Objects.[value] like '%CHASE.2017%'
		)
	END
	ELSE
	BEGIN
		RAISERROR (@Response_Body, 16, 1)
	END

