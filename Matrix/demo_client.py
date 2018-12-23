import http.client

conn = http.client.HTTPConnection("localhost", 8000)
# Sende String an Matrix:
conn.request("GET","S"+"HalloWelt132")
r1 = conn.getresponse()
print(r1.status, r1.reason)
print(r1.read())
# Sende Binaerbild an Matrix:
testImg = "01" * 16 * 8
conn.request("GET","I"+testImg)
r2 = conn.getresponse()
print(r2.status, r2.reason)
print(r2.read())

conn.close()