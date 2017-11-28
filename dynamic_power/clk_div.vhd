library IEEE;

entity clk_div is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_1x : out STD_LOGIC;
                clk_2x : out STD_LOGIC;
                clk_3x : out STD_LOGIC;
                clk_4x : out STD_LOGIC;
                clk_5x : out STD_LOGIC;
                clk_6x : out STD_LOGIC;
                clk_7x : out STD_LOGIC;
                clk_8x : out STD_LOGIC
        );
end entity clk_div;

architecture Behavioral of clk_div is
-- Modules ---------------------------------------------------------------------
    component divide_by_2 is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_out: out STD_LOGIC
        );
    end component;
begin
-- Module instantiations -------------------------------------------------------
    slowed_clk_1: divide_by_2
        Port map (
                    clk     => clk,
                    reset   => reset,
                    clk_out => clk_1x
        );
    slowed_clk_2: divide_by_2
        Port map (
                    clk     => clk_1x,
                    reset   => reset,
                    clk_out => clk_2x
        );
    slowed_clk_3: divide_by_2
        Port map (
                    clk     => clk_2x,
                    reset   => reset,
                    clk_out => clk_3x
        );
    slowed_clk_4: divide_by_2
        Port map (
                    clk     => clk_3x,
                    reset   => reset,
                    clk_out => clk_4x
        );
    slowed_clk_5: divide_by_2
        Port map (
                    clk     => clk_4x,
                    reset   => reset,
                    clk_out => clk_5x
        );
    slowed_clk_6: divide_by_2
        Port map (
                    clk     => clk_5x,
                    reset   => reset,
                    clk_out => clk_6x
        );
    slowed_clk_7: divide_by_2
        Port map (
                    clk     => clk_6x,
                    reset   => reset,
                    clk_out => clk_7x
        );
    slowed_clk_8: divide_by_2
        Port map (
                    clk     => clk_7x,
                    reset   => reset,
                    clk_out => clk_8x
        );
end Behavioral;