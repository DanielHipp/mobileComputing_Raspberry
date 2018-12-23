#from http.server import HTTPServer, BaseHTTPRequestHandler
import BaseHTTPServer
import stringHandler
from matrix16x16 import Matrix16x16


class RequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        # Send the html message
        #self.wfile.write("JA?")
        request_path = self.path
        STRINGHANDLER.handleString(request_path,ignoreErrors=True)
        #print("path:\t",request_path)
        #print("headers:\t",self.headers)
        #self.send_response(200)
        return

if __name__ == '__main__':
    port = 8000
    MATRIX_AVALIABLE = True
    #Set MATRIX_AVALIABLE to True if this script runs on your Raspberry
    if MATRIX_AVALIABLE:
        from Adafruit_LED_Backpack import Matrix8x16

        display = Matrix8x16.Matrix8x16(address=0x70)
        display.begin()
        display.set_brightness(3)

        displaylow = Matrix8x16.Matrix8x16(address=0x71)
        displaylow.begin()
        displaylow.set_brightness(3)

        matrix = Matrix16x16(display, displaylow)
    else:
        matrix = None

    # OBJECT will be used from server to send Data to Matrix
    STRINGHANDLER = stringHandler.StringHandler(imgChar='I', stringChar='S', imgSize=16 * 16, matrix16x16=matrix)

    print("server Running on Port",port)
    server = BaseHTTPServer.HTTPServer(('',port), RequestHandler)
    server.serve_forever()
