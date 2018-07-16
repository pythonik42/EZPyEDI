select * from edi_OrderTracking
--update edi_OrderTracking
--SET
--  JomarInvoiceNumber = ps.LRNR
FROM edi_OrderTracking ot, txuyls00 ps
where (ot.OrderClosed is Null or ot.OrderClosed <> 'Y') 
and ot.JomarBizNum=ps.LBNR and ot.JomarPlantNum=ps.LPLT 
and ot.JomarOrderType=ps.LSART and ot.JomarOrderNumber=ps.LBLN
AND (otrk.generateXML='A' or otrk.generateXML='S') 
AND (ot.DateASNSent is null or DateASNSent=0)
AND (ps.LBACK is null or ps.LBACK <> 'Y') -- don't use cancelled packing slips

update edi_OrderTracking
SET
  DateASNSent=20111111,
  DateInvoiceSent=20111111,
  GenerateXML='N'
where 
  JomarInvoiceNumber is not null
  
-- SOs where all line items are currently closed, but some items have been shipped
-- note: a SO may be 're-opened' by adding to qtyOrdered in a line 
--
select * from edi_OrderTracking
--update edi_OrderTracking
--SET
--  OrderClosed = 'Y'
where (select count(*) 
       from TXUYUF01 sl 
       where (OrderCancelled is Null or OrderCancelled <> 'Y') 
       and JomarBizNum=sl.VBNR and JomarPlantNum=sl.VPLT 
       and JomarOrderType=sl.VBLA and JomarOrderNumber=sl.VBLN
       and not (sl.VERA='E' and sl.VMGL=sl.VMGS))=0

-- Show cancelled Sales Orders
--
select * from edi_OrderTracking
--update edi_OrderTracking
--SET
--  OrderClosed = 'Y',
--  OrderCancelled = 'Y'
where (select count(*) 
       from TXUYUF01 sl 
       where JomarBizNum=sl.VBNR and JomarPlantNum=sl.VPLT 
       and JomarOrderType=sl.VBLA and JomarOrderNumber=sl.VBLN
       and not (sl.VERA='E' and sl.VMGL=0))=0
       
edi_ApplyJomarUpdatesToOrderTracking

----------------------------------------------------------------------------------
select * from TXUYUF01 so where vkdl='015991'

select * from txuyls01 ps where vkdl='015991'

select * from edi_OrderTracking

    --                                                                         .---------.  
    SELECT  ------------------------------------------------------------------| CrossDock |
    --                                                                        '-----------'
    wh.Name                                 AS Name,
    wh.AddressLine1                         AS AddressLine1,
    wh.AddressLine2                         AS AddressLine2,
    wh.City                                 AS City,
    wh.State                                AS StateOrProvinceCode,
    wh.Zip                                  AS PostalCode,
    wh.Country                              AS CountryCode,
    wh.ID                                   AS LocID        -- location ID
    
    FROM edi_PartnerShipToLocation wh 
    WHERE wh.PartnerID = 'TESTNEXCOMLD' AND wh.Category = 'WH' AND wh.ID ='995'
    FOR XML RAW('CrossDock'), TYPE
    
    select * from edi_PartnerShipToLocation where Category='WH'

select ps.LREL, ps.LPRO, dr.D0PRO, dr.D0BLN orderNum, dr.D0TYP, dr.D0DATE dateReleased, dr.D0CARR carrier, ot.*
from edi_OrderTracking ot, TXUYDR00 dr, txuyls00 ps
where not ot.OrderCancelled='Y' 
and dr.D0BLN=ot.JomarOrderNumber and ps.LBLN=ot.JomarOrderNumber
    and dr.D0KDN=ot.CustomerSoldToID and dr.D0SNR=ps.LSNR  
    and ot.DateASNSent='20110812'
    and ,,,
-- group by dr.D0BLN, dr.D0DREL, dr.D0CARR
order by ot.CustomerPO, ot.JomarOrderNumber, dr.D0DATE -- , dr.D0DREL

select ps.* from edi_OrderTracking ot, txuyls00 ps where ot.JomarOrderNumber=ps.LBLN

select dr.* from edi_OrderTracking ot, txuyDR00 dr where ot.JomarOrderNumber=dr.D0BLN

update edi_OrderTracking
SET
  MasterBOLNumber = ps.LMBLN
