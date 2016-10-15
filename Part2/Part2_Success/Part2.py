
import urllib.request
from bs4 import BeautifulSoup
import re
import subprocess
import time
import os
import PyPDF2
import os.path

#pdf links
os.chdir('/Users/pagarwal/my_project/assignment1')
html_page = urllib.request.urlopen('https://www.ffiec.gov/nicpubweb/content/BHCPRRPT/BHCPR_PEER.htm')
html_page
soup = BeautifulSoup(html_page, "lxml")
f = open('workfile.txt', 'w')
for link in soup.findAll('a', attrs={'href': re.compile("PeerGroup_1")}):
    f.write('https://www.ffiec.gov/nicpubweb/content/BHCPRRPT/')
    f.write(link.get('href'))
    f.write('\n')
f.close()

# Rscript to download pdf
#Execute R script
command = 'Rscript'
path2script = '/Users/pagarwal/my_project/python_assgn/DOWNLOAD PDF.R'
cmd = [command, path2script]
subprocess.check_output(cmd, universal_newlines=True)
time.sleep(20)

#read pdf and convert to text file
save_path = '/Users/pagarwal/my_project/assignment1/PeerGroup_1_txt'
os.chdir('/Users/pagarwal/my_project/assignment1/PeerGroup_1_pdf')
pdfFiles = []
for filename in os.listdir('.'):
    pdfFiles.append(filename)

for filename1 in pdfFiles:
    pdfFileObj = open(filename1, 'rb')
    pdfReader = PyPDF2.PdfFileReader(pdfFileObj)
    content = ''
    if(pdfReader.numPages < 16):
        last = 15
    else:
        last = 28
    for i in range(0,last):
        pageObj = pdfReader.getPage(i)
        pageText = pageObj.extractText()
        content += pageText

    filename1 = filename1.replace(".pdf","")
    completeName = os.path.join(save_path, filename1+".txt")
    page = open(completeName, 'w')
    page.write(content)
    page.close()
time.sleep(20)

#Convert of file to xlsx
command = 'Rscript'
path2script = '/Users/pagarwal/my_project/python_assgn/xlsxConvert.R'
cmd = [command, path2script]
subprocess.check_output(cmd, universal_newlines=True)
time.sleep(10)
