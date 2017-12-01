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
               duty_cycle : in STD_LOGIC_VECTOR (10-1 downto 0); -- 9 is width
               pwm_out    : out STD_LOGIC
              );
    end component;

-- Internal Signals ------------------------------------------------------------
-- Is equal to 1 when the estimation is finished
signal copy_buffer: STD_LOGIC; -- Essentially an enable for copying whatever is the 'current' approximation of the voltage

signal i_voltage: 

begin
-- Internal processes ----------------------------------------------------------\
    count : process(clk,reset)
    begin
        if( reset = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            if (counter(10-1) = '1') then
                counter <= (others => '0');
            else
                counter <= counter + '1';
            end if;
        end if;
    end process;

    update_internal_voltage: process(clk, reset) -- Todo: fix to remove bit bobble
    begin
        if (reset = '1') then
            -- Reset all outputs    
        elsif (rising_edge(clk) AND (counter(10-1) = '1') then
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
    end process update_internal_voltage;

    -- Process to update the output voltage only if the difference between updates is large
    update_output_voltage : process(clk, reset)
    begin
        if (reset = '1' then)
            voltage <= (others => '0');
            i_voltage_prev <= (others => '0');
        elsif (rising_edge(clk)) then
            if (voltage_update_diff > min_diff) then
                voltage <= i_voltage;
                i_voltage_prev <= i_voltage;
            end if ;
        end if;
    end process ; -- update_output_voltage

    voltage_update_diff <= i_voltage XNOR i_voltage_prev;

-- Module instantiation --------------------------------------------------------
    PWM_DAC_OUTPUT: PWM_DAC
        Port map (
                   clk         => clk,
                   reset       => reset,
                   duty_cycle  => i_voltage,
                   pwm_out     => pwm_out
               );

end Behavioral;
