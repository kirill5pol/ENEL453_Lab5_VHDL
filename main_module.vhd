library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main_module is
    Generic (width: integer := 9); -- Optional sig digs for the pwm_out & internal voltage
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
    component signal_gen is
        generic (width: integer := 9);
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                comparator  : in  STD_LOGIC;
                voltage     : out STD_LOGIC_VECTOR(width-1 downto 0);
                pwm_out     : out STD_LOGIC
         );
    end component;
    component estimator is
        generic (width: integer := 9);
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                voltage     : in  STD_LOGIC_VECTOR(width-1 downto 0);
                distance    : out STD_LOGIC_VECTOR(width-1 downto 0)
         );
    end component;
    component vga_module is
        generic (width: integer := 9);
        Port (
                clk         : in  STD_LOGIC;
                --reset       : in  STD_LOGIC;
                distance    : in  STD_LOGIC_VECTOR(width-1 downto 0); -- estimated distance
                red         : out STD_LOGIC_VECTOR(3 downto 0);
                green       : out STD_LOGIC_VECTOR(3 downto 0);
                blue        : out STD_LOGIC_VECTOR(3 downto 0);
                hsync       : out STD_LOGIC;
                vsync       : out STD_LOGIC
         );
    end component;

-- Internal Signals ------------------------------------------------------------
    signal voltage : STD_LOGIC_VECTOR (width-1 downto 0); -- the approximate voltage
    signal distance: STD_LOGIC_VECTOR (width-1 downto 0); -- the estimated distance (0.0-30.0) needs at least 9 bits
    
begin

-- Module instantiations -------------------------------------------------------
    ADC_SIGNAL_GEN: signal_gen
        generic map(width => width)

        Port map (
                clk         => clk,
                reset       => reset,
                comparator  => comparator,
                voltage     => voltage,
                pwm_out     => pwm_out
            );
    DISTANCE_ESTIMATOR: estimator -- Note: remeber that the RNN state is internal
        generic map(width => width)

        Port map (
                clk         => clk,
                reset       => reset,
                voltage     => voltage,
                distance    => distance
            );
    VGA_DISPLAY: vga_module
        generic map(dist_width => width)
        Port map ( 
                clk          => clk,
                --reset       => reset,
                distance     => distance,
                red          => red,
                green        => green,
                blue         => blue,
                hsync        => hsync,
                vsync        => vsync
            );

end Behavioral;