FROM edi_OrderTracking ot, txuyls00 ps
where ot.JomarOrderNumber=ps.LBLN


WHERE exists (select ps.LMBLN, ps.LSNR, ps.LBLN 
                    FROM edi_OrderTracking ot, txuyls00 ps 
                    where ot.JomarOrderNumber=ps.LBLN and ps.LMBLN is not null and ps.LMBLN<>'')
                    
select ps.LMBLN, so.* from TXUYLS00 ps, TXUYUV00 so where ps.LBLN = so.UBLN and ps.LMBLN is not null and ps.LMBLN<>''
  
select distinct ot.JomarOrderNumber
  from edi_OrderTracking ot
  where (select count(*) from TXUYUF01 sl where sl.VBLN=ot.JomarOrderNumber and not (sl.VERA='E' and sl.VMGL=0))=0
  
select count(*) from TXUYUF01 sl where sl.VBLN='0000012636' and not(sl.VERA='E' and sl.VMGL=0)

select * from TXUYUF01 sl where sl.VBLN='0000012636' and not(sl.VERA='E' and sl.VMGL=0)


select * from edi_OrderTracking ot where ot.OrderCancelled='Y'

-- exec dbo.edi_ApplyJomarUpdatesToOrderTracking

select ps.* from TXUYUV00 so, TXUYLS00 ps where ps.LBLN=so.UBLN and so.UIHR like '619152%'

--                                                                      .-------.
SELECT  ---------------------------------------------------------------| Carrier |
--                                                                     '---------'
ps.LPRO                                 AS PS_PRONumber,
dr.D0PRO                                AS DR_PRONumber,
RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1)           AS Code,
DBO.fn_StdCarrierAlphaCode(
  RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1))        AS Name,
  
RTRIM(ps.Ltrk)                          AS EquipmentNumber,
-- PRONumber has been semantically overloaded, this is how it is handled:
-- If EquipmentNumber is not specified, then we assume that
-- this is a parcel carrier and the PRONumber column
-- contain the pickup reference number, otherwise the
-- PRONumber column contains a valid PRONumber. 
CASE WHEN dr.D0TRK is not Null and LEN(RTRIM(dr.D0TRK))>0
    THEN RTRIM(dr.D0PRO)
    ELSE '' END                         AS PRONumber,
-- Note: Should have been RTRIM(ps.Lpck) except for the fact that
-- that field's value cannot be entered though the Jomar interface
-- at this time.  
-- TODO: We need to fix this, eventually 
CASE WHEN dr.D0TRK is Null or LEN(RTRIM(dr.D0TRK))=0
    THEN RTRIM(dr.D0PRO)
    ELSE '' END                         AS PickupReferenceNumber

FROM txuyls00 ps, edi_OrderTracking ot, txuydr00 dr -- from PackingSlip header table
where ps.LBLN=ot.JomarOrderNumber and ps.LSNR=dr.D0SNR  
        

select dr.D0BLN orderNum, dr.D0TYP, dr.D0DATE dateReleased, dr.D0CARR carrier, dr.D0PRO proNum, ot.*
from edi_OrderTracking ot, TXUYDR00 dr
where not ot.OrderCancelled='Y' and dr.D0BLN=ot.JomarOrderNumber 
    and dr.D0KDN=ot.CustomerSoldToID
-- group by dr.D0BLN, dr.D0DREL, dr.D0CARR
order by ot.CustomerPO, ot.JomarOrderNumber, dr.D0DATE -- , dr.D0DREL

select * from edi_OrderTracking where dateporeceived>='20110919'

select * from edi_Sent  xxxx  

select * from TXUYDR00 dr
where dr.D0BLN in (select JomarOrderNumber from edi_OrderTracking ot where dr.D0BLN=ot.JomarOrderNumber and dr.D0KDN=ot.CustomerSoldToID) -- and D0RNR is not null
order by dr.D0BLN

-- all wordpad notes
select * from GNPWPD00 where WPCODE like 'SO%'

-- all lookup codes
SELECT * FROM TXUYLS00

-- show Terms of Delivery (Method of payment) codes (PS LHAN column)
SELECT distinct right(axanr,1) as Code, axtxt as Description FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like '#L%'

-- select Carrier codes
SELECT distinct right(axanr,len(axanr)-2) as Code, axtxt as Description FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like '#C%'

