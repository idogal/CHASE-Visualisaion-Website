-- STEP A: Create a temporary table to hold the results --
----------------------------------------------------------
--DELETE FROM #PAIR_C_SCORES
--CREATE TABLE #PAIR_C_SCORES (Author_Name_1 VARCHAR(100), Author_Name_2 VARCHAR(100), C_Score SMALLINT);


-- STEP B: Run the coupling creation process            --
----------------------------------------------------------
DECLARE A_CURSOR CURSOR
FOR 
	SELECT ANAME1, ANAME2
	FROM   Authors_Pairs AS AP WHERE ANAME1 = 'meira levy' -- and ANAME2 = 'irit hadar'

DECLARE @ANAME1 VARCHAR(100), @ANAME2 VARCHAR(100);
DECLARE @C INT = 1;

OPEN A_CURSOR;
FETCH NEXT FROM A_CURSOR INTO @ANAME1, @ANAME2;

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	DECLARE @REF1 TABLE (REF_ID BIGINT);
	DECLARE @COUPLING SMALLINT;

	DELETE FROM @REF1;

	INSERT INTO @REF1 
	  SELECT R.Reference_ID 
	  FROM Papers_References AS R WHERE EXISTS (SELECT * FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID AND A.Author_Name = @ANAME1);

	-- All of the authors that author A has cited
	SET @COUPLING = 
	  (	SELECT COUNT(Author_Name) 
		FROM Authors 
		WHERE Author_Name = @ANAME2
			AND EXISTS (SELECT * FROM @REF1 AS R WHERE R.REF_ID = Authors.Paper_Id));

	IF @COUPLING > 0
	BEGIN
	   INSERT INTO #PAIR_C_SCORES
	   SELECT @ANAME1, @ANAME2, @COUPLING;
	END

	SET @C = @C + 1;
	PRINT @C;
	FETCH NEXT FROM A_CURSOR INTO @ANAME1, @ANAME2;
END

CLOSE A_CURSOR;
DEALLOCATE A_CURSOR;


-- STEP C: Get the data out                             --
----------------------------------------------------------
-- Edges
SELECT * FROM #PAIR_C_SCORES

-- Nodes
SELECT DISTINCT A.Author_Name_1, Author_Name_1
FROM  #PAIR_C_SCORES AS A
UNION 
SELECT DISTINCT A.Author_Name_2, Author_Name_2
FROM  #PAIR_C_SCORES AS A