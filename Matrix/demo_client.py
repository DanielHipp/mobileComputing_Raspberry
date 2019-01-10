import http.client

conn = http.client.HTTPConnection("192.168.10.1", 8000)
# Sende String an Matrix:
nachricht="Die%20Testnachricht%20kommt%20an.........?"
nachricht="HalloWelt"
conn.request("GET","/S"+nachricht)
r1 = conn.getresponse()
print(r1.status, r1.reason)
print(r1.read())
# Sende Binaerbild an Matrix:
testImg = "01" * 16 * 8
#conn.request("GET","I"+testImg)
#r2 = conn.getresponse()
#print(r2.status, r2.reason)
#print(r2.read())

conn.close()