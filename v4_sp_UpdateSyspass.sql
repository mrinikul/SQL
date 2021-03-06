USE [FRS_ITrain]
GO
/****** Object:  StoredProcedure [dbo].[v4_sp_UpdateSyspass]    Script Date: 10/03/2018 17:11:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Irina NIK
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[v4_sp_UpdateSyspass]
	-- Add the parameters for the stored procedure here
	(
		@Reckey numeric,
		@user_id varchar(50),
		@user_name varchar(50),
		@location varchar(50),
		@VendorId varchar(15),
		@user_stat varchar(5),
		@user_super_right varchar(1),
		@user_email varchar(150),
		@position varchar(2),
		@CaseManNum varchar(10),
		@Signature varchar(25)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE
		syspass
	SET
		--[user_id]=@user_id ,
		[user_name]=@user_name,
		location=@location ,
		VendorId=@VendorId,
		user_stat=@user_stat ,
		user_super_right=@user_super_right ,
		user_email=@user_email ,
		position=@position ,
		CaseManNum=@CaseManNum ,
		[Signature]=@Signature 
	WHERE 
		Reckey=@Reckey
		
	SELECT * FROM syspass WHERE Reckey=@Reckey
END
