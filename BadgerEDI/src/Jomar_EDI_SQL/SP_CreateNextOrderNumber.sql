/****** Object: Procedure [dbo].[edi_CreateNextOrderNumber]   Script Date: 12/8/2011 1:07:21 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_CreateNextOrderNumber]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_CreateNextOrderNumber];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create procedure [dbo].[edi_CreateNextOrderNumber] AS
update bdg_tblWebOrderSequence set OrderNumber = OrderNumber + 1

GO
