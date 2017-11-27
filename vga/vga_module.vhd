library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_module is
    Port (
            clk         : in  STD_LOGIC;
            distance    : in  STD_LOGIC_VECTOR(9-1 downto 0); -- 9 is dist_width
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
    component digits_box is
        Port (
            clk:          in  STD_LOGIC;
            reset:        in  STD_LOGIC;
            digit_tens:   in  STD_LOGIC_VECTOR(3 downto 0);
            digit_ones:   in  STD_LOGIC_VECTOR(3 downto 0);
            digit_tenths: in  STD_LOGIC_VECTOR(3 downto 0);
            scan_line_x:  in  STD_LOGIC_VECTOR(10 downto 0);
            scan_line_y:  in  STD_LOGIC_VECTOR(10 downto 0);
            --kHz:          in  STD_LOGIC;
            red:          out STD_LOGIC_VECTOR(3 downto 0);
            blue:         out STD_LOGIC_VECTOR(3 downto 0);
            green:        out std_logic_vector(3 downto 0)
        );
    end component;
    component binary_to_bcd is
        generic (
            g_INPUT_WIDTH    : in positive := 9;
            g_DECIMAL_DIGITS : in positive := 4
        );
        Port (
            i_Clock  : in std_logic;
            i_Start  : in std_logic;
            i_Binary : in std_logic_vector(g_INPUT_WIDTH-1 downto 0);
            o_BCD    : out std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
            o_DV     : out std_logic
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

    signal digits_bcd: STD_LOGIC_VECTOR(11 downto 0);
    signal digit_tens: STD_LOGIC_VECTOR(3 downto 0);
    signal digit_ones: STD_LOGIC_VECTOR(3 downto 0);
    signal digit_tenths: STD_LOGIC_VECTOR(3 downto 0);

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
                hHz              => i_hHz
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
    BIN_TO_BCD: binary_to_bcd
        generic map(g_INPUT_WIDTH => 9,
                    g_DECIMAL_DIGITS => 4)
        Port map (
                i_Clock      => clk,
                i_Start      => '1',
                i_Binary     => distance,
                o_BCD        => digits_bcd,
                o_DV         => open
        );
    BOX: digits_box
        Port map (
                clk          => clk,
                reset        => reset,
                digit_tens   => digit_tens,
                digit_ones   => digit_ones,
                digit_tenths => digit_tenths,
                scan_line_x  => scan_line_x,
                scan_line_y  => scan_line_y,
                --kHz          => i_kHz,
                red          => red,
                blue         => blue,
                green        => green
        );

digit_tens <= digits_bcd(11 downto 8);
digit_ones <= digits_bcd(7 downto 4);
digit_tenths <= digits_bcd(3 downto 0);

end Behavioral;

