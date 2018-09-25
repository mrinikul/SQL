
-- =============================================
-- Author:		Irina Eva
-- Create date: 12/07/2017
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[v2_fn_CreateErNumber] ()
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @er_num INT

	-- Add the T-SQL statements to compute the return value here
	
	DECLARE @minEr_num INT = 1
	DECLARE @maxEr_num INT = ISNULL((SELECT MAX(er_num) FROM er),1) + 1
	DECLARE @minEr_numFound INT = ISNULL((SELECT MIN(er_num) FROM er),1)
	IF @minEr_num < @minEr_numFound
		SET @maxEr_num = @minEr_numFound

	SET @er_num =
		(
		SELECT TOP 1 rowNumber FROM 
			(
			SELECT ROW_NUMBER() OVER (ORDER BY er_num) + @minEr_num - 1 rowNumber, er_num
			FROM er WHERE er_num BETWEEN @minEr_num AND @maxEr_num
			) t
		WHERE rowNumber<>CONVERT(BIGINT,er_num)
		ORDER BY rowNumber,er_num
		)

	IF @er_num IS NULL
		IF NOT EXISTS(SELECT TOP 1 1 FROM er WHERE er_num = @minEr_num)
			SET @er_num = @minEr_num
		ELSE
			SET @er_num = @maxEr_num
	

	-- Return the result of the function
	RETURN @er_num

END

