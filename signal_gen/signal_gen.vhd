--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

--entity signal_gen is
--    Port (
--            clk         : in  STD_LOGIC;
--            reset       : in  STD_LOGIC;
--            comparator  : in  STD_LOGIC; -- If 1: increase voltage, If 0: decrease
--            voltage     : out STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
--            pwm_out     : out STD_LOGIC
--     );
--end signal_gen;


--architecture Behavioral of signal_gen is
---- Modules ---------------------------------------------------------------------
--    component PWM_DAC is
--        Port (
--               reset      : in STD_LOGIC;
--               clk        : in STD_LOGIC;
--               duty_cycle : in STD_LOGIC_VECTOR (9-1 downto 0); -- 9 is width
--               pwm_out    : out STD_LOGIC
--              );
--    end component;

---- Internal Signals ------------------------------------------------------------
--    signal i_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width

--begin
--    check_real_voltage: process(clk, reset)
--    begin
--        if (reset = '1') then
--            i_voltage <= (others => '0');
--        elsif (rising_edge(clk)) then
--            i_voltage <= i_voltage + 1;
--        end if;
--    end process;
    
--    voltage <= i_voltage;

---- Module instantiation --------------------------------------------------------
--    PWM_DAC_OUTPUT: PWM_DAC
--        Port map (
--                   clk         => clk,
--                   reset       => reset,
--                   duty_cycle  => i_voltage,
--                   pwm_out     => pwm_out
--               );

--end Behavioral;













































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
    signal current_voltage: STD_LOGIC_VECTOR(9-1 downto 0) := (others => '0'); -- 9 is width
    signal counter : STD_LOGIC_VECTOR (12-1 downto 0); -- update along with pwm DAC
    
    signal enable: STD_LOGIC := '0';


begin
-- Internal processes ----------------------------------------------------------
    count : process(clk,reset)
    begin
        if( reset = '1') then
            counter <= (others => '0');
            enable <= '0';
        elsif (rising_edge(clk)) then
            if (counter = "111111111111") then
                enable <=  '1';
            elsif (enable = '1') then
                enable <= '0';
            end if;
            counter <= counter + '1';
        end if;
    end process;

    check_real_voltage: process(clk, reset) -- Todo: fix to remove bit bobble
    begin
        if (reset = '1') then
            current_voltage <= (others => '0');
            i_voltage <= (others => '0');
            i_voltage_prev <= (others => '0');

        elsif (rising_edge(clk)) then
            if (enable = '1') then
                if (comparator = '1') then
                    i_voltage <= i_voltage + 1;
                    i_voltage_prev <= i_voltage;
                else
                    i_voltage <= (others => '0');
                    current_voltage <= i_voltage_prev;
                end if;

            end if;
        end if;
    end process ; -- check_real_voltage
    
    voltage <= current_voltage;

-- Module instantiation --------------------------------------------------------
    PWM_DAC_OUTPUT: PWM_DAC
        Port map (
                   clk         => clk,
                   reset       => reset,
                   duty_cycle  => i_voltage,
                   pwm_out     => pwm_out
               );

end Behavioral;