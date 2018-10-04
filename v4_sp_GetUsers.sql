USE [FRS_ITrain]
GO

/****** Object:  StoredProcedure [dbo].[v4_sp_GetUsers]    Script Date: 10/03/2018 17:10:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Irina NIK
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[v4_sp_GetUsers]
	-- Add the parameters for the stored procedure here
	(
	@PageNumber AS INT, 
	@RowspPage AS INT,
	@sortBy varchar(25)=''
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @NumberOfPages INT = 0
	--SET @NumberOfPages = (SELECT COUNT(RecKey) FROM dbo.v4_view_Syspass)/@RowspPage

	IF @RowspPage=0
		SET @RowspPage = (SELECT COUNT(1) FROM dbo.v4_view_Syspass)
	    
	SELECT 
		RecKey, 
		[user_id], 
		[user_name], 
		location, 
		user_stat, 
		user_super_right, 
		user_email, 
		position, 
		user_mail_addr1, 
		user_mail_addr2, 
		AgencyCode, 
		CaseManNum, 
		Phone, 
		Fax, 
		Subgrante_cd, 
		keyboard, 
		Superv_ID, 
		Superv_Email, 
		[Signature]
	FROM
	(
		SELECT ROW_NUMBER() OVER(ORDER BY 
			CASE WHEN @sortBy='descUserId' THEN [user_id] END DESC,
			CASE WHEN @sortBy='ascUserName' THEN [user_name] END ASC,
			CASE WHEN @sortBy='descUserName' THEN [user_name] END DESC,
			[user_id] ASC
			) AS NUMBER,
			*
		FROM         
			dbo.v4_view_Syspass
		) syspass
	WHERE 
		NUMBER BETWEEN ((@PageNumber - 1) * @RowspPage + 1) AND (@PageNumber * @RowspPage)
	ORDER BY 
		CASE WHEN @sortBy='descUserId' THEN [user_id] END DESC,
		CASE WHEN @sortBy='ascUserName' THEN [user_name] END ASC,
		CASE WHEN @sortBy='descUserName' THEN [user_name] END DESC,
		[user_id] ASC
	END

GO


