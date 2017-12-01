library IEEE;
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
                voltage  : in  STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
                out_clk  : out STD_LOGIC
         );
end dynamic_clk;

architecture Behavioral of dynamic_clk is
-- Internal modules ------------------------------------------------------------
    component clk_div is
            Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_1x : out STD_LOGIC;
                clk_2x : out STD_LOGIC;
                clk_3x : out STD_LOGIC;
                clk_4x : out STD_LOGIC;
                clk_5x : out STD_LOGIC;
                clk_6x : out STD_LOGIC;
                clk_7x : out STD_LOGIC;
                clk_8x : out STD_LOGIC
            );
    end component;
-- Internal signals ------------------------------------------------------------
    signal prev_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0');
    signal diff_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '1'); -- XOR of voltage & prev_voltage

    signal clk_1x: STD_LOGIC := '0'; -- These are clks slowed down 2^n times
    signal clk_2x: STD_LOGIC := '0';
    signal clk_3x: STD_LOGIC := '0'; -- Eg this one is 2^3 = 8x slower than clk
    signal clk_4x: STD_LOGIC := '0';
    signal clk_5x: STD_LOGIC := '0';
    signal clk_6x: STD_LOGIC := '0';
    signal clk_7x: STD_LOGIC := '0';
    signal clk_8x: STD_LOGIC := '0'; -- 2^8 = 256x slower

begin
-- Module instantiations -------------------------------------------------------
    clk_divider: clk_div
        port map (
            clk    => clk,
            reset  => reset,
            clk_1x => clk_1x,
            clk_2x => clk_2x,
            clk_3x => clk_3x,
            clk_4x => clk_4x,
            clk_5x => clk_5x,
            clk_6x => clk_6x,
            clk_7x => clk_7x,
            clk_8x => clk_8x
        );
-- Internal processes ----------------------------------------------------------
    seq : process(clk,reset)
    begin
        if (reset = '1') then
            prev_voltage <= (others => '0');
            diff_voltage <= (others => '1');
            out_clk <= clk;
        elsif (rising_edge(clk)) then -- By using clk 
            prev_voltage <= voltage;
            diff_voltage <= voltage XNOR prev_voltage;
        end if;
    end process;

    slow_clk : process(diff_voltage, clk,
                       clk_1x, clk_2x, 
                       clk_3x, clk_4x, 
                       clk_5x, clk_6x,
                       clk_7x, clk_8x)
    begin
        if (diff_voltage(9-1) = '0') then -- (9-1-0) -- slow clk by 2^0 = same speed
            out_clk <= clk;
        elsif (diff_voltage(9-2) = '0') then -- (9-1-1) -- slow clk by 2^1
            out_clk <= clk_1x;
        elsif (diff_voltage(9-3) = '0') then -- (9-1-2) -- slow clk by 2^2
            out_clk <= clk_2x;
        elsif (diff_voltage(9-4) = '0') then -- (9-1-3) -- slow clk by 2^3
            out_clk <= clk_3x;
        elsif (diff_voltage(9-5) = '0') then -- (9-1-4) -- slow clk by 2^4
            out_clk <= clk_4x;
        elsif (diff_voltage(9-6) = '0') then -- (9-1-5) -- slow clk by 2^5
            out_clk <= clk_5x;
        elsif (diff_voltage(9-7) = '0') then -- (9-1-6) -- slow clk by 2^6
            out_clk <= clk_6x;
        elsif (diff_voltage(9-8) = '0') then -- (9-1-7) -- slow clk by 2^7
            out_clk <= clk_7x;
        elsif (diff_voltage(9-9) = '0') then -- (9-1-8) -- slow clk by 2^8
            out_clk <= clk_8x;
        end if;
    end process;

end Behavioral;

