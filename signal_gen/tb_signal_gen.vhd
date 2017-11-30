library ieee;
use ieee.std_logic_1164.all;

entity tb_signal_gen is
end tb_signal_gen;

architecture tb of tb_signal_gen is

    component signal_gen
        port (clk        : in std_logic;
              reset      : in std_logic;
              comparator : in std_logic;
              voltage    : out std_logic_vector (9-1 downto 0);
              pwm_out    : out std_logic);
    end component;

    signal clk        : std_logic;
    signal reset      : std_logic;
    signal comparator : std_logic;
    signal voltage    : std_logic_vector (9-1 downto 0);
    signal pwm_out    : std_logic;

    constant clk_period : time := 10 ps;
    signal clk : std_logic := '0';

begin

    dut : signal_gen
    port map (clk        => clk,
              reset      => reset,
              comparator => comparator,
              voltage    => voltage,
              pwm_out    => pwm_out);

    -- Clock generation
    clk <= not clk after clk_period/2;

    stimuli : process
    begin
        reset <= '0';
        comparator <= '1';
        wait for 1000 * clk_period;

        comparator <= '0';
        wait for 1000 * clk_period;

        comparator <= '1';
        wait for 300 * clk_period;

        comparator <= '0';
        wait for 100 * clk_period;

    end process;

end tb;