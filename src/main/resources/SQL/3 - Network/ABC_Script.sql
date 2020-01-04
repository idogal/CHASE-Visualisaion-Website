-- STEP A: Create a temporary table to hold the results --
----------------------------------------------------------
--DELETE FROM ##PAIR_BC_INTERMEDIATE_SCORES
--DELETE FROM ##PAIR_BC_SCORES
--CREATE TABLE ##PAIR_BC_INTERMEDIATE_SCORES (Author_Name_1 VARCHAR(100), Author_Name_2 VARCHAR(100), REF_ID BIGINT, BC_Score SMALLINT);
--CREATE TABLE ##PAIR_BC_SCORES (Author_Name_1 VARCHAR(100), Author_Name_2 VARCHAR(100), BC_Score SMALLINT);

-- STEP B: Run the coupling creation process            --
----------------------------------------------------------
DECLARE A_CURSOR CURSOR
FOR 
	SELECT ANAME1, ANAME2
	FROM   Authors_Pairs AS AP
	WHERE EXISTS 
	      (SELECT * 
		   FROM   Authors_References AS AR WHERE AR.Author_Name = AP.ANAME2
		   AND    AR.Reference_ID IN 
	      (SELECT AR.Reference_ID FROM Authors_References AS AR WHERE AR.Author_Name = AP.ANAME1))
	--AND  ANAME2 = 'a cesar c franca' AND ANAME1 = 'jingdong jia';

DECLARE @ANAME1 VARCHAR(100), @ANAME2 VARCHAR(100);

OPEN A_CURSOR;
FETCH NEXT FROM A_CURSOR INTO @ANAME1, @ANAME2;

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	DECLARE @REF1 TABLE (REF_ID BIGINT);
	DECLARE @REF2 TABLE (REF_ID BIGINT);
	DECLARE @REF_BOTH TABLE (REF_ID BIGINT);
	DECLARE @PAPERS_BOTH TABLE (PID BIGINT);
	DECLARE @PAIR_RESULT TABLE (REF_ID BIGINT, COUPLING SMALLINT);

	DELETE FROM @REF1;
	DELETE FROM @REF2;
	DELETE FROM @REF_BOTH;
	DELETE FROM @PAPERS_BOTH;
	DELETE FROM @PAIR_RESULT;

	INSERT INTO @REF1 
	  SELECT R.Reference_ID 
	  FROM Papers_References AS R WHERE EXISTS (SELECT * FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID AND A.Author_Name = @ANAME1);

	INSERT INTO @REF2 
	  SELECT R.Reference_ID 
	  FROM Papers_References AS R WHERE EXISTS (SELECT * FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID AND A.Author_Name = @ANAME2);

	INSERT INTO @PAPERS_BOTH
	  SELECT PD.Paper_API_Id
	  FROM   Papers_Details AS PD
	  WHERE  @ANAME1 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = PD.Paper_API_Id)
	         AND 
			 @ANAME2 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = PD.Paper_API_Id)

	  SELECT PD.Paper_API_Id
	  FROM   Papers_Details AS PD
	  WHERE  @ANAME1 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = PD.Paper_API_Id)
	         AND 
			 @ANAME2 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = PD.Paper_API_Id)

	INSERT INTO @REF_BOTH
		SELECT *
		FROM 
		(
		SELECT REF_ID FROM @REF1
		INTERSECT
		SELECT REF_ID FROM @REF2
		) AS R
		WHERE NOT EXISTS (SELECT * FROM Papers_References AS R2 WHERE R2.Paper_ID IN (SELECT PID FROM @PAPERS_BOTH) AND R2.Reference_ID = R.REF_ID)
 
 		SELECT *
		FROM 
		(
		SELECT REF_ID FROM @REF1
		INTERSECT
		SELECT REF_ID FROM @REF2
		) AS R
		WHERE NOT EXISTS (SELECT * FROM Papers_References AS R2 WHERE R2.Paper_ID IN (SELECT PID FROM @PAPERS_BOTH) AND R2.Reference_ID = R.REF_ID)

    INSERT INTO @PAIR_RESULT
		SELECT RB.REF_ID, CASE WHEN N1 < N2 THEN N1 ELSE N2 END AS N
		FROM   @REF_BOTH AS RB
			   CROSS APPLY 
			   (
				SELECT COUNT(*) AS N1
				FROM   Papers_References AS R
				WHERE  R.Reference_ID = RB.REF_ID 
					   AND @ANAME1 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID)
					   AND EXISTS (SELECT * FROM Papers_Details AS PD WHERE PD.Paper_API_Id = R.Paper_Id AND PD.Paper_Order = 1)
			   ) AS C1
			   CROSS APPLY 
			   (
				SELECT COUNT(*) AS N2
				FROM   Papers_References AS R
				WHERE  R.Reference_ID = RB.REF_ID 
					   AND @ANAME2 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID)
					   AND EXISTS (SELECT * FROM Papers_Details AS PD WHERE PD.Paper_API_Id = R.Paper_Id AND PD.Paper_Order = 1)
			   ) AS C2;

		SELECT RB.REF_ID, CASE WHEN N1 < N2 THEN N1 ELSE N2 END AS N
		FROM   @REF_BOTH AS RB
			   CROSS APPLY 
			   (
				SELECT COUNT(*) AS N1
				FROM   Papers_References AS R
				WHERE  R.Reference_ID = RB.REF_ID 
					   AND @ANAME1 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID)
					   AND EXISTS (SELECT * FROM Papers_Details AS PD WHERE PD.Paper_API_Id = R.Paper_Id AND PD.Paper_Order = 1)
			   ) AS C1
			   CROSS APPLY 
			   (
				SELECT COUNT(*) AS N2
				FROM   Papers_References AS R
				WHERE  R.Reference_ID = RB.REF_ID 
					   AND @ANAME2 IN (SELECT A.Author_Name FROM Authors AS A WHERE A.Paper_Id = R.Paper_ID)
					   AND EXISTS (SELECT * FROM Papers_Details AS PD WHERE PD.Paper_API_Id = R.Paper_Id AND PD.Paper_Order = 1)
			   ) AS C2;

	INSERT INTO ##PAIR_BC_INTERMEDIATE_SCORES
	    SELECT @ANAME1, @ANAME2, REF_ID, COUPLING
		FROM   @PAIR_RESULT;

	INSERT INTO ##PAIR_BC_SCORES
		SELECT @ANAME1, @ANAME2, SUM(COUPLING) AS BC_SCORE
		FROM   @PAIR_RESULT;

	FETCH NEXT FROM A_CURSOR INTO @ANAME1, @ANAME2;
END

CLOSE A_CURSOR;
DEALLOCATE A_CURSOR;


-- STEP C: Get the data out                             --
----------------------------------------------------------

--SELECT * 
--FROM   ##PAIR_BC_INTERMEDIATE_SCORES

-- Edges
SELECT S.Author_Name_1, Author_Name_2, BC_Score, 'Undirected'
FROM   ##PAIR_BC_SCORES AS S
WHERE  BC_Score IS NOT NULL

-- Nodes
SELECT DISTINCT Author_Name_1, Author_Name_1
FROM   ##PAIR_BC_SCORES

UNION

SELECT DISTINCT Author_Name_2, Author_Name_2
FROM   ##PAIR_BC_SCORES
