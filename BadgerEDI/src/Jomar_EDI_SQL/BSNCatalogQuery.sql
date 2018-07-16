-- select a customer's catalog using their assigned pricing
select
  'BADGER'                                           AS VendorID,
  prc.spdat                                          AS EffectiveDateOfCatalog,  
  it.EITNR                                           AS MfrPartNumber,
  ISNULL(styles.axtxt, styles2.axtxt)                AS ShortDescription,
  RTRIM(SUBSTRING(it.EITNR,1,6))                     AS Style,
  RTRIM(SUBSTRING(it.EITNR,7,9))                     AS Color,
  LTRIM(RTRIM(SUBSTRING(it.EITNR,16,5)))             AS Size,
  ISNULL(upcs.upcnumber,'')                          AS UPCCode,
  it.EIUPC                                           AS GTINCode,
  prc.sppri                                          AS NetPricePerUOM,
  prc.spuom                                          AS BaseUOM
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
