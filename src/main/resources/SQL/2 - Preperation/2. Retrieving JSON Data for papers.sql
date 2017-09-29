DECLARE @Paper_Name VARCHAR(1000);
DECLARE @Paper_ID BIGINT;

DECLARE Papers_Cursor CURSOR FAST_FORWARD 
FOR
(
SELECT TOP (100) PERCENT
       ID, Paper_Name
FROM   [dbo].[Papers_List]
WHERE NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = [Papers_List].ID AND I.JSON_Acedemic_Info IS NOT NULL)
);

OPEN Papers_Cursor;
FETCH NEXT FROM Papers_Cursor INTO @Paper_ID, @Paper_Name;

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	DECLARE @Request_Value varchar(512);
	DECLARE @Output_Text varchar(8000);

	SET @Request_Value = 
	   'https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?' 
	   +
	   'expr=Id='
	   +
	   CAST(@Paper_ID AS VARCHAR(20))
	   +
	   '&attributes=Ti,Id,Y,D,CC,ECC,W,AA.AuN,AA.AuId,AA.AfN,AA.AfId,A.S,F.FN,F.FId,J.JN,J.JId,C.CN,C.CId'

	EXECUTE [CLRDB].dbo.[HttpUtilities_HttpGet_WithSubscriptionKey] 
	   @Http_URI = @Request_Value
	  ,@Subscription_Key = 'a11514bc0fca4e5386975a2027bb288f'
	  ,@Text_Response =  @Output_Text OUTPUT

    -- INSERT MODE, IF THATS THE FIRST RUN
	/*
    IF (NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = @Paper_ID))
		INSERT INTO Papers_Academic_Info ([Paper_ID], [Paper_Name], [JSON_Acedemic_Info])
		VALUES (@Paper_ID, @Paper_Name, @Output_Text); */

	-- UPDATE MODE
    IF (NOT EXISTS (SELECT * FROM Papers_Academic_Info AS I WHERE I.Paper_ID = @Paper_ID AND I.JSON_Acedemic_Info IS NOT NULL))
		UPDATE Papers_Academic_Info
		SET JSON_Acedemic_Info = @Output_Text
		WHERE Paper_ID = @Paper_ID;

	FETCH NEXT FROM Papers_Cursor INTO @Paper_ID, @Paper_Name;

	--WAITFOR DELAY '00:00:01';
END;

CLOSE Papers_Cursor;
DEALLOCATE Papers_Cursor;

--SELECT * FROM Papers_Academic_Info