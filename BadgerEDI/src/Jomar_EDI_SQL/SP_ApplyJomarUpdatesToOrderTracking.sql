/****** Object: Procedure [dbo].[edi_ApplyJomarUpdatesToOrderTracking]   Script Date: 12/8/2011 1:07:02 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_ApplyJomarUpdatesToOrderTracking]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_ApplyJomarUpdatesToOrderTracking];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[edi_ApplyJomarUpdatesToOrderTracking]
WITH EXEC AS CALLER
AS
-- update cancelled SOs
update edi_OrderTracking
SET
  OrderCancelled = 'Y',
  OrderClosed = 'Y'
where (select count(*) 
       from TXUYUF01 sl 
       where JomarBizNum=sl.VBNR and JomarPlantNum=sl.VPLT 
       and JomarOrderType=sl.VBLA and JomarOrderNumber=sl.VBLN
       and not (sl.VERA='E' and sl.VMGL=0))=0
       
-- update SOs where all line items are currently closed, but some items have been shipped
-- note: a SO may be 're-opened' by adding to qtyOrdered in a line 
update edi_OrderTracking
SET
  OrderClosed = 'Y'
where (select count(*) 
       from TXUYUF01 sl 
       where (OrderCancelled is Null or OrderCancelled <> 'Y') 
       and JomarBizNum=sl.VBNR and JomarPlantNum=sl.VPLT 
       and JomarOrderType=sl.VBLA and JomarOrderNumber=sl.VBLN
       and not (sl.VERA='E' and sl.VMGL=sl.VMGS))=0

-- update MasterBOL values set through Jomar for all open orders (i.e. not closed)
update edi_OrderTracking
SET
  MasterBOLNumber = ps.LMBLN
FROM edi_OrderTracking ot, txuyls00 ps
where (ot.OrderClosed is Null or ot.OrderClosed <> 'Y') 
and ot.JomarBizNum=ps.LBNR and ot.JomarPlantNum=ps.LPLT 
and ot.JomarOrderType=ps.LSART and ot.JomarOrderNumber=ps.LBLN
and (ps.LBACK is null or ps.LBACK <> 'Y') -- skip cancelled packing slips
and (ps.LMBLN is not null and ps.LMBLN <> '')

-- update InvoiceNums where Orders have been invoiced 
update edi_OrderTracking
SET
  JomarInvoiceNumber = ps.LRNR
from edi_OrderTracking otrk
join TXUYLS00 ps ON (otrk.JomarBizNum=ps.LBNR and otrk.JomarPlantNum=ps.LPLT 
    and otrk.JomarOrderType=ps.LSART and otrk.JomarOrderNumber=ps.LBLN)
where (otrk.generateXML='A' or otrk.generateXML='S') 
    AND (ps.LBACK is null or ps.LBACK <> 'Y') -- don't use cancelled packing slips
    
-- set MasterBOL values for CrossDock Orders when all non-cancelled/closed orders in 
-- the parent PO have been invoiced by Jomar and are ready to ship.
update edi_OrderTracking
SET
  MasterBOLNumber = 'XD-'+ot.CustomerPOType+rtrim(ot.CustomerPO)
FROM edi_OrderTracking ot
where ot.ShipType='CD' 
and (ot.OrderCancelled is not Null and ot.OrderCancelled<>'Y') 
and (ot.DateASNSent is null or ot.DateASNSent=0)
and (ot.JomarInvoiceNumber is not null and ot.JomarInvoiceNumber<>'')
and not exists (select *
      from edi_OrderTracking ot2 
      where ot2.CustomerSoldToID=ot.CustomerSoldToID
      and ot2.JomarBizNum=ot.JomarBizNum 
      and ot2.JomarPlantNum=ot.JomarPlantNum
      and ot2.CustomerPOType=ot.CustomerPOType
      and ot2.CustomerPO=ot.CustomerPO
      and ot.OrderClosed<>'Y' 
      and ot.OrderCancelled<>'Y' 
      and (ot2.JomarInvoiceNumber is null or ot2.JomarInvoiceNumber=''))
GO
