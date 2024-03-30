library ieee;
use ieee.numeric_bit.all;

--W operations
entity W_operation is
    port (
        clk, en : in bit;
        w_2, w_7, w_15, w_16: in bit_vector(31 downto 0);
        w_t : out bit_vector(31 downto 0 )
    );
end W_operation;

architecture Behave of W_operation is
    
    component sigma1 is
        port(
            x: in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    component sigma0 is
        port(
            x: in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    signal sigma1_out, sigma0_out : bit_vector(31 downto 0);

    begin

            
    inst_sig1 : sigma1
        port map(
                x => w_2, q => sigma1_out
        );

    inst_sig0 : sigma0
        port map(
                x => w_15, q => sigma0_out
        );
        
        w_t <= bit_vector(unsigned(sigma1_out) + unsigned(w_7) + unsigned(sigma0_out) + unsigned(w_16)) ;
end Behave ; -- Behave

----------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
-- Register Bank Entity
entity generic_register_bank is
    generic(bank_size : natural := 64;
            word_size : natural := 32;
            clk_level : bit := '0'
        );
    Port (
        clk, rst  : in  bit;
        write_en  : in  bit;       
        D   : in  bit_vector(word_size-1 downto 0);
        reg_addr  : in  unsigned(5 downto 0);          
        Q  : out bit_vector(word_size-1 downto 0) 
    );


end generic_register_bank;

-- Register Bank Architecture
architecture Behavioral of generic_register_bank is
    type Register_Array is array (bank_size-1 downto 0) of bit_vector(word_size-1 downto 0);
    signal registers : Register_Array;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif (clk'event) and (clk = clk_level) then
            if write_en = '1' then
                registers(to_integer(reg_addr)) <= D; 
            end if;
            Q <= registers(to_integer(reg_addr));
        end if;
    end process;
end Behavioral;


----------------------------------------------------
library ieee;
use ieee.numeric_bit.all;


entity multisteps is
    port (
        clk, rst: in bit;
        msgi : in bit_vector (511 downto 0);
        haso : out bit_vector (255 downto 0);
        done : bit
    );
end entity;
architecture Behave of multisteps is
    ---------------------------------------------

    ------- component decalaration -------
    component generic_register_bank is
        generic(bank_size : natural := 64;
                word_size : natural := 32;
                clk_level : bit := '0'
            );
        Port (
            clk, rst  : in  bit;
            write_en  : in  bit;       
            D   : in  bit_vector(word_size-1 downto 0);
            reg_addr  : in  unsigned (5 downto 0);          
            Q  : out bit_vector(word_size-1 downto 0) 
        );
    end component;
    
    ---------------------------------------------
    component stepfun IS
    PORT (
        ai, bi, ci, di, ei, fi, gi, hi : IN bit_vector(31 DOWNTO 0);
        kpw : IN bit_vector(31 DOWNTO 0);
        ao, bo, co, do, eo, fo, go, ho : OUT bit_vector(31 DOWNTO 0)
    );
    END component;
    ---------------------------------------------

    component W_operation is
        port (
            clk, en : in bit;
            w_2, w_7, w_15, w_16: in bit_vector(31 downto 0);
            w_t : out bit_vector(31 downto 0 )
        );
    end component;
    
    signal operation_buffer : bit_vector(31 downto 0);
    ---------------------------------------------

    signal W_in, W_out : bit_vector(31 downto 0);
    signal W_id : unsigned  (5 downto 0);
    signal W_write_en : bit;

    ---------------------------------------------
    signal w_opeartor_en : bit;
    signal w_2, w_7, w_15, w_16, w_t : bit_vector(31 downto 0);

    ---------------------------------------------
    signal ai, bi, ci, ei, fi, gi, hi : bit_vector (31 downto 0);
    signal ao, bo, co, eo, fo, go, ho : bit_vector (31 downto 0);
    signal kpw :  bit_vector (31 downto 0);
    
    -- state machine states:
    -- from 0 to 15 fills 0-15 W addrs with msgi
    -- from 16 to 63 fills 16- 63 W addrs with corresponding sigma operations
    --- substates 0 to 3 reads W from register bank to memory 
    --- substate 4 executes W_operation
    --- substate 5 saves W_operation result into corresponding register 

    signal state_machine : unsigned (5 downto 0); 
    signal sub_state_machine : unsigned (2 downto 0); 
    signal counting_substate : bit;

    begin
        ------- component instantiation -------

        W_comp : generic_register_bank 
        port map(
            clk => clk, rst => rst, write_en => W_write_en,
            D => W_in, reg_addr => W_id, Q => W_out
        );


        stepper : stepfun 
        port map(
            ai, bi, ci, ei, fi, gi, hi,
            kpw,
            ao, bo, co, eo, fo, go, ho
        );
        
        
        w_operator: W_operation
        port map(
            clk => not(clk), en=> w_opeartor_en,
            w_2 => w_2, w_7 => w_7, w_15 => w_15, w_16 => w_16,
            w_t => w_t
        );
    ---------------------------------------------
        process(clk,rst)
        begin
            if rst = '1' then
                -- reset stuff
                state_machine <= to_unsigned(0,state_machine'length);
                sub_state_machine <= to_unsigned(0,sub_state_machine'length);

            elsif (clk'event) and (clk = '1') then
                W_write_en <= '0';
                -- first state machine state process
            
                if state_machine >=0 and state_machine<=15 then 
                    W_in <= msgi( to_integer( (state_machine+1)) *32 -1 downto to_integer(state_machine)*32 );
                    W_id <= state_machine;
                    W_write_en <= '1';

                -- second state machine state process
                elsif state_machine >=16 and state_machine<=63 then 
                    counting_substate <= '1';
                    case to_integer(sub_state_machine) is
                        when 0 =>
                            W_id <= state_machine-to_unsigned(2, state_machine'length);
                            w_2 <= w_out;
                        when 1 =>
                            W_id <= state_machine-7;
                            w_7 <= w_out;
                        when 2 =>
                            W_id <= state_machine-15;
                            w_15 <= w_out;
                        when 3 =>
                            W_id <= state_machine-16;
                            w_16 <= w_out;
                        when 4 =>
                            w_opeartor_en <='1';
                            operation_buffer <=w_t;
                        when 5 =>
                            W_id <= state_machine;
                            w_in <= operation_buffer;
                            W_write_en <= '1';
                            counting_substate <= '0';
                        when others =>
                            null;
                    end case;
                    if counting_substate = '1' then
                        sub_state_machine <= sub_state_machine + 1;
                    else
                        sub_state_machine <= to_unsigned(0,sub_state_machine'length);
                    end if;
                end if;
                if ((state_machine < 64) and (not (counting_substate)) = '1') then
                    state_machine <= state_machine + 1;
                end if;
            end if;
        end process;
end Behave ; -- Behave