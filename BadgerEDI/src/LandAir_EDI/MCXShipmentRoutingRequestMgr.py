'''
Created on May 11, 2011

@author: jknaus
'''

from urllib import urlencode
import urllib2
from BeautifulSoup import BeautifulSoup
import cookielib
import re

def get_table():

    # Configuration
    uri1 = 'http://landair.shipcomm.com/LogisticsPortal/vendor/vendorLoginControl.jsp'
    uri2 = 'http://landair.shipcomm.com/LogisticsPortal/vendor/mainScreenControl.jsp'
    
    # Create headers
    headers = {
        'Accept':'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
        'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
        'Accept-Encoding': 'gzip,deflate,sdch',
        'Accept-Language': 'en-US,en;q=0.8',
        'Connection': 'keep-alive',
        'Content-Type':'application/x-www-form-urlencoded',
        'Host':'www.badgersportswear.com',
        'User-Agent': 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6;en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.134 Safari/534.16',
        }
    
    formFields = {'user':'BADGE28625'}
    encodedFields = urlencode(formFields)
    
    # Set up cookie jar
    cj = cookielib.CookieJar()
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj), urllib2.HTTPSHandler(debuglevel=1))
    
    # Grab information that we need to pass along with our requests #
    # NOT r = urllib2.urlopen(uri1)
    req = urllib2.Request(uri1,encodedFields,headers)
    cj.add_cookie_header(req)
    r = opener.open(req)
    print 'Cookie Jar:'+cj
    
    soup = BeautifulSoup(r.read())
    
    # capture and resend hidden state vars
    viewstate = soup.find('input', id='__VIEWSTATE')['value']
    formFields = [
        ('__VIEWSTATE',viewstate),
        ('reportType', 'MainScreen'),
        ]  
    encodedFields = urlencode(formFields)
    print 'Contents1 (soup): '+soup
    
    # Load page 2
    req = urllib2.Request(uri2, encodedFields, headers)
    cj.add_cookie_header(req)
    r = opener.open(req)
    
    contents = r.read()
    print 'Contents2: '+ contents

    """
    row_pattern = (
        'href="displaySRR\&srrDocId=.*?>' +   # 
        '(.*?)<.*?"borderEven">' +            # SRR 
        '(.*?)<.*?"borderEven">' +            # available
        '(.*?)<.*?"borderEven">' +            # recipient ID
        '(.*?)<.*?"borderEven">' +            # recipient Name
        '(.*?)<.*?"borderEven">' +            # PO#
        '(.*?)<.*?"borderEven">' +            # weight
        '(.*?)<.*?"borderEven">' +            # cartons
        '(.*?)<.*?"borderEven">' +            # cube
        '(.*?)<.*?"borderEven">' +            # status
        '(.*?)<.*?"borderEven">' +            # carrier
        '(.*?)<.*?"borderEven">.*?srrDocId=.*>\s*?' +  # ship date 
        '(.*?)\s*<'                           # BOL#
        )
    """
    row_pattern = 'href="displaySRR\&srrDocId=.*?>(.*?)<.*?"borderEven">' # SRR 
    m = re.search(row_pattern, content)
    row = dict()
    if m:
        row['SRR'] = m.group(1)
        row['available'] = m.group(2)
        row['recipientID'] = m.group(3)
        row['recipientName'] = m.group(4)
        row['po'] = m.group(5)
        row['weight'] = m.group(6)
        row['cartons'] = m.group(7)
        row['cube'] = m.group(8)
        row['status'] = m.group(9)
        row['carrier'] = m.group(10)
        row['shipDate'] = m.group(11)
        row['bol'] = m.group(12)
        print ('Found row for SRR=%s, available=%s, recipientID=%s, '+
            'recipientName=%s, po=%s, weight=%s, cartons=%s, cube=%s, '+
            'status=%s, carrier=%s, shipDate=%s, bol=%s') % (
            row['SRR'], row['available'], row['recipientID'], row['recipientName'], 
            row['po'], row['weight'], row['cartons'], row['cube'],
            row['status'], row['carrier'], row['shipDate'], row['bol'])
    else:
        print 'No rows found in table!'
    return row

        
if __name__=='__main__':
    get_table()

"""
# Login Page
#
login_url = "http://landair.shipcomm.com/LogisticsPortal/vendor/vendorLoginControl.jsp?user=badge2865"
resp = urllib2.urlopen(login_url)
content = resp.read()
print 'CONTENT1: [[['+content+']]]'

#  show SRR table for logged in user
#
data = dict()
data['reportType'] = 'mainScreen'
srr_table_url = "http://landair.shipcomm.com/LogisticsPortal/vendor/mainScreenControl.jsp"
resp = urllib2.urlopen(login_url, *data)
content = resp.read()
print 'CONTENT2: [[['+content+']]]'

"""

"""
http://landair.shipcomm.com/LogisticsPortal/vendor/vendorLoginControl.jsp?user=badge28625

# to show MCX BOL
http://landair.shipcomm.com/LogisticsPortal/vendor/billOfLadingControl.jsp?action=display&srrDocId=164950

# search for all SRRs from a PO
http://landair.shipcomm.com/LogisticsPortal/vendor/mainScreenControl.jsp
dateFrom=, dateThru=, searchSRR=SRRID, reportType=mainScreen


# new SRR request
http://landair.shipcomm.com/LogisticsPortal/vendor/SRRControl.jsp?action=newSRRRequest

#===================================================================================================
# <td align='center'><input type='text' maxlength='20' size='17'  name='poNumber_0' value=''></td>
# <td align='center'><input type='text' maxlength='10' size='4' name='carton_0' value=''></td>
# <td align='center'><input type='text' maxlength='10' size='5' name='weight_0' value=''></td>
# <td align='center'><input type='text' maxlength='10' size='5' name='cube_0' value=''></td>
# <td align='center'>
# <select name='freightClass_0'><option value='23'>Non-Furniture - Class-70</option><option value='31'>Furniture - Class-175</option>
# </select></td>
# <td align='center'><input type='text' maxlength='250' size='19' name='productType_0' value=''></td>
# <td align='center'><input type='text' maxlength='32' size='6' name='reference2_0' value=''></td>
#===================================================================================================

poNumber_0=<PO Number>
carton_0
weight_0
cube_0
freightClass_0=23
productType_0
reference2_0=<locationID>
"""