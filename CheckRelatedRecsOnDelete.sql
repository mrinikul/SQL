USE [FRS_Workforce]
GO
/****** Object:  Trigger [dbo].[CheckRelatedRecsOnDelete]    Script Date: 09/24/2018 17:36:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Irina Nik
-- Create date: 04/18/2016
-- Description:	Prevent delition if related recs exist 
-- =============================================
ALTER TRIGGER [dbo].[CheckRelatedRecsOnDelete] 
   ON  [dbo].[WorkForce]
   FOR DELETE
AS 
BEGIN 
	SET NOCOUNT ON;

	DECLARE @RecKey numeric 
	DECLARE @Msg varchar(max) = ''
	DECLARE @iRecCount INT = 0
	DECLARE @ApplNumb VARCHAR(7)
	
	DECLARE wCursor CURSOR FOR
		(SELECT RecKey, ApplNumb FROM deleted)
	
	OPEN wCursor

	FETCH NEXT FROM wCursor INTO @RecKey, @ApplNumb
	
	WHILE @@FETCH_STATUS = 0 OR @iRecCount<=50 
		BEGIN --1
			SET @iRecCount = @iRecCount + 1
			SET @Msg = 'ERROR MESSAGE from CheckRelatedRecsOnDelete TRIGGER: Related record found for Workforce.ApplNumb=' + @ApplNumb + ' and Workforce.RecKey=' + CONVERT(varchar,@RecKey) + ' '
			IF 	
				EXISTS (SELECT TOP 1 1 FROM WorkForceContinue	WHERE RecKey=@RecKey) 
				OR
				EXISTS (SELECT TOP 1 1 FROM WorkforceCalJOBS	WHERE RecKey=@RecKey) 
				OR
				EXISTS (SELECT TOP 1 1 FROM WIAApplSuppl		WHERE ApplRecKey=@RecKey) 
				OR
				EXISTS (SELECT TOP 1 1 FROM Section167Data		WHERE ApplRecKey=@RecKey) 
				OR
				EXISTS (SELECT TOP 1 1 FROM Enrollment			WHERE ApplicationNumber=@ApplNumb AND GrantCode<>'001')
				OR
				EXISTS (SELECT TOP 1 1 FROM Activity			WHERE ApplicationNumber=@ApplNumb AND GrantCode<>'001')
				OR
				EXISTS (SELECT TOP 1 1 FROM WIAExit			WHERE ApplicationNumber=@ApplNumb)
				OR
				EXISTS (SELECT TOP 1 1 FROM FollowUp			WHERE ApplicationNumber=@ApplNumb)
				BEGIN 
					SET @Msg = @Msg + 
						CASE 
							WHEN EXISTS (SELECT TOP 1 1 FROM WorkForceContinue WHERE RecKey=@RecKey) THEN ' in WorkForceContinue table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM WorkforceCalJOBS WHERE RecKey=@RecKey) THEN ' in WorkforceCalJOBS table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM WIAApplSuppl  WHERE ApplRecKey=@RecKey) THEN ' in WIAApplSuppl table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM Section167Data WHERE ApplRecKey=@RecKey) THEN ' in Section167Data table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM Enrollment WHERE ApplicationNumber=@ApplNumb AND GrantCode<>'001') THEN ' in Enrollment table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM Activity WHERE ApplicationNumber=@ApplNumb AND GrantCode<>'001') THEN ' in Activity table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM WIAExit WHERE ApplicationNumber=@ApplNumb) THEN ' in WIAExit table.'
							WHEN EXISTS (SELECT TOP 1 1 FROM FollowUp WHERE ApplicationNumber=@ApplNumb) THEN ' in FollowUp table.'
							ELSE ' in one of the related tables.'
						END 
					ROLLBACK TRAN
					RAISERROR (@Msg ,16,10)
				END 
			FETCH NEXT FROM wCursor INTO @RecKey, @ApplNumb
		END 
		CLOSE wCursor;
		DEALLOCATE wCursor;
END 

