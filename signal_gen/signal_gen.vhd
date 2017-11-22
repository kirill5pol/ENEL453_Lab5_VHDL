library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity signal_gen is
    Generic (width : integer := 9);
    Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            comparator  : in  STD_LOGIC; -- If 1: increase voltage, If 0: decrease
            voltage     : out STD_LOGIC_VECTOR(width-1 downto 0);
            pwm_out     : out STD_LOGIC
     );
end signal_gen;


architecture Behavioral of signal_gen is
-- Modules ---------------------------------------------------------------------
    component PWM_DAC is
        generic map(width => width)
        Port (
               reset      : in STD_LOGIC;
               clk        : in STD_LOGIC;
               duty_cycle : in STD_LOGIC_VECTOR (width-1 downto 0);
               pwm_out    : out STD_LOGIC
              );
    end component;

-- Internal Signals ------------------------------------------------------------
    i_voltage = STD_LOGIC_VECTOR(width-1 downto 0) := (others => '0');


begin
-- Internal processes ----------------------------------------------------------
    UpdateVoltage: process(clk, reset) -- Todo: fix to remove bit bobble
    begin
        if (reset = '1') then
            -- Reset all outputs    
        elsif (rising_edge(clk)) then
            if (comparator == '1') then
                -- Increase Voltage
                i_voltage = i_voltage + 1;
            elsif (comparator == '0') then
                -- Decrease Voltage
                i_voltage = i_voltage - 1;
            end if;
        end if;
    end process UpdateVoltage;

    voltage <= i_voltage;

-- Module instantiation --------------------------------------------------------
    PWM_DAC_OUTPUT: PWM_DAC
        Port map (
                   clk         => clk,
                   reset       => reset,
                   duty_cycle  => i_voltage,
                   pwm_out     => pwm_out
               );

end Behavioral;
