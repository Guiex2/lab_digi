library ieee;
use ieee.numeric_bit.all;

--W operations
entity W_operation is
    port (
        clk, en : in bit;
        w_2, w_7, w_15 w_16: in bit_vector(31 downto 0);
        w_t : out bit_vector(31 downto 0 )
    );
end W_operation;

architecture Behave of W_operation is
    
    component sigma1 is
        port(
            x: in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end sigma1;

    component sigma0 is
        port(
            x: in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end sigma0;

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
        
        w_t <= bit_vector(unsigned(sigma1_out) + w_7 + sigma0_out + w_16) ;
end Behave ; -- Behave

----------------------------------------------------

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


----------------------------------------------------

entity multisteps is
    port (
        clk, rst: in bit;
        msgi : in bit_vector (511 downto 0);
        haso : out bit_vector (255 downto 0);
        done : bit
    );

architecture Behave of multisteps is
    ---------------------------------------------

    ------- component decalaration -------
    component generic_register_bank is
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
            w_2, w_7, w_15 w_16: in bit_vector(31 downto 0);
            w_t : out bit_vector(31 downto 0 )
        );
    end W_operation;

    ---------------------------------------------

    signal W_in, W_out : bit_vector(32 downto 0);
    signal W_id : integer;
    signal W_write_en : bit;

    signal ai, bi, ci, ei, fi, gi, hi : bit_vector (31 downto 0);
    signal ao, bo, co, eo, fo, go, ho : bit_vector (31 downto 0);
    signal kpw : in bit_vector (31 downto 0);
    
    -- state machine states:
    -- from 0 to 15 fills 0-15 W addrs with msgi
    -- from 16 to 63 fills 16- 63 W addrs with corresponding sigma operations
    --- substates 0 to 3 reads W from register bank to memory 
    --- substates 4 executes W_operation


    signal state_machine : unsigned (5 downto 0); 
    signal sub_state_machine : unsigned (1 downto 0); 




    begin
        ------- component instantiation -------

        W_comp : generic_register_bank 
        port map(
            clk => clk, rst => rst, 
            D => W_in, reg_addr => W_id, Q => W_out,
        );


        stepper : stepfun 
        port map(
            ai, bi, ci, ei, fi, gi, hi,
            kpw,
            ao, bo, co, eo, fo, go, ho
        );
    ---------------------------------------------
        process(clk,rst)
        begin
            if rst = '1' then
                -- reset stuff
            else if (clk'event) and (clk = '1') then
                -- first state machine state process
                if state_machine >=0 and state_machine<=15 then 
                    W_in <= msgi( (state_machine+1)*32 downto state_machine*32 );
                    W_id <= state_machine;
                    W_write_en <= '1';

                -- second state machine state process
                else if state_machine >=16 and state_machine<=63 then 
                    W_in <= msgi( (state_machine+1)*32 downto state_machine*32 );
                    W_id <= state_machine;
                    W_write_en <= '1';
            end if;
        end process;
end Behave ; -- Behave