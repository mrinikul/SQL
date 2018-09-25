
-- =============================================
-- Author:		Irina Eva
-- Create date: 12/07/2017
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[v2_fn_CreateApplNumber]
(
	-- Add the parameters for the function here

)
RETURNS VARCHAR(7)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @newApplNumb VARCHAR(7) = ''

	-- Add the T-SQL statements to compute the return value here
	DECLARE @minAppl VARCHAR(7) = '2000000'
	DECLARE @maxAppl VARCHAR(7) = '2999999' 
	

	DECLARE @minApplFound VARCHAR(7) = (SELECT MIN(ApplNumb) FROM Workforce WHERE CONVERT(INT,ApplNumb) BETWEEN CONVERT(INT,@minAppl) AND CONVERT(INT,@maxAppl))
	IF @minApplFound <> @minAppl
		SET @maxAppl = @minApplFound

	DECLARE @rowNumber BIGINT =
		(
		SELECT TOP 1 rowNumber FROM 
			(
			SELECT ROW_NUMBER() OVER (ORDER BY ApplNumb)+CONVERT(INT,@minAppl)-1 rowNumber, ApplNumb
			FROM Workforce 
			WHERE CONVERT(INT,ApplNumb) BETWEEN CONVERT(INT,@minAppl) AND CONVERT(INT,@maxAppl)
			) t
		WHERE rowNumber<>CONVERT(BIGINT,ApplNumb)
		ORDER BY rowNumber,ApplNumb
		)

	IF @rowNumber IS NULL
		IF NOT EXISTS(SELECT 1 FROM Workforce WHERE ApplNumb=@minAppl)
			SET @newApplNumb = @minAppl
		ELSE IF NOT EXISTS(SELECT 1 FROM Workforce WHERE ApplNumb=@maxAppl)
			SET @newApplNumb = @maxAppl
		ELSE
			SET @newApplNumb = ''
	ELSE
		SET @newApplNumb = CONVERT(VARCHAR(7), @rowNumber)
		
	--IF @newApplNumb = ''
	--	RAISERROR ('ERROR from v2_fn_CreateApplNumb - Cant create new ApplNumb',-1,-1 ); 
		
	--SELECT @newApplNumb newApplNumb
	--SELECT * FROM WorkForce where ApplNumb=@newApplNumb

	-- Return the result of the function
	RETURN @newApplNumb

END

