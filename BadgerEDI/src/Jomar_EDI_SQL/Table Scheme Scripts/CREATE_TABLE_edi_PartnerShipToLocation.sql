/****** Object: Table [dbo].[edi_PartnerShipToLocation]   Script Date: 12/8/2011 1:13:43 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_PartnerShipToLocation]') AND type in (N'U'))
BEGIN
DROP TABLE [ee8idbbdt].[dbo].[edi_PartnerShipToLocation];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [dbo].[edi_PartnerShipToLocation] (
[PartnerID] varchar(50) NOT NULL,
[ID] varchar(50) NOT NULL,
[Name] varchar(50) NULL,
[AddressLine1] varchar(50) NULL,
[AddressLine2] varchar(50) NULL,
[City] varchar(50) NULL,
[State] varchar(30) NULL,
[Zip] varchar(10) NULL,
[Country] varchar(50) NULL,
[Phone] varchar(20) NULL,
[Category] varchar(50) NOT NULL DEFAULT ('*'))
ON [PRIMARY];
GO

