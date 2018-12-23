import time
import numpy as np

from PIL import Image
from PIL import ImageDraw	
from Adafruit_LED_Backpack import Matrix8x16
from fontPlaceholder import fontPlaceholder



def draw_img(display, np_array):
	if display is None:
		return
	assert(np_array.shape == (8,16))
	display.clear()
	# Run through each pixel individually and turn it on.
	for x in range(8):
		for y in range(16):
			display.set_pixel(x, y, np_array[x,y])
	display.write_display()
	return

def add_padding(data):
	padding = np.zeros((data.shape[0],16), dtype=int)
	return np.concatenate((data, padding), axis=1)


def draw_periodic(display,full_array, times=1, padding=False, flip=False):
	if display is None:
		return
	max = full_array.shape[1]
	if padding:
		full_array=add_padding(full_array)
		max += (times-1)*16
	offset = 0
	if flip:
		offset = 15 # Text in andere richtung durchlaufen index 0->15 index 15->0
	times = times*max + 1	#1=zum schluss wieder an erster Stelle (x[0])
	if padding:
		times -= 16 #zum schluss nurnoch das Padding (leeres Array) anzeigen
	array = np.zeros((8,16))

	for i in range(times):
		for k in range(16):
			array[:,offset-k] = full_array[:,(k+i) % max]
 		draw_img(display, array)
		time.sleep(0.125)
	return


def string_to_array(text, f, shape=8):
	textArray = np.zeros((8,1))
	for letter in text:
		textArray = np.concatenate((textArray,f.toArray(letter)), axis=1)
	if shape==16:
		z = np.zeros((4,textArray.shape[1]))
		print("z.shape vor ",textArray.shape)
		textArray = np.concatenate((z,textArray), axis=0)
		textArray = np.concatenate((textArray,z), axis=0)
		print("z.shape nach",textArray.shape)

	return textArray


def matrix16x16simulation(data, topdisplay=None, botdisplay=None, times=1, flip=True):
	print("shape of inputdata:",data.shape)
	if topdisplay is None or botdisplay is None:
		print("displays ot spezified, just usefull for testings!")
	if flip:
		data = np.flip(data, axis=1)
	
	print("times not implemented Yet!")
	tmp = data[:,:16]
	draw_img(topdisplay, tmp[:8])
	draw_img(botdisplay, tmp[8:])

	
display = Matrix8x16.Matrix8x16(address=0x70)
display.begin()
display.set_brightness(3)

f = fontPlaceholder()
textArray8 = string_to_array("ABCDEF",f)
textArray16 = string_to_array("ABCDEF",f , shape=16)
draw_periodic(display, textArray8, times=2, padding=True, flip=True)
a = input("weiter mit Zahl:")
matrix16x16simulation(textArray16, display, None, times=2, flip=True)


testIcon = np.array([[0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0],
					 [0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0],
					 [0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0],
					 [1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
					 [0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
					 [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0],
					 [0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0],
					 [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1]])

#draw_img(display, testIcon)

full_sine = np.array([[0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			[0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
			[1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1],
			[0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1],
			[0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0],
			[0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0],
			[0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0]])

#draw_periodic(display, full_sine, times=2, padding=True)
#draw_periodic(display, full_sine, times=1)

topBotIcon = np.array([[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
					 [1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1],
					 [0,0,1,0,0,1,1,0,0,1,1,1,0,0,1,1],
					 [0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,1],
					 [0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,1],
					 [0,0,1,0,0,1,1,0,0,1,1,1,0,0,1,1],
					 [0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1],
					 [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
					 [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
					 [0,1,1,1,0,0,0,0,0,0,0,1,0,0,1,1],
					 [0,1,0,0,1,0,0,0,0,0,1,1,1,0,1,1],
					 [0,1,1,1,0,0,0,1,1,0,0,1,0,0,1,1],
					 [0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,1],
					 [0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,1],
					 [0,1,1,1,0,0,0,1,1,0,0,0,1,0,1,1],
					 [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1]])


#matrix16x16simulation(topBotIcon,display,None)
#a = input("now it will change to Bot:")
#matrix16x16simulation(topBotIcon,None,display)

