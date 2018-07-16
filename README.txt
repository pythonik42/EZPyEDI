EZPyEDI - Branched from BOTS (an open source Data Transformation Framework)

It is a fully functioning implementation of a B2B EDI Framework for US Markets (ala BizTalk).

This code was developed and tested under Python 2.7.1, using the EclipseHelios3_61x86-64bit IDE on Windows.

This is an initial commit of the GitHub version (initially saved on BitBucket).  The code is disorganized and needs cleanup to integrate with a Warehouse Mgmt System other than JOMAR.

Most of my code additions to the basic BOTS release code base can be found within the BadgerEDI/src/site-packages/badgerEDI directory. Specifically, the treeops.py module implements a mechanism to customize each CUSTOMER's semantics and handling of pseudo-standard X12 document elements. Yes, numerous customers treat the semantics of incoming/outgoing X12 document elements differently.

** This is a work in progress **
