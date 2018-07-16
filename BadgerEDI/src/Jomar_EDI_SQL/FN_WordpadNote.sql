/****** Object: Function [dbo].[fn_WordpadNote]   Script Date: 12/8/2011 1:10:48 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_WordpadNote]') AND type IN (N'FN', N'FS', N'FT', N'TF', N'IF'))
BEGIN
DROP FUNCTION [dbo].[fn_WordpadNote];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
create function [dbo].[fn_WordpadNote] (@CODE VARCHAR(40), @NTYPE VARCHAR(4), @NSEQ DECIMAL(5,0))
RETURNS VARCHAR(4000)
AS
BEGIN
    DECLARE @NOTETEXT VARCHAR(4000)
  SELECT @NOTETEXT=WPTEXT FROM GNPWPD00 
  WHERE wpbnr='001' and wpplt='01' and wpntyp = @NTYPE and wpcode = @CODE and wpline = @NSEQ
    return (@NOTETEXT)
END
GO
