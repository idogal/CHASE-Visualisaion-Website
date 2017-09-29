	DECLARE @Request_Value VARCHAR(4000);
	DECLARE @Output_Text   NVARCHAR(MAX);

	SET @Request_Value = 
	   'https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?' 
	   +
	   'expr='
	   +'Composite(C.CN=''re'')'
	   +'&count=1000'
	   +
	   '&attributes=Ti,Id,Y,D,CC,ECC,W,AA.AuN,AA.AuId,AA.AfN,AA.AfId,A.S,F.FN,F.FId,J.JN,J.JId,C.CN,C.CId'


	   --PRINT @Request_Value

	EXECUTE [CLRDB].dbo.[HttpUtilities_HttpGet_WithSubscriptionKey] 
	   @Http_URI = @Request_Value
	  ,@Subscription_Key = 'a11514bc0fca4e5386975a2027bb288f'
	  ,@Text_Response =  @Output_Text OUTPUT

	  --SELECT @Output_Text

	INSERT INTO [Papers_List] (ID, [Paper_Name], [Conference_Year])
		SELECT  --ROW_NUMBER() OVER (ORDER BY P_Date ASC), 
		        ID,
				Title, P_Year
		FROM    OPENJSON(@Output_Text, '$.entities')
				WITH 
				(   
					Title    VARCHAR(100) '$.Ti',  
					ID    VARCHAR(100) '$.Id',  
					P_Year    CHAR(4) '$.Y',  
					P_Date DATETIME '$.D',
					P_CC   INT  '$.CC',
					P_ECC   INT  '$.ECC'
				 ) AS Papers;