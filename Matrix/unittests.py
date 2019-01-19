import unittest
import fontPlaceholder
import string
import matrix16x16
import numpy as np
import stringHandler


class TestFontplaceholder(unittest.TestCase):
    def test_dict(self):
        font = fontPlaceholder.fontPlaceholder()
        allLetters = string.ascii_uppercase                 # test all uppercase Letters
        for char in allLetters:
            self.assertTrue(font.toArray(char).shape[0], 5) #Arrays must all have the same hight, otherwise concat would crash
        return

class TestMatrix16x16(unittest.TestCase):
    def test_init(self):
        matrix = matrix16x16.Matrix16x16(debug=True)
        l1 = matrix.draw_Image(np.zeros((16, 16), dtype=int))
        self.assertTrue(l1[0].sum() == 0)       # input was array of zeros, so sum of output should be 0
        self.assertTrue(l1[1].sum() == 0)
        self.assertEqual(l1[0].shape, (8,16))   # shape of returnvalue must equal 8x16 matrix
        self.assertEqual(l1[1].shape, (8,16))
        l2 = matrix.write_string("AAA")
        self.assertTrue(l2[0][0].sum() == 0)         #bevore and after the message is displayed, screen should be turned off
        self.assertTrue(l2[-1][0].sum() == 0)
        for i in range(3,len(l2)-1):
            self.assertTrue(l2[i].sum() > 0)    #on each step between joining and leaving the matrix, something should be displayed
                                                # if something is displayed, at least one LED is high (sum of all LEDs > 0)
        return

    def test_only_usefull_with_Hardware_connected(self):
        if not HARDWARE_CONNECTED:
            self.assertTrue(True)   # if no hardware is connected, this test will be skiped
            return
        try:
            from Adafruit_LED_Backpack import Matrix8x16

            display = Matrix8x16.Matrix8x16(address=0x70)
            display.begin()
            display.set_brightness(3)

            displaylow = Matrix8x16.Matrix8x16(address=0x71)
            displaylow.begin()
            displaylow.set_brightness(3)

            matrix = matrix16x16.Matrix16x16(display, displaylow)
            matrix.write_string("testcase on hardware")
            self.assertTrue(True)                                   #hardware test was successfull (on codeside) if correct text is displayed
                                                                    #has to be checked by a human.
        except:
            self.assertTrue(False)                                  #something went wrong by connecting to Hardware
        return

class testStringhandler(unittest.TestCase):

    def test_text(self):
        sh = stringHandler.StringHandler(imgChar="I", stringChar="S", imgSize=16 * 16, matrix16x16=None)
        testString = string.ascii_lowercase
        result = sh.handleString("S" + testString)
        for i in range(len(result)):
            self.assertEqual(testString[i].upper(), result[i])  #ech char should be returned as upper
                                                                #in case, that our font only supports upper chars
        return

    def test_image(self):
        sh = stringHandler.StringHandler(imgChar="I", stringChar="S", imgSize=16 * 16, matrix16x16=None)
        testImg = "01" * 16 * 8
        result = sh.handleString("I" + testImg)
        self.assertEqual(result.shape,(16,16))                  #an Image always needs shape 16x16 to be displayed on matrix
        self.assertTrue(result.min() == 0)                      #an Image is representated as binary so value has to be 0 or 1
        self.assertTrue(result.max() == 1)
        self.assertEqual(result[0][0], 0)                       #just to check the outcomming result equals the expected sequence of 0 and 1
        self.assertEqual(result[0][1], 1)

        from time import sleep
        sleep(1)                                                #just to be shure all prints are done bevore unittest prints his result
        return

if __name__ == '__main__':
    HARDWARE_CONNECTED = False  # change this flag to true, if hardware (16x16 matrix) is connected.
    unittest.main()