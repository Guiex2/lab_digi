-- Register Bank Entity
entity generic_register_bank is
    generic(bank_size : natural := 64;
            word_size : natural := 32;
            clk_level : bit :=0
        );
    Port (
        clk, rst  : in  bit;
        write_en  : in  bit;       
        D   : in  bit_vector(word_size-1 downto 0);
        reg_addr  : in  integer range bank_size downto 0;          
        Q  : out bit_vector(word_size-1 downto 0) 
    );
end generic_register_bank;

-- Register Bank Architecture
architecture Behavioral of generic_register_bank is
    type Register_Array is array (bank_size-1 to 0) of bit_vector(word_size-1 downto 0);
    signal registers : Register_Array;
begin
    process(clk, reset)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif (clk'event) and (clk = clk_level) then
            if write_en = '1' then
                registers(reg_addr) <= data_in; 
            end if;
            data_out <= registers(reg_addr);
        end if;
    end process;
end Behavioral;
