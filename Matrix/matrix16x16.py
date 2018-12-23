import time
import numpy as np
from fontPlaceholder import fontPlaceholder

class Matrix16x16:
    def __init__(self, topdisplay=None, botdisplay=None, flip=True, fonttype=None, debug=False):
        if topdisplay is None or botdisplay is None:
            print("displays not initialized, just usefull for testings!")
        if fonttype is None:
            self.f = fontPlaceholder()
        else:
            print("only None fonttype implemented Yet!")
            self.f = fontPlaceholder
        self.debug=debug                # if Debug flag is set, no Matrix will be necessary
        self.top = topdisplay
        self.bot = botdisplay
        self.flip = flip

    #Zeichnet aktuelles 8x16 Bild auf teil Matrix
    def draw8x16(self, display, np_array):
        assert (np_array.shape == (8, 16))
        if self.debug:
            print(np_array) #debug=Keine LEDMatrix verfuegbar
            return
        if display is None:
            return
        display.clear()
        # Run through each pixel individually and turn it on.
        for x in range(8):
            for y in range(16):
                display.set_pixel(x, y, np_array[x, y])
        display.write_display()
        return

    #Zeichnet aktuelles 16x16 Bild auf gesammte Matrix
    def draw_Image(self, data):
        #if self.flip:
        #    data = np.flip(data, axis=1)
        tmp = data[:, :16]
        self.draw8x16(self.top, tmp[:8])
        self.draw8x16(self.bot, tmp[8:])
        if self.debug:
            print("\n########################################\n")
    # text=string wird in np_array umgewandelt (oben und unten=freier Rand von 4 Pixel)
    def string_to_array(self, text):
        textArray = np.zeros((8, 1),dtype=int)
        for letter in text:
            textArray = np.concatenate((textArray, self.f.toArray(letter)), axis=1)
        z = np.zeros((4, textArray.shape[1]),dtype=int)
        textArray = np.concatenate((z, textArray), axis=0)
        textArray = np.concatenate((textArray, z), axis=0)
        return textArray

    def write_string(self, textinput, padding=True):
        data_Array = self.string_to_array(textinput)
        if padding:
            data_Array = self.add_padding(data_Array, True) # Leeres Feld davor
            data_Array = self.add_padding(data_Array, False)# Leeres Feld danach
        self.shift_long_data(data_Array)

    def shift_long_data(self, data, speed=0.125):
        max = data.shape[1]
        offset = 0
        if self.flip:
            offset = 15             # Text in andere richtung durchlaufen index 0->15 index 15->0
        array = np.zeros((16, 16), dtype=int)  # Bildausschnitt 16x16
        for i in range(max-15):
            for k in range(16):
                array[:, offset - k] = data[:, i+k]
            self.draw_Image(array)
            time.sleep(speed)
        return


    def add_padding(self, data, front):
        padding = np.zeros((data.shape[0], 16), dtype=int)
        if front:
            return np.concatenate((data, padding), axis=1)
        return np.concatenate((padding,data), axis=1)



if __name__ == '__main__':
    print("okay, lets go!")
    matrix = Matrix16x16(debug=True)
    matrix.draw_Image(np.zeros((16,16), dtype=int))
    matrix.write_string("AAA")

