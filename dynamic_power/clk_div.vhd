library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    signal i_clk_1x : STD_LOGIC := '0';
    signal i_clk_2x : STD_LOGIC := '0';
    signal i_clk_3x : STD_LOGIC := '0';
    signal i_clk_4x : STD_LOGIC := '0';
    signal i_clk_5x : STD_LOGIC := '0';
    signal i_clk_6x : STD_LOGIC := '0';
    signal i_clk_7x : STD_LOGIC := '0';
    signal i_clk_8x : STD_LOGIC := '0';

begin
-- Module instantiations -------------------------------------------------------
    slowed_clk_1: divide_by_2
        Port map (
                    clk     => clk,
                    reset   => reset,
                    clk_out => i_clk_1x
        );
    slowed_clk_2: divide_by_2
        Port map (
                    clk     => i_clk_1x,
                    reset   => reset,
                    clk_out => i_clk_2x
        );
    slowed_clk_3: divide_by_2
        Port map (
                    clk     => i_clk_2x,
                    reset   => reset,
                    clk_out => i_clk_3x
        );
    slowed_clk_4: divide_by_2
        Port map (
                    clk     => i_clk_3x,
                    reset   => reset,
                    clk_out => i_clk_4x
        );
    slowed_clk_5: divide_by_2
        Port map (
                    clk     => i_clk_4x,
                    reset   => reset,
                    clk_out => i_clk_5x
        );
    slowed_clk_6: divide_by_2
        Port map (
                    clk     => i_clk_5x,
                    reset   => reset,
                    clk_out => i_clk_6x
        );
    slowed_clk_7: divide_by_2
        Port map (
                    clk     => i_clk_6x,
                    reset   => reset,
                    clk_out => i_clk_7x
        );
    slowed_clk_8: divide_by_2
        Port map (
                    clk     => i_clk_7x,
                    reset   => reset,
                    clk_out => i_clk_8x
        );

    clk_1x <= i_clk_1x;
    clk_2x <= i_clk_2x;
    clk_3x <= i_clk_3x;
    clk_4x <= i_clk_4x;
    clk_5x <= i_clk_5x;
    clk_6x <= i_clk_6x;
    clk_7x <= i_clk_7x;
    clk_8x <= i_clk_8x;

end Behavioral;