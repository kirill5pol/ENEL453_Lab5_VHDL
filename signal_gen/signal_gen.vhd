library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity signal_gen is
    Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            comparator  : in  STD_LOGIC; -- If 1: increase voltage, If 0: decrease
            voltage     : out STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
            pwm_out     : out STD_LOGIC
     );
end signal_gen;


architecture Behavioral of signal_gen is
-- Modules ---------------------------------------------------------------------
    component PWM_DAC is
        Port (
               reset      : in STD_LOGIC;
               clk        : in STD_LOGIC;
               duty_cycle : in STD_LOGIC_VECTOR (9-1 downto 0); -- 9 is width
               pwm_out    : out STD_LOGIC
              );
    end component;

-- Internal Signals ------------------------------------------------------------
    signal i_voltage     : STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width
    signal i_voltage_prev: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width

    constant min_voltage : STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width
    constant max_voltage : STD_LOGIC_VECTOR(9-1 downto 0) := (others => '1'); -- 9 is width

    signal counter : STD_LOGIC_VECTOR (9-1 downto 0); -- update along with pwm DAC


begin
-- Internal processes ----------------------------------------------------------
    count : process(clk,reset)
    begin
        if( reset = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            counter <= counter + '1';
        end if;
    end process;

    check_real_voltage: process(clk, reset, counter) -- Todo: fix to remove bit bobble
    begin
        if (reset = '1') then
            voltage <= (others => '0');
            i_voltage <= (others => '0');
            i_voltage_prev <= (others => '0');

        elsif (rising_edge(clk) AND (counter(9-1 downto 0) = "111111111")) then
            if (comparator = '0') then
                voltage <= i_voltage_prev; -- Copy the voltage change
                i_voltage <= (others => '0'); -- Reset the ramp
            else
                i_voltage <= i_voltage + 1;
                i_voltage_prev <= i_voltage;
            end if;

        end if;
    end process ; -- check_real_voltage

-- Module instantiation --------------------------------------------------------
    PWM_DAC_OUTPUT: PWM_DAC
        Port map (
                   clk         => clk,
                   reset       => reset,
                   duty_cycle  => i_voltage,
                   pwm_out     => pwm_out
               );

end Behavioral;
