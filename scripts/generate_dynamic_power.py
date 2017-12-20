	
def main():
	clk_divider = '''\nlibrary IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk_div is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;'''
	clk_divider += ''.join(['\n                clk_{}x : out STD_LOGIC;'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '''\n        );
end entity clk_div;

architecture Behavioral of clk_div is
-- Modules ---------------------------------------------------------------------
    component divide_by_2 is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_out: out STD_LOGIC
        );
    end component;'''
	clk_divider += ''.join(['\n    signal i_clk_{}x : STD_LOGIC := \'0\';'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '''\nbegin
-- Module instantiations -------------------------------------------------------'
	clk_divider += '\n    slowed_clk_1: divide_by_2
        Port map (
                    clk     => clk,
                    reset   => reset,
                    clk_out => i_clk_1x
        );\n'
	clk_divider += ''.join(['\n    slowed_clk_{}: divide_by_2
        Port map (
                    clk     => i_clk_{},
                    reset   => reset,
                    clk_out => i_clk_{}x
        );\n'.format(i, i-1, i) for i in range(1,BINARY_WIDTH_GENERIC)])
	clk_divider += ''.join(['\n    clk_{}x <= i_clk_{}x;'.format(i, i) for i in range(BINARY_WIDTH_GENERIC)])
	clk_divider += '\n
end Behavioral;'''
	
	
	divide_by_2 = '''
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divide_by_2 is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_out: out STD_LOGIC
        );
end entity divide_by_2;

architecture Behavioral of divide_by_2 is
    signal i_clk_out: STD_LOGIC := \'0\';
begin

    clk_divide_by_2 : process(clk, reset)
    begin
        if reset=\'1\' then
            i_clk_out <= \'0\';
        elsif rising_edge(clk) then
            i_clk_out <= not i_clk_out;
        end if;
    end process;
    
    clk_out <= i_clk_out;


end Behavioral;'''
	
	
	
	dynamic_clk = '''\nlibrary IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Dynamic Clk: 
--    - Takes a voltage and a clk, and slows down or speeds up the clk based on
--      how much the voltage is changing.
--    - When voltage is changing slowly then you can detect changes to the signal
--      with high accuracy at a slower rate. By using a slower clk cycle you
--      significantly save power (CMOS circuits use almost no static power)
--
-- Internal process:
--    - Compare voltage measured to previous voltages (XOR), the the most 
--      significant high bit, eg for "000111111" the bit is 5. Divide the clk by
--      2^(width-1-5) = 2^3 clk cycles.


entity dynamic_clk is
        Port (
                clk      : in  STD_LOGIC;
                reset    : in  STD_LOGIC;
                voltage  : in  STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0); -- BINARY_WIDTH_GENERIC is width
                out_clk  : out STD_LOGIC
         );
end dynamic_clk;

architecture Behavioral of dynamic_clk is
-- Internal modules ------------------------------------------------------------
    component clk_div is
            Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;\
	'''
	dynamic_clk += ''.join(['\n                clk_{}x : out STD_LOGIC;'.format(i) for i in range(BINARY_WIDTH_GENERIC)])
	dynamic_clk += '''\n            );
    end component;
-- Internal signals ------------------------------------------------------------
    signal prev_voltage: STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0) := (others => \'0\');
    signal diff_voltage: STD_LOGIC_VECTOR(BINARY_WIDTH_GENERIC-1 downto 0) := (others => \'1\'); -- XOR of voltage & prev_voltage
'''
	dynamic_clk += ''.join(['\n    signal clk_{}x: STD_LOGIC := \'0\';'.format(i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '''\n
begin
-- Module instantiations -------------------------------------------------------
    clk_divider: clk_div
        port map (
            clk    => clk,
            reset  => reset,'''
	dynamic_clk += ''.join(['\n            clk_{}x => clk_{}x'.format(i,i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '''\n        );
-- Internal processes ----------------------------------------------------------
    seq : process(clk,reset)
    begin
        if (reset = \'1\') then
            prev_voltage <= (others => \'0\');
            diff_voltage <= (others => \'1\');
            out_clk <= clk;
        elsif (rising_edge(clk)) then -- By using clk 
            prev_voltage <= voltage;
            diff_voltage <= voltage XNOR prev_voltage;
        end if;
    end process;

    slow_clk : process(diff_voltage, clk,'''
	dynamic_clk += ''.join(['clk_{}x'.format(i,i) for i in range(1,BINARY_WIDTH_GENERIC)])
	dynamic_clk += '''\n    begin
        if (diff_voltage(9-1) = \'0\') then -- (9-1-0) -- slow clk by 2^0 = same speed
            out_clk <= clk;
        elsif (diff_voltage(9-2) = \'0\') then -- (9-1-1) -- slow clk by 2^1
            out_clk <= clk_1x;
        elsif (diff_voltage(9-3) = \'0\') then -- (9-1-2) -- slow clk by 2^2
            out_clk <= clk_2x;
        elsif (diff_voltage(9-4) = \'0\') then -- (9-1-3) -- slow clk by 2^3
            out_clk <= clk_3x;
        elsif (diff_voltage(9-5) = \'0\') then -- (9-1-4) -- slow clk by 2^4
            out_clk <= clk_4x;
        elsif (diff_voltage(9-6) = \'0\') then -- (9-1-5) -- slow clk by 2^5
            out_clk <= clk_5x;
        elsif (diff_voltage(9-7) = \'0\') then -- (9-1-6) -- slow clk by 2^6
            out_clk <= clk_6x;
        elsif (diff_voltage(9-8) = \'0\') then -- (9-1-7) -- slow clk by 2^7
            out_clk <= clk_7x;
        elsif (diff_voltage(9-9) = \'0\') then -- (9-1-8) -- slow clk by 2^8
            out_clk <= clk_8x;
        end if;
    end process;

end Behavioral;
'''
	dynamic_clk = dynamic_clk.replace('BINARY_WIDTH_GENERIC', str(BINARY_WIDTH_GENERIC))


    with open('./dynamic_clk/clk_divider', 'w') as f:
        f.write(clk_divider)

    with open('./dynamic_clk/divide_by_2', 'w') as f:
        f.write(divide_by_2)

    with open('./dynamic_clk/dynamic_clk', 'w') as f:
        f.write(dynamic_clk)
