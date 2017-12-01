library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_module is
    Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            distance_bcd: in  STD_LOGIC_VECTOR(4*4-1 downto 0);
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
            enable          : in  STD_LOGIC;
            kHz             : out STD_LOGIC;      
            seconds_port    : out STD_LOGIC_VECTOR(4-1 downto 0); -- unused
            ten_seconds_port: out STD_LOGIC_VECTOR(3-1 downto 0); -- unused
            minutes_port    : out STD_LOGIC_VECTOR(4-1 downto 0); -- unused
            ten_minutes_port: out STD_LOGIC_VECTOR(3-1 downto 0); -- unused
            twentyfive_MHz  : out STD_LOGIC;
            --daHz            : out STD_LOGIC -- update digits every tenth of a second
            Hz              : out STD_LOGIC -- update digits every second
        );
    end component;
    component digits_box is
        Port (
            clk:          in  STD_LOGIC;
            reset:        in  STD_LOGIC;
            distance_bcd: in  STD_LOGIC_VECTOR(4*4-1 downto 0);
            scan_line_x:  in  STD_LOGIC_VECTOR(10 downto 0);
            scan_line_y:  in  STD_LOGIC_VECTOR(10 downto 0);
            --kHz:          in  STD_LOGIC;
            red:          out STD_LOGIC_VECTOR(3 downto 0);
            blue:         out STD_LOGIC_VECTOR(3 downto 0);
            green:        out std_logic_vector(3 downto 0)
        );
    end component;

-- Internal Signals ------------------------------------------------------------
    -- Clock divider signals:
    --signal i_kHz, i_daHz, i_pixel_clk: std_logic;
    signal i_kHz, i_Hz, i_pixel_clk: std_logic;
    -- Sync module signals:
    signal vga_blank : std_logic;
    signal scan_line_x, scan_line_y: STD_LOGIC_VECTOR(10 downto 0);
    -- Box size signals:
    signal inc_box, dec_box: std_logic;

    signal i_distance_bcd: STD_LOGIC_VECTOR(4*4-1 downto 0);

begin
-- Module Instantiation --------------------------------------------------------
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
                --daHz             => i_daHz
                Hz               => i_Hz
        );
    VGA_SYNC: sync_signals_generator
        Port map(
                pixel_clk    => i_pixel_clk,
                reset        => reset,
                hor_sync     => hsync,
                ver_sync     => vsync,
                blank        => vga_blank,
                scan_line_x  => scan_line_x,
                scan_line_y  => scan_line_y
        );

    DELAY_DIGITS: process(i_Hz, reset) -- only update the digits once a second on the vga
    begin
        if (reset = '1') then
            i_distance_bcd <= (others => '0');
        elsif (rising_edge(i_Hz)) then
        --elsif (rising_edge(i_daHz)) then
            i_distance_bcd <= distance_bcd;
        end if;
    end process;


    BOX: digits_box
        Port map (
                clk          => clk,
                reset        => reset,
                distance_bcd => i_distance_bcd,
                scan_line_x  => scan_line_x,
                scan_line_y  => scan_line_y,
                --kHz          => i_kHz,
                red          => red,
                blue         => blue,
                green        => green
        );


end Behavioral;

