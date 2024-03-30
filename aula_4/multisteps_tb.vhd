library ieee;
use ieee.numeric_bit.all;

entity multisteps_tb is
end entity multisteps_tb;

architecture Behavioral of multisteps_tb is
    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, rst : bit;
    signal msgi : bit_vector(511 downto 0);
    signal haso : bit_vector(255 downto 0);
    signal done: bit;

    component multisteps is
    port (
        clk, rst: in bit;
        msgi : in bit_vector (511 downto 0);
        haso : out bit_vector (255 downto 0);
        done : bit
        );
    end multisteps;

begin
    -- Instantiate multisteps
    pig_step: multisteps
    port map (
        clk, rst,
        msgi,haso,
        done
    );

    clk <= not (clk) after CLK_PERIOD/2;
        
    -- Stimulus process
    stimulus: process
    begin
        msgi <= bit_vector(to_unsigned(0,msgi'length));
        rst <= '1';        
        wait for 10 ns;
        rst <= '0';    
        wait for 10 ns;
        wait;
    end process stimulus;
    
    -- Clock process
    clk_process: process
    begin
    	wait for 60 ns;
        wait;
    end process clk_process;
end Behavioral;
