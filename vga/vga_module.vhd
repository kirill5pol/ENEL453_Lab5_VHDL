library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_module is
    Generic (dist_width : integer := 9); -- Optional sig digs for the distance
    Port (
            clk         : in  STD_LOGIC;
            distance    : in  STD_LOGIC_VECTOR(dist_width-1 downto 0);
            red         : out STD_LOGIC_VECTOR(3 downto 0);
            green       : out STD_LOGIC_VECTOR(3 downto 0);
            blue        : out STD_LOGIC_VECTOR(3 downto 0);
            hsync       : out STD_LOGIC;
            vsync       : out STD_LOGIC
     );
end vga_module;

architecture Behavioral of vga_module is
-- Modules ---------------------------------------------------------------------
    component sync_signals_generator is
        Port (
            pixel_clk       : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            hor_sync        : out STD_LOGIC;
            ver_sync        : out STD_LOGIC;
            blank           : out STD_LOGIC;
            scan_line_x     : out STD_LOGIC_VECTOR(10 downto 0);
            scan_line_y     : out STD_LOGIC_VECTOR(10 downto 0)
        );
    end component;
    component clock_divider is
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            enable          : in STD_LOGIC;
            kHz             : out STD_LOGIC;      
            seconds_port    : out STD_LOGIC_VECTOR(4-1 downto 0); -- unused
            ten_seconds_port: out STD_LOGIC_VECTOR(3-1 downto 0); -- unused
            minutes_port    : out STD_LOGIC_VECTOR(4-1 downto 0); -- unused
            ten_minutes_port: out STD_LOGIC_VECTOR(3-1 downto 0); -- unused
            twentyfive_MHz  : out STD_LOGIC;
            hHz             : out STD_LOGIC
        );
    end component;

    component bouncing_box is
        Port (
            clk            : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            scan_line_x    : in STD_LOGIC_VECTOR(10 downto 0);
            scan_line_y    : in STD_LOGIC_VECTOR(10 downto 0);
            kHz            : in STD_LOGIC;
            red            : out STD_LOGIC_VECTOR(3 downto 0);
            blue           : out STD_LOGIC_VECTOR(3 downto 0);
            green          : out std_logic_vector(3 downto 0)
        );
    end component;

-- Internal Signals ------------------------------------------------------------
    signal reset: std_logic;
    -- Clock divider signals:
    signal i_kHz, i_hHz, i_pixel_clk: std_logic;
    -- Sync module signals:
    signal vga_blank : std_logic;
    signal scan_line_x, scan_line_y: STD_LOGIC_VECTOR(10 downto 0);
    -- Box size signals:
    signal inc_box, dec_box: std_logic;
begin

-- Module Instantiation --------------------------------------------------------
    VGA_SYNC: sync_signals_generator
        Port map(
                pixel_clk   => i_pixel_clk,
                reset       => reset,
                hor_sync    => hsync,
                ver_sync    => vsync,
                blank       => vga_blank,
                scan_line_x => scan_line_x,
                scan_line_y => scan_line_y
        );

    DIVIDER: clock_divider
        Port map (
                clk              => clk,
                reset            => reset,
                kHz              => i_kHz,
                twentyfive_MHz   => i_pixel_clk,
                enable           => '1',
                seconds_port     => open,
                ten_seconds_port => open,
                minutes_port     => open,
                ten_minutes_port => open,
                hHz              => i_hHz
        );
    BOX: bouncing_box
        Port map (
                clk         => clk,
                reset       => reset,
                scan_line_x => scan_line_x,
                scan_line_y => scan_line_y,
                kHz         => i_kHz,
                red         => red,
                blue        => blue,
                green       => green
        );


-- Internal Processes ----------------------------------------------------------


end Behavioral;

