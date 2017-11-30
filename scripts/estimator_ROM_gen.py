from __future__ import print_function
import numpy as np



bcd_lookup_table = {
    '0': '0000',
    '1': '0001',
    '2': '0010',
    '3': '0011',
    '4': '0100',
    '5': '0101',
    '6': '0110',
    '7': '0111',
    '8': '1000',
    '9': '1001'
}


def num_to_bcd(i, num_digits):
    str_i = str(i).replace('.', '')
    str_i = str_i[0:min(len(str_i), num_digits)]
    for _ in range(num_digits - len(str_i)):
        str_i = '0' + str_i
    str_bcd = ''
    for digit in str_i:
        str_bcd += bcd_lookup_table[digit]
    return str_bcd


def get_ROM_str(key, value, width):
    '''Take a key & value pair, and return a string of a VHDL ROM'''
    rom_str = '    constant {}: ROM := ('.format(key)
    for i in range(2**width):
        rom_str += '("{}"), '.format(value[i])
    rom_str = rom_str[:-2] + ');\n'
    return rom_str


def write_estimator_vhd(filename, values, binary_width=9, num_digits=3):

    # dictionary, key is that name of the ROM, val is values of ROM. All ROMs are same size
    keys = [key for key in values.iterkeys()]
    #---------------------------------------------------------------------------
    code_string = 'library IEEE;\n\
    use IEEE.STD_LOGIC_1164.ALL;\n\
    use IEEE.STD_LOGIC_ARITH.ALL;\n\
    use IEEE.STD_LOGIC_UNSIGNED.ALL;\n\
    \n\
    entity estimator is\n\
            generic (width: integer := {});\n\
            Port (\n\
                    clk        : in  STD_LOGIC;\n\
                    reset      : in  STD_LOGIC;\n'.format(binary_width)
    #---------------------------------------------------------------------------
    # Set which ROM to use as an input
    for key in keys:
        code_string += '                    en_{}: in  STD_LOGIC;\n'.format(key)


    #---------------------------------------------------------------------------
    # Set the size of distance (several binary coded digits concatenated together)
    code_string += '                    voltage    : in  STD_LOGIC_VECTOR(width-1 downto 0);\n\
                    distance   : out STD_LOGIC_VECTOR({}*4-1 downto 0)\n\
            );\n\
    end estimator;\n\
    \n\
    architecture Behavioral of estimator is\n'.format(num_digits)
    code_string += '    type ROM is array (0 to {}) of STD_LOGIC_VECTOR({}*4-1 downto 0);\n'.format(2**binary_width-1, num_digits)

    

    #---------------------------------------------------------------------------
    # Add all ROM definitions here
    for k, v in values.iteritems():
        code_string += get_ROM_str(k,v, binary_width)


    #---------------------------------------------------------------------------
    code_string += '\n\
    begin\n\
    -- Internal processes ----------------------------------------------------------\n\
    select_rom : process(voltage, '


    #---------------------------------------------------------------------------
    # Code for selecting which ROM is used
    code_string += ''.join([' en_{},'.format(key) for key in keys])[1:-1] # Remove trailing comma & space
    
    code_string += ')\n\
    begin\n\
        if (en_{} = \'1\') then\n\
            distance <= {}(CONV_INTEGER(UNSIGNED(voltage)));'.format(keys[0], keys[0])

    for key in keys[1:]:
        code_string += '\n        elsif (en_{} = \'1\') then\n\
            distance <= {}(CONV_INTEGER(UNSIGNED(voltage)));'.format(key, key)

    code_string += '\n        else\n\
            distance <= '
    code_string += ''.join([' & "1111"' for _ in range(num_digits)])[3:] + ';'

    code_string += '\n        end if;\n\
    end process ; -- select_rom\n\
    \nend Behavioral;\n\
    \n'
    #---------------------------------------------------------------------------

    with open(filename, 'w') as f:
        f.write(code_string)


def main(filename='../estimator/estimator.vhd',
         binary_width=9, # Make a rom with 9 bits of accuracy
         num_digits=3,   # The output bcd will be num_digits*4 bits
         max_voltage=3.3,# FPGA voltage is 3.3v
         # The actual function we're using
         distance_func=lambda x:(3.2194*x**4 - 25.53*x**3 + 75.61*x**2 - 102.92*x + 62.383),
         scales={'dists_cm': 1, 'dists_mm': 10, 'dists_in': 0.3937008} # TODO add Wiffle as measurement: 3.2cm
        ):
    # Creates the function to go from voltages to distances
    voltages = np.linspace(0, max_voltage, 2**binary_width) # voltages in volts
    distances = distance_func(voltages) # distances in cm

    # No negative distances are allowed, so clip negatives
    distances = np.maximum(distances, 0)

    # Takes a list of numbers and converts them to bcd strings
    vnum_to_bcd = np.vectorize(num_to_bcd)

    # Get the actual ROMs as a dictionary
    bcd_ROMs = {}
    for name, scale in scales.iteritems():
        bcd_ROMs[name] = vnum_to_bcd(distances * scale, num_digits)

    # Write the file
    write_estimator_vhd(filename, bcd_ROMs, binary_width=binary_width, num_digits=num_digits)


if __name__ == '__main__':
    main()

