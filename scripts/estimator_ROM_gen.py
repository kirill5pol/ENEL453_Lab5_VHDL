from __future__ import print_function
import numpy as np

binary_width = 9

x = np.linspace(0, 2**binary_width-1, 2**binary_width) # voltage
y = (-5E-07)*(x/10.)**5 + (6E-05)*(x/10.)**4 - (0.0028)*(x/10.)**3 + (0.0662)*(x/10.)**2 - (0.8254)*(x/10.) + 5.1286 # distance
np.clip(y, 0, ((2**binary_width-1)/10.), out=y) # limit distances to 0 - 51.1 cm

# Takes ndarray converts to binary str, remove the '0b', & left fill with 0s to proper width
bin_and_fill = lambda a: bin(a)[2:].zfill(binary_width)
vectorized_bin = np.vectorize(bin_and_fill)

x_int = x.astype(np.int)
y_int = (y*10.).astype(np.int) # Take value in cm and convert to mm (assume between 0-51.1cm)

x_bin = vectorized_bin(x_int) # this should be 0 to 3.3 -> represented a a logic vec between 0s and 1s
y_bin = vectorized_bin(y_int) # this should be 0 to 30

addresses = x_bin
values = y_bin



rom_str = 'type ROM is array (0 to {}) of STD_LOGIC_VECTOR({} downto 0);\n'.format(2**binary_width-1, binary_width-1)
rom_str += '    constant estimator_rom: ROM := ('
for i, addr in enumerate(addresses):
	rom_str += '("{}"), '.format(values[i])
rom_str = rom_str[:-2] + ');'

code_string = 'library IEEE;\n\
use IEEE.STD_LOGIC_1164.ALL;\n\
use IEEE.STD_LOGIC_ARITH.ALL;\n\
use IEEE.STD_LOGIC_UNSIGNED.ALL;\n\
\n\
entity estimator is\n\
        generic (width: integer := {});\n\
        Port (\n\
                clk      : in  STD_LOGIC;\n\
                reset    : in  STD_LOGIC;\n\
                voltage  : in  STD_LOGIC_VECTOR(width-1 downto 0);\n\
                distance : out STD_LOGIC_VECTOR(width-1 downto 0)\n\
         );\n\
end estimator;\n\
\n\
architecture Behavioral of estimator is\n\
    {}\n\
\n\
begin\n\
-- Internal processes ----------------------------------------------------------\n\
    distance <= estimator_rom(CONV_INTEGER(UNSIGNED(voltage)));\n\
\n\
end Behavioral;\n\
\n\
'.format(binary_width, rom_str)


filename = '../estimator/estimator.vhd'
with open(filename, 'w') as f:
	f.write(code_string)

