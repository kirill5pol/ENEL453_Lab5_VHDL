library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_bin_to_bcd is
end tb_bin_to_bcd;

architecture tb of tb_bin_to_bcd is

    component binary_to_bcd
        port (
                i_Clock  : in std_logic;
                i_Start  : in std_logic;
                i_Binary : in std_logic_vector (9-1 downto 0); -- Set g_input_width to 9
                o_BCD    : out std_logic_vector (3*4-1 downto 0); -- Set g_decimal_digits to 3
                o_DV     : out std_logic
        );
    end component;

    signal i_Clock  : std_logic := '0';
    signal i_Start  : std_logic := '1';
    signal i_Binary : std_logic_vector (9-1 downto 0) := (others <= '0'); -- Set g_input_width to 9
    signal o_BCD    : std_logic_vector (3*4-1 downto 0); -- Set g_decimal_digits to 3
    signal o_DV     : std_logic;

    constant TbPeriod : time := 10 ns; -- Period of clock
    signal TbClock : std_logic := '0';

begin
-- Module to test
    dut : binary_to_bcd
    port map (i_Clock  => i_Clock,
              i_Start  => i_Start,
              i_Binary => i_Binary,
              o_BCD    => o_BCD,
              o_DV     => o_DV);

-- Testbench processes
    -- Clock generation
    clk_process :process
   begin
        TbClock <= '0';
        wait for TbPeriod/2;
        TbClock <= '1';
        wait for TbPeriod/2;
   end process; 

    -- Counter input (eg distance)
    input_counter: process(TbClock)
    begin
        if (rising_edge(TbClock)) then
            i_Binary <= i_Binary + 1;
        end if;
    end process ; -- input_counter

    -- Test Bench process
    stimuli : process
    begin
        wait for 1000 * TbPeriod;
    end process;

end tb;