-- select Text codes
SELECT distinct right(axanr,len(axanr)-2) as Code, axtxt as Description FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like '#T%'

-- select Terms of Payment codes
SELECT distinct right(axanr,len(axanr)-2) as Code, axtxt as Description FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like '#Z%'

-- select FOB codes
SELECT distinct right(axanr,len(axanr)-2) as Code, axtxt as Description FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr like '#H%'
 
--- show errors in bulk order load table
select 
ord.ukdn, ord.ubln, 
li.VPLT, li.VLFN, li.VBNR, li.VLFN, li.VANR,
li.verr1, li.verr2, li.verr3, li.verr4, li.verr5
from TXUYUV10 ord, TXUYUF12 li 
where li.vbln = ord.ubln
order by ord.UBLN, li.VLFN

--exec edi_GenInvoiceXML @ediPartnerID='SPSMCX', @ediPartnerQualifier='ZZ', @JoInvoiceNum='0000822504'
--exec edi_GenShippingNoticeXML @ediPartnerID='SPSMCX', @ediPartnerQualifier='ZZ', @JoInvoiceNum='0000822504'
--exec edi_GenShippingNoticeXML @ediPartnerID='SPSMCX', @ediPartnerQualifier='ZZ', @JoInvoiceNum='0000822504'

update edi_OrderTracking set GenerateXML ='A'
select * from edi_OrderTracking where CustomerPO in ('00364', '00365', '00366', '00367') 
delete from edi_OrderTracking where JomarOrderNumber not in ('0000001625', '0000001626', '0000001627', '0000001628') 

-- list all invoices for a specific 'SoldTo' customer
select 
  ord.uihr as 'PONum',
  ord.udat as 'OrderDate', 
  ord.ubln as 'OrderNum',
  ord.ukdr as 'SoldTo', 
  ord.ukdn as 'ShipTo',
  inv.rdatre as 'InvDate', 
  inv.rrnr as 'InvNum' 
from TXUYUV00 ord, TXUYRE00 inv 
where ord.ukdr='020430' and ord.ubln=inv.rbln
order by InvDate desc

-- to show load errors for bulk order load process
select ubln, uihr, ubla, ubnr, ukdn, ukdr, uerr1, uerr2, uerr3, uerr4 from TXUYUV10 -- where ubln = '0000003482'
select vbln, vanr, vkdl, vmgs, verr1, verr2, verr3, verr4, verr5 from TXUYUF12      -- where vbln = '0000003482'

-- delete all bulk order load table entries
delete from TXUYUV10
delete from TXUYUF12

-- select rows in BULK Order load table
select * from TXUYUV10 where ubln = '0000003478' -- where ubln in ('0000000831', '0000000832', '0000000833')
select VPLT, VLFN, VBNR, VBLN, VBLA  from TXUYUF12 where vbln = '0000003478'-- where vbln in ('0000000831', '0000000832', '0000000833')

select * from TXUYUV10
select * from TXUYUF12

SELECT SGCODE, SGTEXT, SGLANG, SGFMT FROM SGPTXT00 

SELECT SCGRP FROM GNPSEC00

SELECT SUBSTRING(XANR,1, 6) AS STYLE, SUBSTRING(XANR, 7, 9) AS COLOR, XFLX40, XANR, XARTGR, XSEL1, XSEL2, XSEL3, XSEL4, BAKT, V1 , XBNR, XPLT FROM TXMYAT03 INNER JOIN TXMYAT00 ON (XBNR = BNR AND XANR = ARTNR) ORDER BY STYLE, COLOR, XFLX40

SELECT * FROM TXUYDR00

select * from TXUYKD00 where kkdn like '000151%'

select top 5 * from  bdg_View_ASN_Summary

-- TEST: delete all rows in EDI and bulk order load tables
delete from TXUYUV10 -- where ukdn='020430'
delete from TXUYUF12 -- where vkdl='020430'
--delete from edi_OrderChange
--delete from edi_OrderLineChange

-- PROD: delete all rows in EDI and bulk order load tables
-- delete from TXUYUV10
-- delete from TXUYUF12
--delete from edi_OrderChange
--delete from edi_OrderLineChange

