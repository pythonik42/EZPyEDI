/****** Object: Table [dbo].[edi_OrderTracking]   Script Date: 12/8/2011 1:14:12 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_OrderTracking]') AND type in (N'U'))
BEGIN
DROP TABLE [ee8idbbdt].[dbo].[edi_OrderTracking];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [dbo].[edi_OrderTracking] (
[JomarBizNum] varchar(3) NOT NULL DEFAULT ('001'),
[JomarPlantNum] varchar(2) NOT NULL DEFAULT ('01'),
[CustomerPO] varchar(10) NOT NULL,
[CustomerPOType] varchar(2) NULL,
[CustomerSoldToID] varchar(6) NOT NULL,
[CustomerShipToLocation] varchar(10) NULL,
[CrossDockLocID] varchar(10) NULL,
[MasterBOLNumber] varchar(40) NULL,
[JomarOrderType] varchar(2) NOT NULL DEFAULT ('SO'),
[JomarOrderNumber] varchar(10) NOT NULL,
[JomarInvoiceNumber] varchar(10) NULL,
[ShipType] varchar(10) NOT NULL DEFAULT ('DS'),
[DateASNSent] decimal(8, 0) NULL,
[DateInvoiceSent] decimal(8, 0) NULL,
[DatePOReceived] decimal(8, 0) NOT NULL,
[OrderCancelled] char(1) NOT NULL,
[OrderClosed] char(1) NOT NULL DEFAULT ('N'),
[GenerateXML] char(1) NOT NULL DEFAULT ('A'))
ON [PRIMARY];
GO

