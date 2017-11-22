--
--    Digits Box: takes in 3 digits (from 0 to 9) and prints those digits on the 
--                vga monitor.
--    
--    Module of:
--        - vga_module
--
--    Internal singals:
--        - sig_0 - sig_10: A 5x5 matrix that contains a digit from 0-9
--        - sig_dec: A matrix the contains an image of a decimal point
--        - box_loc_x/y_min/max: Min and max indices from x and y
--        - pixel_color: Colour of an individual pixel


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digits_box is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;

            digit_tens: in STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            digit_ones: in STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            digit_tenths: in STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits

			scan_line_x: in STD_LOGIC_VECTOR(10 downto 0);
			scan_line_y: in STD_LOGIC_VECTOR(10 downto 0);
			kHz: in STD_LOGIC;
			red: out STD_LOGIC_VECTOR(3 downto 0);
			blue: out STD_LOGIC_VECTOR(3 downto 0);
			green: out std_logic_vector(3 downto 0)
		  );
end digits_box;

architecture Behavioral of digits_box is

-- Internal Signals  -----------------------------------------------------------
    -- You have 3 digits + 1 decimal point -> 50 by 50 for each -> width 200, height 50
    type MAT is array (4 downto 0) of std_logic_vector(4 downto 0);
    constant sig_0: MAT := (("01110"), ("10001"), ("10001"), ("10001"), ("01110"));
    constant sig_1: MAT := (("00100"), ("00100"), ("00100"), ("00100"), ("00100"));
    constant sig_2: MAT := (("01110"), ("10001"), ("00110"), ("01000"), ("11111"));
    constant sig_3: MAT := (("11110"), ("00001"), ("01110"), ("00001"), ("11110"));
    constant sig_4: MAT := (("00110"), ("01010"), ("11111"), ("00010"), ("00010"));
    constant sig_5: MAT := (("11111"), ("10000"), ("00110"), ("00001"), ("11111"));
    constant sig_6: MAT := (("01111"), ("10000"), ("11110"), ("10001"), ("01110"));
    constant sig_7: MAT := (("11111"), ("00010"), ("00100"), ("01000"), ("10000"));
    constant sig_8: MAT := (("01110"), ("10001"), ("01110"), ("10001"), ("01110"));
    constant sig_9: MAT := (("01111"), ("10001"), ("01111"), ("00010"), ("11100"));
    constant sig_dec: MAT := (("00000"), ("00000"), ("00000"), ("00000"), ("00100"));

    constant box_loc_x_min: std_logic_vector(9 downto 0) := "0000000000";
    constant box_loc_y_min: std_logic_vector(9 downto 0) := "0000000000";
    constant box_loc_x_max: std_logic_vector(9 downto 0) := "1001111111"; -- 640-1 -- 640 is 1010000000
    constant box_loc_y_max: std_logic_vector(9 downto 0) := "0111011111"; -- 480-1 -- 480 is 0111100000
    signal pixel_color: std_logic_vector(11 downto 0);


begin

DrawDigitTens : process(clk, reset)
begin
    if (reset ='1') then
        redraw <= (others => '0');
    elsif (rising_edge(clk)) then
        -- sometinhf;
    end if;
end process ; -- DrawDigits


useless <= initials(105);
pixel_color <= (
                    (  
                        box_color AND 
                        initials(index_of_initials)
                    ) OR 
                    (
                        "111111111111" AND 
                        (NOT initials(index_of_initials)))
                    ) 
          when  ((scan_line_x >= box_loc_x) and 
                 (scan_line_y >= box_loc_y) and 
                 (scan_line_x < box_loc_x+box_width) and 
                 (scan_line_y < box_loc_y+box_width))
        else
                 "111111111111"; -- represents WHITE
								
red   <= pixel_color(11 downto 8);
green <= pixel_color(7 downto 4);
blue  <= pixel_color(3 downto 0);


end Behavioral;

