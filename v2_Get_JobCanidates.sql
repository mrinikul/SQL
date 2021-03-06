USE [FRS_Workforce]
GO
/****** Object:  StoredProcedure [dbo].[v2_Get_JobCanidates]    Script Date: 09/13/2018 13:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Irina NIK 
-- Create date: 02/22/2012
-- Description: Searches for job canidates
-- =============================================
ALTER PROCEDURE [dbo].[v2_Get_JobCanidates](
	@SubgName VARCHAR(3),
	@SearchStr NVARCHAR(100),
	@StaffID VARCHAR(10)= NULL ,
	@SearchEmploymentHistory VARCHAR(3)='YES',
	@SearchJobGoals VARCHAR(3)='YES'
)
AS
BEGIN
	DECLARE @JobGoalsWeight float;
	SET @JobGoalsWeight = .25;
	IF @SearchStr=''
		SET @SearchStr='';
	IF @StaffID = ''
		SET @StaffID = NULL;
	IF @SearchEmploymentHistory=''
		SET @SearchEmploymentHistory='YES';
	IF @SearchJobGoals=''
		SET @SearchJobGoals='YES';
	SELECT TOP 50
		Workforce.RecKey,
		Workforce.SubgName,
		Workforce.ApplNumb,
		Workforce.FirstName,
		WorkForce.LastName,
		Workforce.IntervID,
		Workforce.RevID,
		Workforce.CaseManagerID,
		Workforce.CoCaseManagerID,
		ISNULL(MAX(EmploymentHistory.[rank]), 0) AS MAX_EPYSS_Emp_History_Search_Results_RANK,
		ISNULL(MAX(JobGoals.[rank]), 0) * @JobGoalsWeight AS MAX_IEPYSS_Goals_Search_Results_RANK
	FROM
		Workforce
	JOIN
		Enrollment
	ON
		Enrollment.SubgranteeName = @SubgName
		AND
		Workforce.ApplNumb = Enrollment.ApplicationNumber
LEFT JOIN
	(
	SELECT DISTINCT
		EH_SubgName,
		EH_ApplNumb,
		IEPYSS_Emp_History_Search_Results.RANK AS [rank]
	FROM
		IEPYSS_Emp_History
	LEFT JOIN
		FREETEXTTABLE 
		(
		IEPYSS_Emp_History, JobTitle, @SearchStr
		) AS IEPYSS_Emp_History_Search_Results
	ON 
		IEPYSS_Emp_History.EH_RecKey = IEPYSS_Emp_History_Search_Results.[Key]
	WHERE
	(
	@SearchEmploymentHistory = 'YES'
	OR
	IEPYSS_Emp_History.JobTitle = @SearchEmploymentHistory
	)
	AND
	IEPYSS_Emp_History_Search_Results.RANK > 0
	) AS EmploymentHistory
	ON
		EmploymentHistory.EH_SubgName = @SubgName
		AND
		WorkForce.ApplNumb = EmploymentHistory.EH_ApplNumb
	LEFT JOIN
	(
	SELECT DISTINCT
		IEPYSS.IEP_SubgName,
		IEPYSS.IEP_ApplNumb,
		IEPYSS_Search_Results.RANK AS [rank]
	FROM
		IEPYSS
	LEFT JOIN
		FREETEXTTABLE 
			( 
			IEPYSS, (IEP_EG_PrimaryGoalJobTitle, IEP_EG_SecondaryGoalJobTitle, IEP_EG_ThirdGoalJobTitle), @SearchStr 
			) AS IEPYSS_Search_Results
	ON IEPYSS.IEP_RecKey = IEPYSS_Search_Results.[Key]
	) AS JobGoals
	ON
		JobGoals.IEP_SubgName = @SubgName
		AND
		WorkForce.ApplNumb = JobGoals.IEP_ApplNumb
	LEFT JOIN
		WiaExit
	ON
		WorkForce.ApplNumb = WiaExit.ApplicationNumber
	AND
		WiaExit.SubgName = @SubgName
	WHERE
		WiaExit.ApplicationNumber is null
	AND
		Enrollment.GrantCode <> '001'
	GROUP BY
		Workforce.RecKey,
		Workforce.SubgName,
		Workforce.ApplNumb,
		Workforce.FirstName,
		WorkForce.LastName,
		Workforce.IntervID,
		Workforce.RevID,
		Workforce.CaseManagerID,
		Workforce.CoCaseManagerID
	HAVING
		(
		ISNULL(MAX(EmploymentHistory.[rank]), 0) + ISNULL(MAX(JobGoals.[rank]), 0) > 1
		)
	ORDER BY
		(ISNULL( MAX(JobGoals.[rank]), 0) * @JobGoalsWeight) + ISNULL( MAX(EmploymentHistory.[rank]), 0) DESC
END
