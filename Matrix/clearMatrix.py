from Adafruit_LED_Backpack import Matrix8x16

try:
	display = Matrix8x16.Matrix8x16(address=0x70)
	display.begin()
	display.clear()
	display.write_display()
except:
	print("0x70 cant be cleared")
try:
	display = Matrix8x16.Matrix8x16(address=0x71)
	display.begin()
	display.clear()
	display.write_display()
except:
	print("0x71 cant be cleared")


