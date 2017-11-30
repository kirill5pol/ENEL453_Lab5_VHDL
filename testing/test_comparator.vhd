library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main_module is
    Port ( -- Main signals
           reset      : in  STD_LOGIC;
           clk        : in  STD_LOGIC;
            -- VGA signals
            red       : out STD_LOGIC_VECTOR(3 downto 0);
            green     : out STD_LOGIC_VECTOR(3 downto 0);
            blue      : out STD_LOGIC_VECTOR(3 downto 0);
            hsync     : out STD_LOGIC;
            vsync     : out STD_LOGIC;
            -- Comparator signals
            comparator : in  STD_LOGIC; -- If 1: increase voltage, If 0: decrease
            pwm_out    : out STD_LOGIC
          );
end main_module;


architecture Behavioral of main_module is
-- Modules ---------------------------------------------------------------------
    component dynamic_clk is
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                voltage     : out STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
                out_clk     : out STD_LOGIC
         );
    end component;
    component signal_gen is
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                comparator  : in  STD_LOGIC;
                voltage     : out STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
                pwm_out     : out STD_LOGIC
         );
    end component;
    component estimator is
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                voltage     : in  STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
                distance    : out STD_LOGIC_VECTOR(9-1 downto 0) -- 9 is width
         );
    end component;
    component vga_module is
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                distance    : in  STD_LOGIC_VECTOR(9-1 downto 0); -- estimated distance -- 9 is width
                red         : out STD_LOGIC_VECTOR(3 downto 0);
                green       : out STD_LOGIC_VECTOR(3 downto 0);
                blue        : out STD_LOGIC_VECTOR(3 downto 0);
                hsync       : out STD_LOGIC;
                vsync       : out STD_LOGIC
         );
    end component;

-- Internal Signals ------------------------------------------------------------
    signal voltage : STD_LOGIC_VECTOR (9-1 downto 0); -- the approximate voltage -- 9 is width
    signal distance0: STD_LOGIC_VECTOR (9-1 downto 0); -- the estimated distance (0.0-30.0) needs at least 9 bits -- 9 is width
    signal distance: STD_LOGIC_VECTOR (9-1 downto 0); -- the estimated distance (0.0-30.0) needs at least 9 bits -- 9 is width
begin

-- Module instantiations -------------------------------------------------------
    dis: process(comparator)
    begin
        if (comparator = '1') then
            distance <= (others => '1');
        else
            distance <= (others => '0');
        end if;
    end process;
    VGA_DISPLAY: vga_module
        Port map (
                clk         => clk,
                reset       => reset,
                distance    => distance,
                red         => red,
                green       => green,
                blue        => blue,
                hsync       => hsync,
                vsync       => vsync
            );

end Behavioral;