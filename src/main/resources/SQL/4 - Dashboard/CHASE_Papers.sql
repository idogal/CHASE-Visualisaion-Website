USE [CHASE_Project]
GO

SELECT [Paper_Id]
      ,[Paper_API_Id]
      ,[Paper_Order]
      ,[Paper_Year]
      ,[Paper_Date]
      ,[Citations_Count]
      ,[Est_Citations_Count]
      ,[Display_Name]
      ,[Venue_Short_Name]
      ,[Venue_Full_Name]
      ,[DOI]
      ,[Abstract]
      ,[Abstract_Length]
      ,[Keywords]
      ,[Fields]
      ,[Authors]
  FROM [dbo].[CHASE_Papers__Papers_Details]
GO


