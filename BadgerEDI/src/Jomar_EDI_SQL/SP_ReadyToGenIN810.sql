/****** Object: Procedure [dbo].[edi_ReadyToGenIN810]   Script Date: 12/8/2011 1:09:51 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_ReadyToGenIN810]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_ReadyToGenIN810];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[edi_ReadyToGenIN810]
WITH EXEC AS CALLER
AS
-- show new invoices for which Invoice DB content XML should be generated
select 
otrk.JomarBizNum as BizNum, 
otrk.JomarPlantNum as PlantNum, 
otrk.CustomerSoldToID as CustomerNum,
otrk.JomarInvoiceNumber  as InvoiceNum
from edi_OrderTracking otrk
where (otrk.generateXML='A' or otrk.generateXML='I') 
    AND (otrk.JomarInvoiceNumber is not null and otrk.JomarInvoiceNumber<>'')
    AND otrk.OrderCancelled='N'
GO
