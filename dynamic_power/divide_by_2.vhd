library IEEE;

entity divide_by_2 is
        Port (
                clk    : in  STD_LOGIC;
                reset  : in  STD_LOGIC;
                clk_out: out STD_LOGIC
        );
end entity divide_by_2;

architecture Behavioral of divide_by_2 is
    signal i_clk_out: out STD_LOGIC := '0';
begin

    clk_divide_by_2 : process(clk, reset)
    begin
        if reset='0' then
            i_clk_out <= '0';
        elsif rising_edge(clk) then
            i_clk_out <= not i_clk_out;
        end if;
    end process;
    clk_out <= i_clk_out;
end Behavioral;