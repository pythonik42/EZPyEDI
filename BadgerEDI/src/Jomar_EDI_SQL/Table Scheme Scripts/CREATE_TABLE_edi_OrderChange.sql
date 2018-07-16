/****** Object: Table [dbo].[edi_OrderChange]   Script Date: 12/8/2011 1:15:02 PM ******/


/***************************************************************************************  
 * NOT USED
 */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_OrderChange]') AND type in (N'U'))
BEGIN
DROP TABLE [ee8idbbdt].[dbo].[edi_OrderChange];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [dbo].[edi_OrderChange] (
[UIHR] varchar(15) NOT NULL,
[UKDR] varchar(10) NOT NULL,
[UCOSEQ] varchar(10) NOT NULL,
[UPOCHTP] varchar(10) NULL,
[UPOREL] varchar(10) NULL,
[UDAT] decimal(8, 0) NULL,
[UDATCH] decimal(8, 0) NULL,
[UFOBCS] varchar(80) NULL,
[UFOBSD] varchar(80) NULL,
[UFOBSPO] varchar(80) NULL,
[UTOSDP] varchar(5) NULL,
[UTOSDDD] varchar(5) NULL,
[UTOSTXT] varchar(80) NULL,
[UDATRE] decimal(8, 0) NULL,
[UENT] decimal(8, 0) NULL,
[UCARCD] varchar(80) NULL,
[UCARTXT] varchar(80) NULL)
ON [PRIMARY];
GO

