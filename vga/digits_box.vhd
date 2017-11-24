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
    Port ( 	clk:          in  STD_LOGIC;
			reset:        in  STD_LOGIC;

            digit_tens:   in  STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            digit_ones:   in  STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits
            digit_tenths: in  STD_LOGIC_VECTOR(3 downto 0); -- Max number is 9 so we need 4 bits

			scan_line_x:  in  STD_LOGIC_VECTOR(10 downto 0);
			scan_line_y:  in  STD_LOGIC_VECTOR(10 downto 0);
			--kHz:          in  STD_LOGIC;
			red:          out STD_LOGIC_VECTOR(3 downto 0);
			blue:         out STD_LOGIC_VECTOR(3 downto 0);
			green:        out std_logic_vector(3 downto 0)
		  );
end digits_box;

architecture Behavioral of digits_box is

-- Internal Signals  -----------------------------------------------------------
    -- You have 3 digits + 1 decimal point -> 50 by 50 for each -> width 200, height 50
    type MAT is array (24 downto 0) of std_logic_vector(24 downto 0);
    constant sig_0: MAT := (("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"));
    constant sig_1: MAT := (("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"));
    constant sig_2: MAT := (("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"));
    constant sig_3: MAT := (("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"));
    constant sig_4: MAT := (("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000011111000001111100000"), ("0000011111000001111100000"), ("0000011111000001111100000"), ("0000011111000001111100000"), ("0000011111000001111100000"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"));
    constant sig_5: MAT := (("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000111111111100000"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("0000000000000000000011111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"));
    constant sig_6: MAT := (("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111111111111111111100000"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"));
    constant sig_7: MAT := (("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000000000111110000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("0000011111000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"), ("1111100000000000000000000"));
    constant sig_8: MAT := (("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"), ("0000011111111111111100000"));
    constant sig_9: MAT := (("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("1111100000000000000011111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000011111111111111111111"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("0000000000000001111100000"), ("1111111111111110000000000"), ("1111111111111110000000000"), ("1111111111111110000000000"), ("1111111111111110000000000"), ("1111111111111110000000000"));
    constant sig_E: Mat := (("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"), ("1111111111111111111111111"));

    constant box_loc_x_min: STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
    constant box_loc_y_min: STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
    constant box_loc_x_max: STD_LOGIC_VECTOR(9 downto 0) := "1001111111"; -- 640-1 -- 640 is 1010000000
    constant box_loc_y_max: STD_LOGIC_VECTOR(9 downto 0) := "0111011111"; -- 480-1 -- 480 is 0111100000
    signal pixel_color:     STD_LOGIC_VECTOR(11 downto 0);

    -- Offset from 0,0 for digits & scale factor
    constant offset_x:      STD_LOGIC_VECTOR(9 downto 0) := "0000010000"; -- Offset 16 pixels
    constant offset_y:      STD_LOGIC_VECTOR(9 downto 0) := "0000010000"; -- Offset 16 pixels
    constant digit_size:    STD_LOGIC_VECTOR(9 downto 0) := "0000011001"; -- Digit size is 25x25 pixels
    constant padding:       STD_LOGIC_VECTOR(9 downto 0) := "0000000100"; -- Padding is 4 pixels

    signal pos_start_x_sig_digit_tens:   STD_LOGIC_VECTOR(9 downto 0);
    signal pos_start_x_sig_digit_ones:   STD_LOGIC_VECTOR(9 downto 0);
    signal pos_start_x_sig_digit_tenths: STD_LOGIC_VECTOR(9 downto 0);
    signal pos_end_x_sig_digit_tens:     STD_LOGIC_VECTOR(9 downto 0);
    signal pos_end_x_sig_digit_ones:     STD_LOGIC_VECTOR(9 downto 0);
    signal pos_end_x_sig_digit_tenths:   STD_LOGIC_VECTOR(9 downto 0);
    signal pos_start_y:                  STD_LOGIC_VECTOR(9 downto 0); -- All digits share these
    signal pos_end_y:                    STD_LOGIC_VECTOR(9 downto 0); -- All digits share these

    signal sig_digit_tens: MAT;
    signal sig_digit_ones: MAT;
    signal sig_digit_tenths: MAT;

    signal currently_sig_digit_tens:    STD_LOGIC := '0';
    signal currently_sig_digit_ones:    STD_LOGIC := '0';
    signal currently_sig_digit_tenths:  STD_LOGIC := '0';
    signal pos_start_x_current_sig: STD_LOGIC_VECTOR(9 downto 0); -- The pos_start_x_sig for the current digit
    signal current_sig_x_offset: integer := 0; -- Used for indexing the current sig_digit MAT
    signal current_sig_y_offset: integer := 0;
begin


-- Internal processes  ---------------------------------------------------------
    -- Get the start & end positions for all of the digit boxes
        -- Possibly hard code these:
        pos_start_x_sig_digit_tens   <= offset_x;
        pos_start_x_sig_digit_ones   <= offset_x + digit_size + padding;
        pos_start_x_sig_digit_tenths <= offset_x + digit_size + padding + digit_size + padding;
        pos_end_x_sig_digit_tens     <= offset_x + digit_size;
        pos_end_x_sig_digit_ones     <= offset_x + digit_size + padding + digit_size;
        pos_end_x_sig_digit_tenths   <= offset_x + digit_size + padding + digit_size + padding + digit_size;
        -- All digits share these y positions
        pos_start_y                  <= offset_y;
        pos_end_y                    <= offset_y + digit_size;

    -- Figure out which digit (if any is currently being shown)
        currently_sig_digit_tens <= '1'
                when (scan_line_x >= pos_start_x_sig_digit_tens) AND
                     (scan_line_x <  pos_end_x_sig_digit_tens) AND
                     (scan_line_y >= pos_start_y) AND
                     (scan_line_y <  pos_end_y) AND
                else '0';
        currently_sig_digit_ones <= '1'
                when (scan_line_x >= pos_start_x_sig_digit_ones) AND
                     (scan_line_x <  pos_end_x_sig_digit_ones) AND
                     (scan_line_y >= pos_start_y) AND
                     (scan_line_y <  pos_end_y) AND
                else '0';
        currently_sig_digit_tenths <= '1'
                when (scan_line_x >= pos_start_x_sig_digit_tenths) AND
                     (scan_line_x <  pos_end_x_sig_digit_tenths) AND
                     (scan_line_y >= pos_start_y) AND
                     (scan_line_y <  pos_end_y) AND
                else '0';

    -- Get the x & y offset INSIDE a digit
        -- The starting pos of the digit you are currently in (or 0s if not in digit)
        pos_start_x_current_sig <=
                (pos_start_x_sig_digit_tens AND currently_sig_digit_tens) OR
                (pos_start_x_sig_digit_ones AND currently_sig_digit_ones) OR
                (pos_start_x_sig_digit_tenths AND currently_sig_digit_tenths) OR
                (others => '0');
        -- Determine how many pixels from the start of the current digit the scan lines are
        current_sig_x_offset <= TO_INTEGER(UNSIGNED(scan_line_x - pos_start_x_current_sig));
        current_sig_y_offset <= TO_INTEGER(UNSIGNED(scan_line_y - pos_start_y));

    -- TODO: refactor to only use CURRENT digit not all three!
    -- Get the values of the current digits
        FIRST_DIGIT: process(digit_tens,sig_0,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_E)
        begin
            case digit_tens is
                when "0000" => sig_digit_tens <= sig_0;
                when "0001" => sig_digit_tens <= sig_1;
                when "0010" => sig_digit_tens <= sig_2;
                when "0011" => sig_digit_tens <= sig_3;
                when "0100" => sig_digit_tens <= sig_4;
                when "0101" => sig_digit_tens <= sig_5;
                when "0110" => sig_digit_tens <= sig_6;
                when "0111" => sig_digit_tens <= sig_7;
                when "1000" => sig_digit_tens <= sig_8;
                when "1001" => sig_digit_tens <= sig_9;
                when others => sig_digit_tens <= sig_E;
            end case;
        end process;
        SECOND_DIGIT: process(digit_ones,sig_0,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_E)
        begin
            case digit_tens is
                when "0000" => digit_ones <= sig_0;
                when "0001" => digit_ones <= sig_1;
                when "0010" => digit_ones <= sig_2;
                when "0011" => digit_ones <= sig_3;
                when "0100" => digit_ones <= sig_4;
                when "0101" => digit_ones <= sig_5;
                when "0110" => digit_ones <= sig_6;
                when "0111" => digit_ones <= sig_7;
                when "1000" => digit_ones <= sig_8;
                when "1001" => digit_ones <= sig_9;
                when others => digit_ones <= sig_E;
            end case;
        end process;
        THIRD_DIGIT: process(digit_tenths,sig_0,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_E)
        begin
            case digit_tens is
                when "0000" => sig_digit_tenths <= sig_0;
                when "0001" => sig_digit_tenths <= sig_1;
                when "0010" => sig_digit_tenths <= sig_2;
                when "0011" => sig_digit_tenths <= sig_3;
                when "0100" => sig_digit_tenths <= sig_4;
                when "0101" => sig_digit_tenths <= sig_5;
                when "0110" => sig_digit_tenths <= sig_6;
                when "0111" => sig_digit_tenths <= sig_7;
                when "1000" => sig_digit_tenths <= sig_8;
                when "1001" => sig_digit_tenths <= sig_9;
                when others => sig_digit_tenths <= sig_E;
            end case;
        end process;

    -- Select the color
        pixel_color <= "111111111111"; -- TODO make this work...

        pixel_color <= ( -- When it matches a pixel representing a digit
                        current_sig_x_offset
                        current_sig_y_offset
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

