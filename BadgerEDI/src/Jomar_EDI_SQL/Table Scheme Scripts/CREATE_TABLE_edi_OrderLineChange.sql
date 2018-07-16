/****** Object: Table [dbo].[edi_OrderLineChange]   Script Date: 12/8/2011 1:14:27 PM ******/


/***************************************************************************************  
 * NOT USED
 */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_OrderLineChange]') AND type in (N'U'))
BEGIN
DROP TABLE [ee8idbbdt].[dbo].[edi_OrderLineChange];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [dbo].[edi_OrderLineChange] (
[VIHR] varchar(15) NOT NULL,
[VKDR] varchar(10) NOT NULL,
[VCOSEQ] varchar(50) NOT NULL,
[VANR] varchar(20) NOT NULL,
[VPOLICHTP] varchar(10) NULL,
[VMGS] decimal(13, 5) NULL,
[VQLTR] decimal(13, 5) NULL,
[VUOM] varchar(3) NULL,
[VPR1] decimal(13, 5) NULL,
[VPRDTXT] varchar(80) NULL,
[VCLRTXT] varchar(80) NULL,
[VSIZTXT] varchar(80) NULL,
[VCLRREQTXT] varchar(80) NULL)
ON [PRIMARY];
GO