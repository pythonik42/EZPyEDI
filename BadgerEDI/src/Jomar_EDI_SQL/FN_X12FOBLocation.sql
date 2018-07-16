/****** Object: Function [dbo].[fn_X12FOBLocation]   Script Date: 12/8/2011 1:12:18 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_X12FOBLocation]') AND type IN (N'FN', N'FS', N'FT', N'TF', N'IF'))
BEGIN
DROP FUNCTION [dbo].[fn_X12FOBLocation];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create function [dbo].[fn_X12FOBLocation] (@CODE VARCHAR(5))
RETURNS VARCHAR(25)
AS
BEGIN
  DECLARE @RVAL VARCHAR(25)
  SET @RVAL=''
  IF (LEN(@CODE) > 0) -- a code of '' means location not specified
  BEGIN
    SELECT @RVAL=axtxt FROM TXMYTX00 WHERE axbnr='001' and axplt='01' and axanr = '#H'+@CODE 
  END
  RETURN (@RVAL)
END
GO
