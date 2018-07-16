-- get JoCarrierCodes
SELECT 
RIGHT(axanr,LEN(axanr)-2) as JoCarrierCode,
axtxt                     as Name
FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like'#C%'

select SPGRP from TXUYKD00 where KKDN='000151'  -- Customer BillTo ID

-- selects all pricing records for customer BillTo ID specified in kkdn
select top 50 byr.kkdn, prc.* 
from TXUYKD00 byr, GNPSPC12 prc 
where byr.kkdn='000151'   -- Sports Supply Group
and (byr.KGR1=prc.SPGRP or prc.SPGRP=byr.KGR1)


exec dbo.edi_GenShippingNoticeXML '130630494', 'ZZ', null, 'XD-SA0071573333', 'T'
exec dbo.edi_GenShippingNoticeXML 'SPSMCX', 'ZZ', '0000756378', null, 'P'

-- psi.L1mgl
FROM txuyls01 psi
WHERE psi.L1lfn = '10' and psi.L1sart = 'SO' AND psi.L1bln = '0000016146'
  AND psi.L1bnr = '001' AND psi.L1plt = '01' AND (psi.L1rnr is NULL or psi.L1rnr <> 'TRANSFER')
  
-- show new invoices to be processed by EDI
-- select ps.LBLN as OrderNum, ps.LRNR as InvoiceNum, otrk.CustomerSoldToID as CustomerNum, otrk.MasterBOLNumber MasterBOL, otrk.generateXML GenXML, ps.*
select  ps.LRNR as InvoiceNum, otrk.JomarOrderNumber as OrderNum, otrk.CustomerSoldToID as CustomerNum, otrk.MasterBOLNumber MasterBOL, otrk.generateXML GenXML, inv.*, ps.LBACK
from edi_OrderTracking otrk
join TXUYLS00 ps ON (otrk.JomarOrderNumber=ps.LBLN)
join TXUYRE00 inv ON (ps.LRNR=inv.Rrnr AND ps.Lbln = inv.Rbln 
      AND ps.Lrnr = inv.Rrnr AND ps.Lplt = inv.Rplt)
--where (ps.LBACK is null or ps.LBACK <> 'Y')
--and (inv.RBACK is null or inv.RBACK <> 'Y')

select * from TXUYUV10 where ubln>='0000031358' and ubln<='0000031369' 
select * from TXUYUF12 where vbln>='0000031358' and vbln<='0000031369' 

select * from TXUYUV10 where ukdn = '015991'
select * from TXUYUF12 where vbln>='0000030465' and vbln<='0000099999' 

delete from TXUYUV10 where ubln>='0000002683' and ubln<='0000002684' 
delete from TXUYUF12 where vbln>='0000002683' and vbln<='0000002684' 

-- show all SOs ready to be loaded
select * from TXUYUV10
select * from TXUYUF12 

-- delete all SOs ready to be loaded
delete from TXUYUV10
delete from TXUYUF12

-- to show load errors for bulk order load process
select ubln, uihr, ubla, ubnr, ukdn, ukdr, uerr1, uerr2, uerr3, uerr4 from TXUYUV10
select vbln, vanr, vkdl, vmgs, verr1, verr2, verr3, verr4, verr5 from TXUYUF12

-- select rows in BULK Order load table
select UNA2, UNA3, UNA4, UORT, USTR from TXUYUV10 -- where ubln in ('0000002267') -- , '0000000832', '0000000833')
select VPLT, VLFN, VBNR, VBLN, VBLA from TXUYUF12 -- where vbln in ('0000002267') -- , '0000000832', '0000000833')

-- set master BOLs in order tracking
--update edi_OrderTracking
--SET
--  MasterBOLNumber = ps.LMBLN
--FROM edi_OrderTracking ot, txuyls00 ps
--where ot.JomarOrderNumber=ps.LBLN

-- update order tracking table to reflect Jomar DB SO states
-- exec dbo.edi_ApplyJomarUpdatesToOrderTracking

-- show order tracking table
select * from edi_OrderTracking where DatePOReceived>=20110901

-- delete from edi_OrderTracking where DatePOReceived>=20110812

update edi_OrderTracking set GenerateXML='A' where DateInvoiceSent='20110823'

update edi_OrderTracking 
set GenerateXML='A'
where DatePOReceived >= 20110812


-- update GenerateXML state in Order Tracking table
-- update edi_OrderTracking set GenerateXML ='A' 
-- where JomarOrderNumber in ('0000001653', '0000001654', '0000001655', '0000001656')

-- show order tracking inof for certain PO numbers
select * from edi_OrderTracking where CustomerPO in ('00364', '00365', '00366', '00367') 

-- remove order tracking entries for all except certain POs
-- delete from edi_OrderTracking 
-- where JomarOrderNumber not in ('0000001625', '0000001626', '0000001627', '0000001628') 

