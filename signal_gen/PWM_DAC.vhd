library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM_DAC is
    Port ( 
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           duty_cycle : in STD_LOGIC_VECTOR (9-1 downto 0); -- 9 is width
           pwm_out : out STD_LOGIC
          );
end PWM_DAC;

architecture Behavioral of PWM_DAC is
--    signal counter : STD_LOGIC_VECTOR (9 downto 0); -- original
    signal counter : STD_LOGIC_VECTOR (9-1 downto 0); -- corrected -- 9 is width
        
begin
    count : process(clk,reset)
    begin
        if( reset = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then 
            counter <= counter + '1';
        end if;
    end process;
  
    compare : process(counter, duty_cycle)
    begin    
        if (counter < duty_cycle) then
            pwm_out <= '1';
        else 
            pwm_out <= '0';
        end if;
    end process;
  
end Behavioral;
