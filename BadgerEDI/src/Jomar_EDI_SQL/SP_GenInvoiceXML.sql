/****** Object: Procedure [dbo].[edi_GenInvoiceXML]   Script Date: 12/8/2011 1:08:37 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_GenInvoiceXML]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_GenInvoiceXML];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[edi_GenInvoiceXML]
@ediPartnerID varchar(20), 
@ediPartnerQualifier varchar(10), 
@JoInvoiceNum varchar(10), 
@testIndicator varchar(1) = 'P'
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
'JoInvoice' AS XMLVersion,
(
    SELECT
    rplt                                            AS Plant,
    rrnr                                            AS Number,
    rdatre                                          AS Date, 
    rwtf                                            AS TotalValue,
    CASE rtxz 
       WHEN '#ZA1' THEN dbo.datetojomar(GETDATE()+30)
       WHEN '#ZA2' THEN dbo.datetojomar(GETDATE()+45)
       WHEN '#ZA3' THEN dbo.datetojomar(GETDATE()+60)
       WHEN '#ZA4' THEN dbo.datetojomar(GETDATE()+90)
    END                                             AS TOSNetDueDate,
    CASE rtxz 
       WHEN '#ZA1' THEN 30
       WHEN '#ZA2' THEN 45
       WHEN '#ZA3' THEN 60
       WHEN '#ZA4' THEN 90
    END                                             AS TOSNetDaysDue,
    CASE rtxz 
       WHEN '#ZA1' THEN 'Net 30 Days'
       WHEN '#ZA2' THEN 'Net 45 Days'
       WHEN '#ZA3' THEN 'Net 60 Days'
       WHEN '#ZA4' THEN 'Net 90 Days'
    END                                             AS TOSNetDescription,
    ( 
        SELECT
        ubla                                            AS Type,
        ubln                                            AS Number,
        udat                                            AS Date,
        uwae                                            AS CurrencyCode,
        DBO.fn_WordpadNote('SO'+Ubln, '#D', 10)         AS ExtraEdiInfo
        
        FROM txuyuv00 SalesOrder
        WHERE ubla = rbla AND ubln = rbln AND ubnr = rbnr AND uplt = rplt
        FOR XML AUTO, TYPE
    ),
    (
        SELECT
        RTRIM(uihr)                                     AS Number,
        uihs                                            AS Date,
        utx3                                            AS ShipToLocation,
        'Store #'+Utx3                                  AS ShipToName,
        DBO.fn_X12FOBLocation(Ufob)                     AS FOBLocation
        
        FROM txuyuv00 PurchaseOrder -- in Order table
        WHERE ubla = rbla AND ubln = rbln AND ubnr = rbnr AND uplt = rplt
        FOR XML AUTO, TYPE
    ),
    ( 
        SELECT
        ukdn                                            AS Number,
        una2                                            AS Name,
        una3                                            AS AddressLine1,
        una4                                            AS AddressLine2,
        uort                                            AS City,
        usta                                            AS StateOrProvinceCode,
        uplz                                            AS PostalCode,
        ulnd                                            AS CountryCode
        
        FROM txuyuv00 ShipTo -- in Order table
        WHERE ubla = rbla AND ubln = rbln AND ubnr = rbnr AND uplt = rplt
        FOR XML AUTO, TYPE
    ),
    ( 
        SELECT
        kkdn                                            AS Number,
        kna2                                            AS Name,
        kna3                                            AS AddressLine1,
        kna4                                            AS AddressLine2,
        kort                                            AS City,
        ksta                                            AS StateOrProvinceCode,
        kplz                                            AS PostalCode,
        klnd                                            AS CountryCode,
        kflx09                                          AS DUNSNumber
        
        FROM txuykd00 SoldTo  -- in Customer table
        WHERE LEFT(rkdn,6) = kkdn AND rplt = kplt AND rbnr = kbnr
        FOR XML AUTO, TYPE
    ),
    (
        select 
        lsnr                                            as PackingSlipNumber,
        lsdat                                           as ShipDate,
        '1200'                                          as ShipTime,
        LGWN                                            as Weight,
        '1'                                             as NumberOfPallets,
        '1'                                             as NumberOfCartons,     -- default, may be 
                                                                                -- updated when processed
        DBO.fn_X12MethodOfPayment(Lhan)                 AS MethodOfPayment,

        (   --                                                                      .-------.            
            SELECT  ---------------------------------------------------------------| Carrier |
            --                                                                     '---------'
            RTRIM(ps.lrel)                                 AS ReleaseCode,
            RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1)                  AS CarrierCode,
            DBO.fn_StdCarrierAlphaCode(
              RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1))               AS CarrierName,
            RTRIM(dr.D0trk)                                AS EquipmentNumber,
            
            -- PRONumber has been semantically overloaded, this is how it is handled:
            -- If EquipmentNumber is not specified, then we assume that
            -- this is a parcel carrier and the PRONumber column
            -- contain the pickup reference number, otherwise the
            -- PRONumber column contains a valid PRONumber. 
            CASE WHEN dr.D0TRK is not Null and LEN(RTRIM(dr.D0TRK))>0
                THEN RTRIM(dr.D0PRO)
                ELSE '' END                                AS CarrierPRONumber,
                
            -- Note: Should have been RTRIM(ps.Lpck) except for the fact that
            -- that field's value cannot be entered though the Jomar interface
            -- at this time.  
            -- TODO: We need to fix this, eventually 
            CASE WHEN dr.D0TRK is Null or LEN(RTRIM(dr.D0TRK))=0
                THEN RTRIM(dr.D0PRO)
                ELSE '' END                                AS CarrierPickupReferenceNumber,
            lfra                                           AS FreightCharge
            
            FROM txuyls00 ps, txuydr00 dr  -- from PackingSlip and DistRel header tables
            WHERE ps.LSNR=dr.D0SNR  
              AND ps.Lsart = Rbla AND ps.Lbln = Rbln 
              AND ps.Lrnr = Rrnr AND ps.Lplt = Rplt 
              AND (ps.LBACK is null or ps.LBACK <> 'Y') -- don't use cancelled packing slips
            FOR XML RAW('Carrier'), TYPE            
        )
        from txuyls00 Shipment
        WHERE lsart = rbla AND lbln = rbln AND lrnr = rrnr AND lplt = rplt 
        FOR XML AUTO, TYPE
    ),
    (
        SELECT
        LEFT(r1lfn,LEN(r1lfn)-1)                           AS LineNumber,
        r1mgd                                              AS Quantity,
        RTRIM(r1meh)                                       AS UnitOfMeasure,
        r1pr1                                              AS UnitPrice,
        upcs.upcnumber                                     AS UPCCode,
        RTRIM(r1anr)                                       AS VendorStyleCode, 
        ISNULL(styles.axtxt, styles2.axtxt)                AS Description,
        RTRIM(SUBSTRING(R1anr,7,9))                        AS Color,
        LTRIM(RTRIM(SUBSTRING(R1anr,16,5)))                AS Size,
        RTRIM(R1csc)                                       AS RequestedColor,
        CASE WHEN r1anr = 'ZZ FRT' 
          THEN r1ntf 
          ELSE 0 END                                       AS FreightCharges
        
        FROM txuyre01 InvoiceLine
        
        -- Lookup UPC for StyleCode
        LEFT JOIN bdg_tblBlankUPCS upcs
          ON r1anr = upcs.jomarsku 
          
        -- Lookup specific SKU in Codes Master
        LEFT JOIN txmytx00 styles 
          ON '*ITM1' + LEFT(r1anr,6) = styles.axanr AND r1bnr = styles.axbnr AND r1plt = styles.axplt
          
        -- Lookup general, style default, SKU in Codes Master
        LEFT JOIN txmytx00 styles2 
          ON '*ITM100' + LEFT(r1anr,4) = styles2.axanr AND r1bnr = styles2.axbnr AND r1plt = styles2.axplt
          
        WHERE rbla = r1bla AND rbln = r1bln AND rbnr = r1bnr AND rplt = r1plt AND rrnr = r1rnr
        
        ORDER BY R1lfn   -- order by Invoice LineNumber
        
        FOR XML RAW ('InvoiceLine'), TYPE
    )
    FROM txuyre00 Invoice -- Invoice Header.
    WHERE Rrnr = @JoInvoiceNum AND Rplt = '01' AND Rbnr = '001' 
    
    FOR XML AUTO, TYPE
)
FOR XML RAW ('EdiTx'), TYPE
GO
