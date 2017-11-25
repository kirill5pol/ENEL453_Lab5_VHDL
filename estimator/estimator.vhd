library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity estimator is
        generic (width: integer := 9);
        Port (
                clk      : in  STD_LOGIC;
                reset    : in  STD_LOGIC;
                voltage  : in  STD_LOGIC_VECTOR(width-1 downto 0);
                distance : out STD_LOGIC_VECTOR(width-1 downto 0)
         );
end estimator;

architecture Behavioral of estimator is
begin
-- Internal processes ----------------------------------------------------------
	distance <= voltage;

end Behavioral;

