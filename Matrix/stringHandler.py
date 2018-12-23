import numpy as np
from math import sqrt

class StringHandler:

    def __init__(self, imgChar, stringChar, imgSize, matrix16x16=None):
        self.imgChar = imgChar
        self.stringChar = stringChar
        self.imgSize = int(imgSize)
        self.matrix = matrix16x16
        sqrtI = sqrt(imgSize)
        if sqrtI-int(sqrtI) != 0.0:
            raise Exception("imgSize must be Quadratic!")
        self.shape = (int(sqrtI),int(sqrtI))

    def handleString(self, inpt, ignoreErrors=False):
        assert isinstance(inpt,str)
        if(inpt[0] == self.imgChar):
            x = self.handleImage(inpt[1:])
            if not ignoreErrors:
                if x is None:
                    raise Exception("Illegal Argument! String starts with 'I' but can`t be casted as Image!")
            if self.matrix is None:
                print("Image:\n",x)
                return
            self.matrix.draw_Image(x)
        elif(inpt[0] == self.stringChar):
            if self.matrix is None:
                print("String:\n",inpt[1:])
                return
            self.matrix.write_string(inpt[1:])
        elif not ignoreErrors:
            raise Exception("Illegal Argument! String has to start with {} or {}".format(self.imgChar,self.stringChar))
        return

    def handleImage(self, img):
        assert isinstance(img, str)
        assert len(img) == self.imgSize
        array = np.zeros(self.imgSize, dtype=int)
        try:
            for i in range(self.imgSize):
                array[i]=int(img[i])
        except:
            return None
        return array.reshape(self.shape)

if __name__ == '__main__':
    sh = StringHandler(imgChar="I",stringChar="S", imgSize=16*16, matrix16x16=None)
    testString = "a"*16*16
    print(sh.handleString("S"+testString))
    testImg = "01"*16*8
    print(sh.handleString("I"+testImg))
