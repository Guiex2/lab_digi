entity generic_register is
    generic(register_size : natural := 32;
            clk_level : bit :=0
    );
    port(
        clk, rst : in bit;
        D : in bit_vector(register_size downto 0);
        Q : out bit_vector(register_size downto 0)
    );
end generic_register;

architecture Behave of generic_register is
    process(reset,CLK)
    begin
    if reset= '1' then
        Q <= (others => 0);

    else if (clk'event) and (clk = clk_level) then
        Q <= D;
    end if;
    end process;
end Behave ; -- Behave