-- select rows in 'Live' Order OrderLine tables for SSG/BSN
select ubln, uihr, ubla, ubnr, ukdn, ukdr from TXUYUV00 where ukdn in ('0001519999')
select vbln, vanr, vkdl, vmgs from TXUYUF01 where vkdl in ('0001519999')

select ubln, uihr, ubla, ubnr, ukdn, ukdr from TXUYUV00 where ubla = 'SO' and uihr in ('272240-02100', '272240-02100', '500123')
select vbln, vanr, vkdl, vmgs from TXUYUF01 where vbln in (825, 826, 827)

--delete from TXUYUV00 where ubla = 'SO' and uihr in ('272240-02100', '272240-02100', '500123')
--delete from TXUYUF01 where vkdl='015991'

-- select rows in 'Live' Order OrderLine tables
select * from TXUYUV00 where ukdr='020430'
select * from TXUYUF01 where vkdl='020430'

-- search order headers
select TOP 100 * from TXUYUV10 where XTX6 is not null and len(XTX6)>0

-- serach customer records
select TOP 100 * from TXUYKD00 where kkdn = '015991'


-- select Customer row
select * from TXUYKD00 where kkdn = '015991'
select top 20 * from TXUYKD00 where kflx06 is not null and len(kflx06)>0

--
-- FIND ALL PIECES OF A SALES ORDER
--

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

select * from txuydr00 where d0kdn='015991'

select * from bdg_tblShippingDetails where OrderNumber between '0000000849' and '0000000851'

-- SKU queries
select
  RTRIM(SUBSTRING(JomarSKU,1,6))                        AS Style,
  RTRIM(SUBSTRING(JomarSKU,7,9))                        AS Color,
  LTRIM(RTRIM(SUBSTRING(JomarSKU,16,5)))                AS Size,
  JomarSKU                                              AS VendorItemNumber,
  UPCNumber                                             AS GTIN
from bdg_tblBlankUPCS sk
group by RTRIM(SUBSTRING(JomarSKU, 1, 6)), 
RTRIM(SUBSTRING(JomarSKU, 7, 9)), 
LTRIM(RTRIM(SUBSTRING(JomarSKU, 16, 5))),
JomarSKU,
UPCNumber
order by JomarSKU

select count(*) from TXMYAT05
select top 100 * from TXMYAT05

-- select a customer's catalog using their assigned pricing
select
  RTRIM(SUBSTRING(it.EITNR,1,6))                     AS Style,
  RTRIM(SUBSTRING(it.EITNR,7,9))                     AS Color,
  LTRIM(RTRIM(SUBSTRING(it.EITNR,16,5)))             AS Size,
  ISNULL(styles.axtxt, styles2.axtxt)                AS Description,
  it.EITNR                                           AS VendorItemNumber,
  upcs.upcnumber                                     AS UPCCode,
  it.EIUPC                                           AS GTINCode,
  prc.sppri                                          AS UnitPrice,
  prc.spuom                                          AS UOM,
  prc.spdat                                          AS EffectiveDate
from TXMYAT05 it

JOIN TXUYKD00 byr
ON byr.kkdn='000151'   -- Sports Supply Group

LEFT JOIN bdg_tblBlankUPCS upcs                    -- Lookup UPC for StyleCode    
ON it.EITNR = jomarsku

LEFT JOIN txmytx00 styles                          -- Lookup style-specific SKU in CodesMaster     
ON '*ITM1'+LEFT(it.EITNR,6) = styles.axanr 
  AND it.EIBNR = styles.axbnr AND it.EIPLT = styles.axplt

LEFT JOIN txmytx00 styles2                         -- Lookup general (default) SKU in CodesMaster     
ON '*ITM100'+LEFT(it.EITNR,4) = styles2.axanr 
  AND it.EIBNR = styles2.axbnr AND it.EIPLT = styles2.axplt
  
-- important: must be a natural join to exclude those items for which we have not assigned a price for this customer
JOIN GNPSPC12 prc    
ON (byr.KGR1=prc.SPGRP or prc.SPGRP=byr.KGR1) and prc.spanr = it.EITNR

order by it.EITNR


-- distinct sizes
select 
  distinct LTRIM(RTRIM(SUBSTRING(JomarSKU,16,5)))                AS Size,
  
from bdg_tblBlankUPCS

-- distinct colors
select 
  distinct RTRIM(SUBSTRING(JomarSKU,7,9))                        AS Color
