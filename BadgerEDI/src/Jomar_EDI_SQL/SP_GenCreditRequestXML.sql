/****** Object: Procedure [dbo].[edi_GenCreditRequestXML]   Script Date: 8/16/2011 10:52:38 AM ******/

-- Test by executing the stored procedure:
--
--    exec edi_GenCreditRequestXML 'WFG1234567', 'ZZ', '0000016147'
--
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_GenCreditRequestXML]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_GenCreditRequestXML];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[edi_GenCreditRequestXML]
@ediPartnerID varchar(10), @ediPartnerQualifier varchar(10), @JoOrderNum varchar(10), @testIndicator varchar(1) = 'P'
WITH RECOMPILE, EXEC AS CALLER
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
dbo.datetojomar(GETDATE()) as Date,
'7048710990' as FromTP,  -- BS
'12' as FromTPQualifier, -- BS
@ediPartnerID as ToTP,
@ediPartnerQualifier as ToTPQualifier,
@testIndicator AS Test,
'001' AS BusinessUnit,
'01' AS Plant,
(   --                                                                   .----------.
    SELECT  ------------------------------------------------------------|   Order    |
    --                                                                  '------------'
    so.Ubla                                         AS Type,
    so.Ubln                                         AS Number,
    so.Udat                                         AS Date,
    so.Udatre                                       AS DateRequested,
    so.Uwtf                                         AS TotalValue, -- Inv Amt Foreign?
    CASE so.Utxz 
       WHEN '#ZA1' THEN dbo.datetojomar(GETDATE()+30)
       WHEN '#ZA2' THEN dbo.datetojomar(GETDATE()+45)
       WHEN '#ZA3' THEN dbo.datetojomar(GETDATE()+60)
       WHEN '#ZA4' THEN dbo.datetojomar(GETDATE()+90)
    END                                             AS TOSNetDueDate,
    CASE so.Utxz 
       WHEN '#ZA1' THEN 30
       WHEN '#ZA2' THEN 45
       WHEN '#ZA3' THEN 60
       WHEN '#ZA4' THEN 90
    END                                             AS TOSNetDaysDue,
    CASE so.Utxz 
       WHEN '#ZA1' THEN 'Net 30 Days'
       WHEN '#ZA2' THEN 'Net 45 Days'
       WHEN '#ZA3' THEN 'Net 60 Days'
       WHEN '#ZA4' THEN 'Net 90 Days'
    END                                             AS TOSNetDescription,
    (   --                                                              .----------.
        SELECT  -------------------------------------------------------|   BillTo   |
        --                                                             '------------'
        bt.Kkdn                                            AS Number,
        bt.Kna2                                            AS Name,
        bt.Kna3                                            AS AddressLine1,
        bt.Kna4                                            AS AddressLine2,
        bt.Kort                                            AS City,
        bt.Ksta                                            AS StateOrProvinceCode,
        bt.Kplz                                            AS PostalCode,
        bt.Klnd                                            AS CountryCode,
        bt.Kflx09                                          AS DUNSNumber
        
        FROM TXUYKD00 bt  -- Customer table
        WHERE  bt.Kkdn = LEFT(so.Ukdr,6) AND bt.Kplt=so.Uplt AND bt.Kbnr=so.Ubnr
        FOR XML RAW ('BillTo'), TYPE
    ),
    (   --                                                             .------------.
        SELECT  ------------------------------------------------------|   OrderLine  |
        --                                                            '--------------'
        soLine.Vlfn                                             AS Number,
        soLine.Vmgs                                             AS QuantityOrdered,
        soLine.Vpr1                                             AS UnitPrice
        
        FROM TXUYUF01 soLine  -- SalesOrder line item table
        WHERE soLine.Vbla = so.Ubla AND soLine.Vbln = so.Ubln 
          AND soLine.Vbnr = so.Ubnr AND soLine.Vplt = so.Uplt
        
        FOR XML RAW ('OrderLine'), TYPE
    )
    FROM TXUYUV00 so  -- SalesOrder table
    WHERE so.Uplt = '01' AND so.Ubnr = '001' AND so.Ubln=@JoOrderNum
    FOR XML RAW ('Order'), TYPE
)
FOR XML RAW ('EdiTx'), TYPE
GO
