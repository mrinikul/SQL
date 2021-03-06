USE [FRS_ITrain]
GO
/****** Object:  StoredProcedure [dbo].[v4_sp_AddSyspass]    Script Date: 10/03/2018 17:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Irina NIK
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[v4_sp_AddSyspass]
	-- Add the parameters for the stored procedure here
	(
		@Reckey numeric = NULL,
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
	INSERT
		syspass
	(
		[user_id] ,
		[user_name],
		location ,
		VendorId,
		user_stat ,
		user_super_right ,
		user_email ,
		position ,
		CaseManNum ,
		[Signature] 
	)
	VALUES
	(
		@user_id ,
		@user_name,
		@location ,
		@VendorId,
		@user_stat ,
		@user_super_right ,
		@user_email ,
		@position ,
		@CaseManNum ,
		@Signature 
	)
	
	SELECT * FROM syspass WHERE Reckey = SCOPE_IDENTITY()  
END
