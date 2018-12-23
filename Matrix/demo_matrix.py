import sys
import numpy as np

from Adafruit_LED_Backpack import Matrix8x16
from matrix16x16 import Matrix16x16


if len(sys.argv) > 1:
	txt = sys.argv[1]
else:
	txt="ABCDEFGHIJKLMNO P"
print("Ausgabe sollte sein:",txt)

display = Matrix8x16.Matrix8x16(address=0x70)
display.begin()
display.set_brightness(3)

displaylow = Matrix8x16.Matrix8x16(address=0x71)
displaylow.begin()
displaylow.set_brightness(3)

matrix = Matrix16x16(display, displaylow)
matrix.write_string(txt)

example_img=np.array([
	[0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
	[0,0,0,1,1,0,0,0,0,0,1,1,1,0,0,0],
	[0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
	[0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
	[0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0],
	[0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0],
	[0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0],
	[1,1,1,0,1,1,0,0,0,1,1,0,1,0,1,0],
	[1,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0],
	[1,1,1,0,1,1,0,0,0,1,1,0,1,1,1,0],
	[0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0],
	[0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0],
	[0,0,1,1,0,1,0,0,0,1,0,1,1,0,0,0],
	[0,0,0,1,0,0,1,1,1,0,0,1,0,0,0,0],
	[0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0],
	[0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0],
])
matrix.draw_Image(example_img)
print("finished, to clean Matrix run $python clearMatrix.py")
