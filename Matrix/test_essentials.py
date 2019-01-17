import unittest
import fontPlaceholder
import string


class TestFontplaceholder(unittest.TestCase):
    def test_dict(self):
        font = fontPlaceholder.fontPlaceholder()
        allLetters = string.ascii_uppercase                 # test all uppercase Letters
        for char in allLetters:
            self.assertTrue(font.toArray(char).shape[0], 5) #Arrays must all have the same hight, otherwise concat would crash

if __name__ == '__main__':
    unittest.main()