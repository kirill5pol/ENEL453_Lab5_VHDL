library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main_module is
    Port ( 
            -- Main signals
            reset      : in  STD_LOGIC;
            clk        : in  STD_LOGIC;
            -- Select units
            en_dists_cm: in STD_LOGIC;
            en_dists_in: in STD_LOGIC;
            -- VGA signals
            red       : out STD_LOGIC_VECTOR(3 downto 0);
            green     : out STD_LOGIC_VECTOR(3 downto 0);
            blue      : out STD_LOGIC_VECTOR(3 downto 0);
            hsync     : out STD_LOGIC;
            vsync     : out STD_LOGIC;
            -- Comparator signals
            comparator : in  STD_LOGIC; -- If 1: increase voltage, If 0: decrease
            en_led     : out STD_LOGIC_VECTOR; -- Enable the LEDs
            led        : out STD_LOGIC_VECTOR(9-1 downto 0); -- LEDs displaying the current value of the comparator
            pwm_out    : out STD_LOGIC
          );
end main_module;


architecture Behavioral of main_module is
-- Modules ---------------------------------------------------------------------
    --component dynamic_clk is
    --    Port (
    --            clk         : in  STD_LOGIC;
    --            reset       : in  STD_LOGIC;
    --            voltage     : out STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is width
    --            out_clk     : out STD_LOGIC
    --     );
    --end component;
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
                clk        : in  STD_LOGIC;
                reset      : in  STD_LOGIC;
                en_dists_cm: in  STD_LOGIC;
                en_dists_in: in  STD_LOGIC;
                voltage    : in  STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is the width
                distance   : out STD_LOGIC_VECTOR(4*4-1 downto 0)
         );
    end component;
    component vga_module is
        Port (
                clk         : in  STD_LOGIC;
                reset       : in  STD_LOGIC;
                distance_bcd: in  STD_LOGIC_VECTOR(4*4-1 downto 0); -- estimated distance -- 3 digits of 4 bits (bcd)
                red         : out STD_LOGIC_VECTOR(3 downto 0);
                green       : out STD_LOGIC_VECTOR(3 downto 0);
                blue        : out STD_LOGIC_VECTOR(3 downto 0);
                hsync       : out STD_LOGIC;
                vsync       : out STD_LOGIC
         );
    end component;

-- Internal Signals ------------------------------------------------------------
    signal voltage : STD_LOGIC_VECTOR (9-1 downto 0); -- the approximate voltage -- 9 is width
    signal distance: STD_LOGIC_VECTOR (4*4-1 downto 0); -- the estimated distance (0.0-30.0) needs at least 9 bits -- 9 is width
    --signal dyn_clk : STD_LOGIC := '0'; -- A clock that slows down when you don't need to update as quickly
begin

-- Module instantiations -------------------------------------------------------
--    DYNAMIC_POWER_CONSUMPTION: dynamic_clk
--        Port map (
--                clk         => clk,
--                reset       => reset,
--                voltage     => voltage,
--                out_clk     => dyn_clk
--            );
    ADC_SIGNAL_GEN: signal_gen
        Port map (
                clk         => clk,
                reset       => reset,
                comparator  => comparator,
                voltage     => voltage,
                pwm_out     => pwm_out
            );
    DISTANCE_ESTIMATOR: estimator -- Note: remeber that the RNN state is internal
        Port map (
                clk         => clk,--dyn_clk, -- Estimation doesn't need to be as fast if the voltage is changing slowly
                reset       => reset,
                en_dists_cm => en_dists_cm,
                en_dists_in => en_dists_in,
                voltage     => voltage,
                distance    => distance
            );
    VGA_DISPLAY: vga_module
        Port map ( 
                clk         => clk,
                reset       => reset,
                distance_bcd=> distance,
                red         => red,
                green       => green,
                blue        => blue,
                hsync       => hsync,
                vsync       => vsync
            );

-- LEDs & fun stuff
    led <= voltage;

end Behavioral;
