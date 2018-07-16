/****** Object: Procedure [dbo].[edi_GenShippingNoticeXML]   Script Date: 12/8/2011 1:08:56 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[edi_GenShippingNoticeXML]') AND type IN (N'P', N'RF', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[edi_GenShippingNoticeXML];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER OFF;
GO
CREATE PROCEDURE [dbo].[edi_GenShippingNoticeXML]
@ediPartnerID varchar(20),
@ediPartnerQualifier varchar(10),
@JoInvoiceNum varchar(10),
@JoMasterBOL varchar(40),
@CrossDockLocID varchar(10),
@testIndicator varchar(1) = 'P'
WITH RECOMPILE, EXEC AS CALLER
AS SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
dbo.datetojomar(GETDATE()) as Date,
'7048710990' as FromTP,  -- BS data
'12' as FromTPQualifier, -- BS data
@ediPartnerID as ToTP,
@ediPartnerQualifier as ToTPQualifier,
@testIndicator AS Test,
'001' AS BusinessUnit,
'01' AS Plant,
'JoShippingNotice' AS XMLVersion,
(
    --                                                                   .---------.  
    SELECT  ------------------------------------------------------------| CrossDock |
    --                                                                  '-----------'
    wh.Name                                 AS Name,
    wh.AddressLine1                         AS AddressLine1,
    wh.AddressLine2                         AS AddressLine2,
    wh.City                                 AS City,
    wh.State                                AS StateOrProvinceCode,
    wh.Zip                                  AS PostalCode,
    wh.Country                              AS CountryCode,
    wh.ID                                   AS LocID        -- WH location ID
    
    FROM edi_PartnerShipToLocation wh 
    WHERE @CrossDockLocID is not null 
    and wh.PartnerID = @ediPartnerID 
    AND wh.ID = @CrossDockLocID 
    AND wh.Category = 'WH'
    FOR XML RAW('CrossDock'), TYPE
),
(
    --                                                                         .--------.  
    SELECT  ------------------------------------------------------------------| Shipment |
    --                                                                        '----------'
    RTRIM(ps.Lmbln)                         AS MasterBOL,
    ps.Lsdat                                AS ShipDate,
    '1200'                                  AS ShipTime,
    ps.Lgwn                                 AS Weight,
    '1'                                     AS NumberOfPallets,         -- default
    '1'                                     AS NumberOfCartons,         -- default
    ps.Lfra                                 AS FreightCharge,
    DBO.fn_X12MethodOfPayment(ps.Lhan)      AS X12MethodOfPayment,
    inv.Rwtf                                AS TotalValue,              -- Value of all Orders in Shipment.
                                                                        -- Wrong for consolidated shipments! 
                                                                        -- Must be recalculated.
    (   --                                                                       .------.
        SELECT  ----------------------------------------------------------------| ShipTo |
        --                                                                      '--------'
        so.Ukdn                                 AS Number,
        so.Una2                                 AS Name,
        so.Una3                                 AS AddressLine1,
        so.Una4                                 AS AddressLine2,
        so.Uort                                 AS City,
        so.Usta                                 AS StateOrProvinceCode,
        so.Uplz                                 AS PostalCode,
        so.Ulnd                                 AS CountryCode,
        so.Utx3                                 AS LocID,        -- location ID
        'Store #'+so.Utx3                       AS LocationName,
        DBO.fn_X12FOBLocation(so.Ufob)          AS FOBLocation
        
        FROM txuyuv00 so -- from Order table
        WHERE so.Ubla = inv.Rbla AND so.Ubln = inv.Rbln 
          AND so.Ubnr = inv.Rbnr AND so.Uplt = inv.Rplt
        FOR XML RAW('ShipTo'), TYPE
    ),
    (   --                                                                      .-------.
        SELECT  ---------------------------------------------------------------| Carrier |
        --                                                                     '---------'
            RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1)           AS Code,
            DBO.fn_StdCarrierAlphaCode(
              RIGHT(ps.Ltxv,LEN(ps.Ltxv)-1))        AS Name,  
            RTRIM(dr.D0TRK)                         AS EquipmentNumber,
            
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
        
        FROM txuydr00 dr  -- from PackingSlip and DistRel header tables
        
        WHERE ps.LSNR=dr.D0SNR

        FOR XML RAW('Carrier'), TYPE
    ),
    (   --                                                                   .----------.
        SELECT  ------------------------------------------------------------|   Order    |
        --                                                                  '------------'
        so.Ubla                                         AS Type,
        so.Ubln                                         AS Number,
        so.Udat                                         AS Date,
        so.Uent                                         AS CancelDate,
        so.UDATRE                                       AS RequestedDate,
        so.UDATLS                                       AS PromisedDate,
        inv.Rwtf                                        AS TotalValue,          -- of this Order
        ps.Lsnr                                         AS PackingSlipNumber, 
        RTRIM(ps.Lrel)                                  AS ReleaseCode,
        inv.Rrnr                                        AS InvoiceNumber,
        inv.Rdatre                                      AS InvoiceDate, 
        DBO.fn_WordpadNote('SO'+so.Ubln, '#D', 10)      AS ExtraEdiInfo,
        DBO.fn_WordpadNote('SO'+so.Ubln, '#D', 12)      AS ExtraPackingDetails,
        RTRIM(so.Uihr)                                  AS PONumber,
        so.Uihs                                         AS PODate,
        --(   --                                                                       .------.
        --    SELECT  ----------------------------------------------------------------| SoldTo |
        --    --                                                                      '--------'
        --    so.Ukdn                                 AS Number,
        --    so.Una2                                 AS Name,
        --    so.Una3                                 AS AddressLine1,
        --    so.Una4                                 AS AddressLine2,
        --    so.Uort                                 AS City,
        --    so.Usta                                 AS StateOrProvinceCode,
        --    so.Uplz                                 AS PostalCode,
        --    so.Ulnd                                 AS CountryCode,
        --    so.Utx3                                 AS LocID,        -- location ID
        --    'ST'                                    AS LocType,
        --    DBO.fn_X12FOBLocation(so.Ufob)          AS FOBLocation
        --    
        --    FROM edi_PartnerShipToLocations 
        --    WHERE ID = so.Utx3 and Category = 'ST' 
        --    FOR XML RAW('ShipTo'), TYPE
        --),
        (   --                                                             .------------.
            SELECT  ------------------------------------------------------|   LineItem   |
            --                                                            '--------------'
            (
                SELECT psi.L1mgl
                FROM txuyls01 psi
                WHERE psi.L1snr = ps.Lsnr 
                    and psi.L1lfn = invi.R1lfn and psi.L1sart = invi.R1bla AND psi.L1bln = invi.R1bln
                    AND psi.L1bnr = invi.R1bnr AND psi.L1plt = invi.R1plt 
                  AND (psi.L1rnr is NULL or psi.L1rnr <> 'TRANSFER')
            )                                                   AS QuantityShipped,  
            invi.R1mgs                                          AS QuantityOrdered,
            LEFT(invi.R1lfn,LEN(invi.R1lfn)-1)                  AS LineNumber,
            RTRIM(invi.R1meh)                                   AS UnitOfMeasure,
            invi.R1pr1                                          AS UnitPrice,
            upcs.upcnumber                                      AS UPCCode,
            RTRIM(invi.R1anr)                                   AS VendorStyleCode, 
            ISNULL(styles.axtxt, styles2.axtxt)                 AS Description,
            RTRIM(SUBSTRING(invi.R1anr,7,9))                    AS Color,
            LTRIM(RTRIM(SUBSTRING(invi.R1anr,16,5)))            AS Size,
            RTRIM(invi.R1csc)                                   AS RequestedColor,
            CASE WHEN invi.R1anr = 'ZZ FRT' 
                THEN invi.R1ntf 
                ELSE 0 END                                      AS FreightCharges
              
            FROM txuyre01 invi -- from Invoice detail line table
            
--            LEFT JOIN txuyls01 psi       -- from PackingSlip detail line table

                 
            LEFT JOIN bdg_tblBlankUPCS upcs                    -- Lookup UPC for StyleCode    
            ON invi.R1anr = jomarsku
            
            LEFT JOIN txmytx00 styles                          -- Lookup style-specific SKU in CodesMaster     
            ON '*ITM1'+LEFT(invi.R1anr,6) = styles.axanr 
              AND invi.R1bnr = styles.axbnr AND invi.R1plt = styles.axplt
            
            LEFT JOIN txmytx00 styles2                         -- Lookup general (default) SKU in CodesMaster     
            ON '*ITM100'+LEFT(invi.R1anr,4) = styles2.axanr 
              AND invi.R1bnr = styles2.axbnr AND invi.R1plt = styles2.axplt
              
            WHERE invi.R1snr = ps.Lsnr AND invi.R1bla = ps.Lsart AND invi.R1bln = ps.Lbln 
                AND invi.R1bnr = ps.Lbnr AND invi.R1plt = ps.Lplt
                
            ORDER BY R1lfn   -- order by Invoice LineNumber
            
            FOR XML RAW ('LineItem'), TYPE
        )
        FROM txuyuv00 so
        WHERE so.Ubla = inv.Rbla AND so.Ubln = inv.Rbln AND so.Ubnr = inv.Rbnr AND so.Uplt = inv.Rplt
        FOR XML RAW ('Order'), TYPE
    )
    
    FROM txuyre00 inv -- from Invoice header table
    
    JOIN edi_OrderTracking otrk -- from Invoice header table
    ON (@JoInvoiceNum is null or otrk.JomarInvoiceNumber=@JoInvoiceNum)
    and (@JoMasterBOL is null or otrk.MasterBOLNumber=@JoMasterBOL)
    and inv.Rrnr = otrk.JomarInvoiceNumber
    AND otrk.JomarBizNum='001' AND otrk.JomarPlantNum='01' 
    
    LEFT JOIN txuyls00 ps     -- from PackingSlip header table
    ON ps.Lsart = inv.Rbla AND ps.Lbln = inv.Rbln
    AND ps.Lrnr = inv.Rrnr AND ps.Lplt = inv.Rplt 
    AND (ps.LBACK is null or ps.LBACK <> 'Y') -- don't use cancelled packing slips
    
    where inv.Rbnr = '001' ANd inv.Rplt = '01'
    FOR XML RAW ('Shipment'), TYPE
   )
FOR XML RAW ('EdiTx'), TYPE
GO
