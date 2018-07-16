/****** Object: Procedure [dbo].[edi_GetLastOrderNumber]   Script Date: 12/8/2011 1:09:15 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_GetLastOrderNumber]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_GetLastOrderNumber];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create procedure [dbo].[edi_GetLastOrderNumber] AS
select ORDERNUMBER FROM bdg_tblWebOrderSequence

GO