from bdg_tblBlankUPCS

-- distinct styles
select 
  distinct RTRIM(SUBSTRING(JomarSKU,1,6))                        AS Style
from bdg_tblBlankUPCS

-- select * from CSPASN00

--
-- DELETE ALL TRACES OF A PREVIOUSLY LOADED SALES ORDER
--

---- delete rows in 'Live' Order OrderLine tables
--delete from TXUYUV00 where ubln in ('0000000420')
--delete from TXUYUF01 where vbln in ('0000000420')
--
---- delete rows in Invoice tables
--delete from TXUYRE00 where rbln in ('0000000420')
--delete from TXUYRE01 where r1bln in ('0000000420')
--
---- delete rows from PackingSlip tables
--delete from txuyls00 where lbln in ('0000000420')
--delete from txuyls01 where l1bln in ('0000000420')
--
---- delete rows from DistRelease tables
--delete from txuydr00 where d0bln in ('0000000420')
--delete from txuydr01 where vbln in ('0000000420')



-- select all columns from Order load tables
select * from TXUYUV10 where ukdn='0159919999' and udat=20111222
delete from TXUYUV10 where ukdn='0159919999' and udat=20111222   -- 128 rows
select * from TXUYUF12 where vkdl='0159919999' and vdat=20111222
select distinct(vbln) from TXUYUF12 where vkdl='0159919999' and vdat=20111222   -- confirm 128 orders
delete from TXUYUF12 where vkdl='0159919999' and vdat=20111222   -- 2747 rows
vbln between 000058646 and 000058773

select * from TXUYKD00 where KTXT3 != Null -- LOC ID
select * from TXUYKD00 where KTXT4 != Null
select * from TXUYKD00 where KTX3 != Null 
select * from TXUYKD00 where KTX4 != Null

-- select all columns from EDI OrderChange tables
select * from edi_OrderChange
select * from edi_OrderLineChange

-- select credit info table
select top 20 * from CSPCCR00 where CRSHP=''

--- MCX TESTING SCRIPTS
select * from edi_OrderTracking where MasterBOLNumber='MBOL-777'
select * from edi_OrderTracking where CustomerSoldToID='019691' and MasterBOLNumber='MBOL-0071573333'

update edi_OrderTracking
SET
  MasterBOLNumber = ps.LMBLN
FROM edi_OrderTracking ot, txuyls00 ps
where -- (ot.OrderClosed is Null or ot.OrderClosed <> 'Y') 
ot.JomarBizNum=ps.LBNR and ot.JomarPlantNum=ps.LPLT 
and ot.JomarOrderType=ps.LSART and ot.JomarOrderNumber=ps.LBLN
and (ps.LBACK is null or ps.LBACK <> 'Y') -- skip cancelled packing slips
and ot.CustomerPO='666'

--- show MCX errors in bulk order load table
select 
ord.ukdn, ord.ubln, 
li.VPLT, li.VLFN, li.VBNR, li.VLFN, li.VANR,
li.verr1, li.verr2, li.verr3, li.verr4, li.verr5
from TXUYUV10 ord, TXUYUF12 li 
where li.vbln = ord.ubln -- and ord.ukdn='015991'
and (verr1<>'' or verr2<>'' or verr3<>'' or verr4<>'' or verr5<>'') 
order by ord.UBLN, li.VLFN

-- show new invoices to be processed by EDI
select ps.LBLN as OrderNum, ps.LRNR as InvoiceNum, otrk.CustomerSoldToID as CustomerNum
from edi_OrderTracking otrk
join TXUYLS00 ps ON (otrk.JomarOrderNumber=ps.LBLN)
where (otrk.JomarInvoiceNumber is NULL or otrk.JomarInvoiceNumber='')
    and otrk.OrderCancelled<>'Y'
    
-- show orders which have been invoiced by Jomar
select ps.LBLN as OrderNum, ps.LRNR as InvoiceNum, ps.LKDL as CustomerNum
from TXUYLS00 ps
where ps.LKDL='015991'
    
-- test: exec as SP to show all Invoices to be transmitted
exec edi_ReadyToTransmitIN810

