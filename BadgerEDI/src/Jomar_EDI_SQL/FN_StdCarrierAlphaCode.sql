/****** Object: Function [dbo].[fn_StdCarrierAlphaCode]   Script Date: 12/8/2011 1:10:32 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_StdCarrierAlphaCode]') AND type IN (N'FN', N'FS', N'FT', N'TF', N'IF'))
BEGIN
DROP FUNCTION [dbo].[fn_StdCarrierAlphaCode];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create function [dbo].[fn_StdCarrierAlphaCode] (@CODE VARCHAR(5))
RETURNS VARCHAR(25)
AS
BEGIN
    DECLARE @CARRIER VARCHAR(25)
  SELECT @CARRIER=axtxt FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr = '#C'+@CODE
    return (@CARRIER)
END
GO
