from __future__ import print_function


"""
    Get signals 5x5: A script to generate the ROM for vhdl (need to remove some 
    stuff and add other stuff)
"""


sig_0 = [['-', '0', '0', '0', '-'],
         ['0', '-', '-', '-', '0'],
         ['0', '-', '-', '-', '0'],
         ['0', '-', '-', '-', '0'],
         ['-', '0', '0', '0', '-']][::-1]

sig_1 = [['-', '-', '1', '-', '-'],
         ['-', '-', '1', '-', '-'],
         ['-', '-', '1', '-', '-'],
         ['-', '-', '1', '-', '-'],
         ['-', '-', '1', '-', '-']][::-1]

sig_2 = [['-', '2', '2', '2', '-'],
         ['2', '-', '-', '-', '2'],
         ['-', '-', '2', '2', '-'],
         ['-', '2', '-', '-', '-'],
         ['2', '2', '2', '2', '2']][::-1]

sig_3 = [['3', '3', '3', '3', '-'],
         ['-', '-', '-', '-', '3'],
         ['-', '3', '3', '3', '-'],
         ['-', '-', '-', '-', '3'],
         ['3', '3', '3', '3', '-']][::-1]

sig_4 = [['-', '-', '4', '4', '-'],
         ['-', '4', '-', '4', '-'],
         ['4', '4', '4', '4', '4'],
         ['-', '-', '-', '4', '-'],
         ['-', '-', '-', '4', '-']][::-1]

sig_5 = [['5', '5', '5', '5', '5'],
         ['5', '-', '-', '-', '-'],
         ['-', '-', '5', '5', '-'],
         ['-', '-', '-', '-', '5'],
         ['5', '5', '5', '5', '5']][::-1]

sig_6 = [['-', '6', '6', '6', '6'],
         ['6', '-', '-', '-', '-'],
         ['6', '6', '6', '6', '-'],
         ['6', '-', '-', '-', '6'],
         ['-', '6', '6', '6', '-']][::-1]

sig_7 = [['7', '7', '7', '7', '7'],
         ['-', '-', '-', '7', '-'],
         ['-', '-', '7', '-', '-'],
         ['-', '7', '-', '-', '-'],
         ['7', '-', '-', '-', '-']][::-1]

sig_8 = [['-', '8', '8', '8', '-'],
         ['8', '-', '-', '-', '8'],
         ['-', '8', '8', '8', '-'],
         ['8', '-', '-', '-', '8'],
         ['-', '8', '8', '8', '-']][::-1]

sig_9 = [['-', '9', '9', '9', '9'],
         ['9', '-', '-', '-', '9'],
         ['-', '9', '9', '9', '9'],
         ['-', '-', '-', '9', '-'],
         ['9', '9', '9', '-', '-']][::-1]


rotate90 = lambda mat: zip(*mat[::-1])
rotate270 = lambda mat: rotate90(rotate90(rotate90(mat)))
sig_0, sig_1, sig_1, sig_2, sig_3, sig_4, sig_5, sig_6, sig_7, sig_8, sig_9 = [rotate270(sig_0), rotate270(sig_1), rotate270(sig_1), rotate270(sig_2), rotate270(sig_3), rotate270(sig_4), rotate270(sig_5), rotate270(sig_6), rotate270(sig_7), rotate270(sig_8), rotate270(sig_9)]


scale = 5 # Scale the image by this size new image will be (scale*5 by scale*5 pixels)

rom_str = ''
for i, sig in enumerate([sig_0, sig_1, sig_2, sig_3, sig_4, sig_5, sig_6, sig_7, sig_8, sig_9]):
    scaled_sig = []
    for row in sig:
        current_row = []
        for character in row:
            current_row += [character for _ in range(scale)]
        scaled_sig += [current_row for _ in range(scale)]

    rom_str += 'sig_{} = ('.format(i), end=''
    for string in scaled_sig:
        rom_str += '("', end=''
        for character in string:
            if character == '-':
                rom_str += '0', end=''
            else:
                rom_str += '1', end=''
        rom_str += '"), ',end=''
    rom_str += ');'