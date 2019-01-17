import http.client
import numpy as np

conn = http.client.HTTPConnection("192.168.10.1", 8000)
# Sende String an Matrix:
nachricht="Die%20Testnachricht%20kommt%20an.-+:.......?"
#nachricht="HalloWelt"
conn.request("GET","/S"+nachricht)
r1 = conn.getresponse()
print(r1.status, r1.reason)
print(r1.read())
# Sende Binaerbild an Matrix:
testImg = "01" * 16 * 8
a = np.array([[0,1,0,0,1,0,1,1,1,1,1,0,0,0,0,0],
                [0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0],
                [0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,0],
                [0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0],
                [0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0],
                [0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0],
                [0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0],
                [0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0],
                [0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0],
                [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0],
                [0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0],
                [0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0]])
b = np.flip(a,1).flatten()
string = "/I"
for e in b:
    string += str(e)
print(string)
conn.request("GET",string)
#r2 = conn.getresponse()
#print(r2.status, r2.reason)
#print(r2.read())

conn.close()