-- ASN view SQL code
SELECT     TOP 1
1 AS BD_41,
'1.0' AS BD_42, 
dbo.UCCCheckDigitAppend('48402350' + RIGHT(dbo.TXUYLS00.LSNR, 9)) AS BD_43, 
'00' AS BD_44,   
dbo.DateToJomar(GETDATE()) AS BD_45, 
dbo.FULLTIME(GETDATE()) AS BD_46, 
'8402350' AS BD_47, dbo.TXUYLS00.LKDR AS BD_48,   
case when LEN(dbo.TXUYLS00.LKDL)>9 THEN LEFT(dbo.TXUYLS00.LKDL,6) + RIGHT(dbo.TXUYLS00.LKDL,3) ELSE dbo.TXUYLS00.LKDL END AS BD_49, 
LEFT(dbo.TXUYKD00.KNA2, 35) AS BD_50, LEFT(dbo.TXUYKD00.KNA3, 35) AS BD_51, 
LEFT(dbo.TXUYKD00.KNA4, 35) AS BD_52, 
dbo.TXUYKD00.KORT AS BD_53,
dbo.TXUYKD00.KSTA AS BD_54, 
dbo.TXUYKD00.KPLZ AS BD_55, 
dbo.TXUYKD00.KLND AS BD_56,   
dbo.TXUYLS00.LSNR AS BD_58, 
dbo.TXMYTX00.AXTXT AS BD_59, 
'' AS BD_60, '' AS BD_61, 
dbo.TXUYLS00.LSDAT AS BD_62, 
2 AS BD_63,  
'Y' AS BD_64, 
dbo.UCCCheckDigitAppend('08402350' + dbo.ICPCTN00.CSCTN) AS BD_65, 
dbo.TXUYUV00.UIHR AS BD_66,   
dbo.TXMYAT05.EIUPC AS BD_67, 
SUBSTRING(dbo.TXMYAT05.EITNR, 3, 4) AS BD_68, 
SUBSTRING(dbo.TXMYAT05.EITNR, 3, 4) AS BD_69,   
RTRIM(SUBSTRING(dbo.TXMYAT05.EITNR, 7, 11)) AS BD_70, 
RTRIM(SUBSTRING(dbo.TXMYAT05.EITNR, 18, 3)) AS BD_71, 
'000' AS BD_72,   
'EA' AS BD_73, dbo.ICPCTN00.CSPQT AS BD_74, 
'99' AS BD_75, dbo.TXUYUV00.UBLN AS BD_76, 
'' AS BD_77,   
dbo.TXMYAT00.AGEW * dbo.ICPCTN00.CSPQT + dbo.ICPCTN00.CSTWG AS GROSSWEIGHT, 
dbo.TXUYLS00.LSNR AS ShipmentNumber,   
dbo.ICPCTN00.CSDREL AS ReleaseNo, 
dbo.TXUYLS00.LKDL AS ShipToID  
FROM         dbo.TXMYAT05 INNER JOIN  
                      dbo.ICPCTN00 ON dbo.TXMYAT05.EITNR = dbo.ICPCTN00.CSANR and eibnr = csbnr and eiplt = csplt INNER JOIN  
                      dbo.TXMYAT00 ON dbo.ICPCTN00.CSANR = dbo.TXMYAT00.ARTNR and csbnr = bnr and csplt = plt RIGHT OUTER JOIN  
                      dbo.TXUYLS00 INNER JOIN  
                      dbo.TXUYKD00 ON dbo.TXUYLS00.LKDR = dbo.TXUYKD00.KKDR AND dbo.TXUYLS00.LKDL = dbo.TXUYKD00.KKDN and lbnr = kbnr and lplt = kplt INNER JOIN  
                      dbo.TXMYTX00 ON '#' + dbo.TXUYLS00.LTXV = dbo.TXMYTX00.AXANR and lbnr = axbnr and lplt = axplt INNER JOIN  
                      dbo.TXUYUV00 ON dbo.TXUYLS00.LBLN = dbo.TXUYUV00.UBLN ON dbo.ICPCTN00.CSALN = dbo.TXUYLS00.LBLN AND   
                      dbo.ICPCTN00.CSDLN = dbo.TXUYLS00.LSNR and csbnr = lbnr and csplt = lplt
WHERE     (dbo.ICPCTN00.CSANR IS NOT NULL) and AXBNR = '001' and LSNR = '0000340521'
ORDER BY dbo.TXUYUV00.UBLN
FOR XML

select *
from txmyat05
where eiupc like '%840235%'

