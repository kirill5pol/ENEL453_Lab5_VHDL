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
    signal i_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width
    signal min_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width
    signal max_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '1'); -- 9 is width


begin
-- Internal processes ----------------------------------------------------------
    UpdateVoltage: process(clk, reset) -- Todo: fix to remove bit bobble
    begin
        if (reset = '1') then
            -- Reset all outputs    
        elsif (rising_edge(clk)) then
            if (comparator = '1') then
                -- Increase Voltage
                if (i_voltage < max_voltage) then
                    i_voltage <= i_voltage + 1;
                    end if;
            elsif (comparator = '0') then
                -- Decrease Voltage
                if (i_voltage > min_voltage) then
                    i_voltage <= i_voltage - 1;
                    end if;
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
