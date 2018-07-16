/****** Object: Function [dbo].[fn_X12MethodOfPayment]   Script Date: 12/8/2011 1:12:35 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_X12MethodOfPayment]') AND type IN (N'FN', N'FS', N'FT', N'TF', N'IF'))
BEGIN
DROP FUNCTION [dbo].[fn_X12MethodOfPayment];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create function [dbo].[fn_X12MethodOfPayment] (@JOCODE VARCHAR(5))
RETURNS VARCHAR(2)
AS
BEGIN
    DECLARE @X12CODE VARCHAR(2)
    SET @X12CODE = CASE @JOCODE
      WHEN '1' THEN 'CC'  -- Collect
      WHEN '2' THEN 'PP'  -- Prepaid
      WHEN '3' THEN 'PP'  -- Prepaid and Charge
      WHEN '4' THEN 'TP'  -- Third Party
      WHEN '5' THEN ''    -- Bill Recipient
      WHEN '6' THEN ''    -- None
      WHEN '7' THEN ''    -- COD (Cash on Delivery)
    END     
    RETURN(@X12CODE)
END
GO