-- select wordpad notes for PO
select * from GNPWPD00 where WPCODE like 'SO%' and WPLINE='20'

-- select wordpad notes for PC(1)
select * from GNPWPD00 where WPCODE like 'SO%' and WPLINE='21'

-- delete wordpad notes for PO and PC edi messages ('20' and '21')
--delete from GNPWPD00 where WPCODE like 'SO%' and WPLINE in ('20', '21')

--- show Dunham's errors in bulk order load table
select 
ord.ukdn, ord.ubln, 
li.VPLT, li.VLFN, li.VBNR, li.VLFN, li.VANR,
li.verr1, li.verr2, li.verr3, li.verr4, li.verr5
from TXUYUV10 ord, TXUYUF12 li 
where li.vbln = ord.ubln and ord.ukdn='015991'
order by ord.UBLN, li.VLFN

-- generate XML content from Jomar DB
--exec edi_GenInvoiceXML @ediPartnerID='SPSMCX', @ediPartnerQualifier='ZZ', @JoInvoiceNum='0000822504'
--exec edi_GenShippingNoticeXML @ediPartnerID='SPSMCX', @ediPartnerQualifier='ZZ', @JoInvoiceNum='0000822504'
    
-- show all Invoices ready to be transmitted
exec edi_ReadyToTransmitIN810

-- show all ASNs ready to be transmitted
exec edi_ReadyToTransmitSH856

-- select all columns from EDI OrderChange and OrderLineChange tables
select * from edi_OrderChange
select * from edi_OrderLineChange

-- delete all columns from EDI OrderChange and OrderLineChange tables
-- delete from edi_OrderChange
-- delete from edi_OrderLineChange


------------------------------
------------------------------  LIVE table SQL
------------------------------

-- select rows in 'Live' Order and OrderLine tables
select * from TXUYUV00 where ubln>='0000019327' and ubln<='0000019352'
select * from TXUYUV00 where udat='20110822'  and ukdr='015991'
select vbln, vanr, vkdl, vmgs from TXUYUF01 where vbln>='0000019327' and vbln<='0000019352'

--delete from TXUYUV00 where ubln>='0000019353' and ubln<='0000019361'
--delete from TXUYUF01 where vbln>='0000019353' and vbln<='0000019361'

select * from TXUYUV00 where ubln>='0000019353' and ubln<='0000019361'
select * from TXUYUF01 where vbln>='0000019353' and vbln<='0000019361'


select ubln, uihr, ubla, ubnr, ukdn, ukdr from TXUYUV00 where ubla = 'SO' and uihr in ('272240-02100', '272240-02100', '500123')
select vbln, vanr, vkdl, vmgs from TXUYUF01 where vbln in (825, 826, 827)

-- delete rows in 'Live' Order and Order Line tables for specific Orders
--delete from TXUYUV00 where ubla = 'SO' and ubln in ('0000001779', '0000001780', '0000001781', '0000001782')
--delete from TXUYUF01 where vbln in ('0000001779', '0000001780', '0000001781', '0000001782')

-- select MCX rows in 'Live' Order OrderLine tables
select * from TXUYUV00 where ukdr='015991'
select * from TXUYUF01 where vkdl='015991'

select UDAT, UBLN, UNA2, UNA3, UNA4, USTR, UORT, USTA, UPLZ 
from TXUYUV00 where UBLN IN (
'0000022847', 
'0000022843',
'0000022845',
'0000022844',
'0000022842',
'0000022839',
'0000022852',
'0000022853',
'0000022855',
'0000022856',
'0000022857',
'0000022862',
'0000022863',
'0000022864',
'0000022869',
'0000022858',
'0000022859',
'0000022866',
'0000022867',
'0000022868',
'0000022849',
'0000022865')

select * from TXUYUF01 where vkdl='015991'

------------------------------
------------------------------ FIND ALL PIECES OF A SALES ORDER
------------------------------

-- select rows in 'Live' Order OrderLine tables
select top 20 * from TXUYUV00 where udat = '20110613'

select * from TXUYUV00 where ubln between '0000000849' and '0000000851'
select * from TXUYUF01 where vbln between '0000000849' and '0000000851'

-- select rows in Invoice tables
select rbln, rrnr from TXUYRE00 where rbln between '0000012635' and '0000012647'
select * from TXUYRE01 where r1bln between '0000012635' and '0000012647'

-- select rows from PackingSlip tables
select * from txuyls00 where lbln between '0000000849' and '0000000851'
select * from txuyls01 where l1bln between '0000000849' and '0000000851'

-- select rows from DistRelease tables
select * from txuydr00 where d0bln between '0000001625' and '0000001628'
select * from txuydr01 where vbln between  '0000001625' and '0000001628'
