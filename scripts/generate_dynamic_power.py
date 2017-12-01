	
def main():
	clk_divider = '\nlibrary IEEE;\
	\nuse IEEE.STD_LOGIC_1164.ALL;\
	\nuse IEEE.STD_LOGIC_UNSIGNED.ALL;\
	\n\
	\nentity clk_div is\
	\n        Port (\
	\n                clk    : in  STD_LOGIC;\
	\n                reset  : in  STD_LOGIC;'
	clk_divider += ''.join(['\n                clk_{}x : out STD_LOGIC;'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '\n        );\
	\nend entity clk_div;\
	\n\
	\narchitecture Behavioral of clk_div is\
	\n-- Modules ---------------------------------------------------------------------\
	\n    component divide_by_2 is\
	\n        Port (\
	\n                clk    : in  STD_LOGIC;\
	\n                reset  : in  STD_LOGIC;\
	\n                clk_out: out STD_LOGIC\
	\n        );\
	\n    end component;'
	clk_divider += ''.join(['\n    signal i_clk_{}x : STD_LOGIC := \'0\';'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '\nbegin\
	\n-- Module instantiations -------------------------------------------------------'
	clk_divider += '\n    slowed_clk_1: divide_by_2\
	\n        Port map (\
	\n                    clk     => clk,\
	\n                    reset   => reset,\
	\n                    clk_out => i_clk_1x\
	\n        );\n'
	clk_divider += ''.join(['\n    slowed_clk_{}: divide_by_2\
	\n        Port map (\
	\n                    clk     => i_clk_{},\
	\n                    reset   => reset,\
	\n                    clk_out => i_clk_{}x\
	\n        );\n'.format(i, i-1, i) for i in range(1,BINARY_WIDTH_GENERIC)])
	clk_divider += ''.join(['\n    clk_{}x <= i_clk_{}x;'.format(i, i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '\n\
	\nend Behavioral;'
	
	
	divide_by_2 = '\
	\nlibrary IEEE;\
	\nuse IEEE.STD_LOGIC_1164.ALL;\
	\nuse IEEE.STD_LOGIC_UNSIGNED.ALL;\
	\n\
	\nentity divide_by_2 is\
	\n        Port (\
	\n                clk    : in  STD_LOGIC;\
	\n                reset  : in  STD_LOGIC;\
	\n                clk_out: out STD_LOGIC\
	\n        );\
	\nend entity divide_by_2;\
	\n\
	\narchitecture Behavioral of divide_by_2 is\
	\n    signal i_clk_out: STD_LOGIC := \'0\';\
	\nbegin\
	\n\
	\n    clk_divide_by_2 : process(clk, reset)\
	\n    begin\
	\n        if reset=\'1\' then\
	\n            i_clk_out <= \'0\';\
	\n        elsif rising_edge(clk) then\
	\n            i_clk_out <= not i_clk_out;\
	\n        end if;\
	\n    end process;\
	\n    \
	\n    clk_out <= i_clk_out;\
	\n\
	\n\
	\nend Behavioral;'
	
	
	
	dynamic_clk = '\nlibrary IEEE;\
	\nuse IEEE.STD_LOGIC_1164.ALL;\
	\nuse IEEE.STD_LOGIC_ARITH.ALL;\
	\nuse IEEE.STD_LOGIC_UNSIGNED.ALL;\
	\n\
	\n\
	\n-- Dynamic Clk: \
	\n--    - Takes a voltage and a clk, and slows down or speeds up the clk based on\
	\n--      how much the voltage is changing.\
	\n--    - When voltage is changing slowly then you can detect changes to the signal\
	\n--      with high accuracy at a slower rate. By using a slower clk cycle you\
	\n--      significantly save power (CMOS circuits use almost no static power)\
	\n--\
	\n-- Internal process:\
	\n--    - Compare voltage measured to previous voltages (XOR), the the most \
	\n--      significant high bit, eg for "000111111" the bit is 5. Divide the clk by\
	\n--      2^(width-1-5) = 2^3 clk cycles.\
	\n\
	\n\
	\nentity dynamic_clk is\
	\n        Port (\
	\n                clk      : in  STD_LOGIC;\
	\n                reset    : in  STD_LOGIC;\
	\n                voltage  : in  STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0); -- BINARY_WIDTH_GENERIC is width\
	\n                out_clk  : out STD_LOGIC\
	\n         );\
	\nend dynamic_clk;\
	\n\
	\narchitecture Behavioral of dynamic_clk is\
	\n-- Internal modules ------------------------------------------------------------\
	\n    component clk_div is\
	\n            Port (\
	\n                clk    : in  STD_LOGIC;\
	\n                reset  : in  STD_LOGIC;\
	'
	dynamic_clk += ''.join(['\n                clk_{}x : out STD_LOGIC;'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	dynamic_clk += '\n            );\
	\n    end component;\
	\n-- Internal signals ------------------------------------------------------------\
	\n    signal prev_voltage: STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0) := (others => \'0\');\
	\n    signal diff_voltage: STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0) := (others => \'1\'); -- XOR of voltage & prev_voltage\
	\n'
	dynamic_clk += ''.join(['\n    signal clk_{}x: STD_LOGIC := \'0\';'.format(i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '\n\
	\nbegin\
	\n-- Module instantiations -------------------------------------------------------\
	\n    clk_divider: clk_div\
	\n        port map (\
	\n            clk    => clk,\
	\n            reset  => reset,'
	dynamic_clk += ''.join(['\n            clk_{}x => clk_{}x'.format(i,i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '\n        );\
	\n-- Internal processes ----------------------------------------------------------\
	\n    seq : process(clk,reset)\
	\n    begin\
	\n        if (reset = \'1\') then\
	\n            prev_voltage <= (others => \'0\');\
	\n            diff_voltage <= (others => \'1\');\
	\n            out_clk <= clk;\
	\n        elsif (rising_edge(clk)) then -- By using clk \
	\n            prev_voltage <= voltage;\
	\n            diff_voltage <= voltage XNOR prev_voltage;\
	\n        end if;\
	\n    end process;\
	\n\
	\n    slow_clk : process(diff_voltage, clk,'
	dynamic_clk += ''.join(['clk_{}x'.format(i,i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '\n    begin\
	\n        if (diff_voltage(9-1) = \'0\') then -- (9-1-0) -- slow clk by 2^0 = same speed\
	\n            out_clk <= clk;\
	\n        elsif (diff_voltage(9-2) = \'0\') then -- (9-1-1) -- slow clk by 2^1\
	\n            out_clk <= clk_1x;\
	\n        elsif (diff_voltage(9-3) = \'0\') then -- (9-1-2) -- slow clk by 2^2\
	\n            out_clk <= clk_2x;\
	\n        elsif (diff_voltage(9-4) = \'0\') then -- (9-1-3) -- slow clk by 2^3\
	\n            out_clk <= clk_3x;\
	\n        elsif (diff_voltage(9-5) = \'0\') then -- (9-1-4) -- slow clk by 2^4\
	\n            out_clk <= clk_4x;\
	\n        elsif (diff_voltage(9-6) = \'0\') then -- (9-1-5) -- slow clk by 2^5\
	\n            out_clk <= clk_5x;\
	\n        elsif (diff_voltage(9-7) = \'0\') then -- (9-1-6) -- slow clk by 2^6\
	\n            out_clk <= clk_6x;\
	\n        elsif (diff_voltage(9-8) = \'0\') then -- (9-1-7) -- slow clk by 2^7\
	\n            out_clk <= clk_7x;\
	\n        elsif (diff_voltage(9-9) = \'0\') then -- (9-1-8) -- slow clk by 2^8\
	\n            out_clk <= clk_8x;\
	\n        end if;\
	\n    end process;\
	\n\
	\nend Behavioral;\
	\n'
	dynamic_clk = dynamic_clk.replace('BINARY_WIDTH_GENERIC', str(BINARY_WIDTH_GENERIC))


    with open('./dynamic_clk/clk_divider', 'w') as f:
        f.write(clk_divider)

    with open('./dynamic_clk/divide_by_2', 'w') as f:
        f.write(divide_by_2)

    with open('./dynamic_clk/dynamic_clk', 'w') as f:
        f.write(dynamic_clk)
