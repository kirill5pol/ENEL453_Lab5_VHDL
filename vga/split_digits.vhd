--
--    Split Digits: takes distance (min 9 bits and splits it into 3 digits)
--    
--    Note: 2^10 = 1024, so any logic vectors longer than 10 will be ignored


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digits_box is
    Port ( 	clk         : in  STD_LOGIC;
			reset       : in  STD_LOGIC;
            distance    : in  STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
            bcd_digit_tens  : out STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            bcd_digit_ones  : out STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            bcd_digit_tenths: out STD_LOGIC_VECTOR(3 downto 0)  -- Max number is 9 so we need 4 bits
		  );
end digits_box;

architecture Behavioral of digits_box is
-- Modules ----------------------------------------------------------
component binary_to_bcd is
    generic (
        g_INPUT_WIDTH    : in positive;
        g_DECIMAL_DIGITS : in positive
    );
    port (
        i_Clock  : in  std_logic;
        i_Start  : in  std_logic;
        i_Binary : in  std_logic_vector(g_INPUT_WIDTH-1 downto 0);
        o_BCD    : out std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
        o_DV     : out std_logic
    );
end component;
begin

-- Internal processes ----------------------------------------------------------
    bin_to_bcd: binary_to_bcd
        Port map (
                i_Clock     => clk,
                reset       => reset,
                scan_line_x => scan_line_x,
                scan_line_y => scan_line_y,
                kHz         => i_kHz,
                red         => red,
                blue        => blue,
                green       => green
        );

end Behavioral;

