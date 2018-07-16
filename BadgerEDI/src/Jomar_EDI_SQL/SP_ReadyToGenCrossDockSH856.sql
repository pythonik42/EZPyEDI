/****** Object: Procedure [dbo].[edi_ReadyToGenCrossDockSH856]   Script Date: 12/8/2011 1:09:34 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_ReadyToGenCrossDockSH856]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_ReadyToGenCrossDockSH856];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[edi_ReadyToGenCrossDockSH856]
WITH EXEC AS CALLER
AS
-- show new CrossDock MBOLs for which ASN DB content XML should be generated
select distinct
otrk.JomarBizNum as BizNum, 
otrk.JomarPlantNum as PlantNum, 
otrk.CustomerSoldToID as CustomerNum,
otrk.MasterBOLNumber as MBOLNum
from edi_OrderTracking otrk
where otrk.ShipType='CD'   -- only consolidated Cross Dock orders
    AND (otrk.generateXML='A' or otrk.generateXML='S')
    AND (otrk.JomarInvoiceNumber is not null and otrk.JomarInvoiceNumber<>'') -- must have been invoiced within Jomar
    AND (otrk.MasterBOLNumber is not null and otrk.MasterBOLNumber<>'')       -- MBOL WILL BE set when these orders are ready to ship
GO
