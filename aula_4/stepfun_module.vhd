-------------------------------------------------------------------------------
-- Author: Guilherme Fortunato Miranda
-- Module Name: main_functions_exp2
-- Description:
-- VHDL module to convert from hex (4b) to 7-segment
-------------------------------------------------------------------------------

ENTITY somador_1 IS
    PORT (
        a, b, carry_in : IN bit;
        enable : IN BIT;
        c : OUT bit;
        overflow : OUT BIT
    );
END somador_1;

ARCHITECTURE Behave OF somador_1 IS
BEGIN
    c <= (a xor b) xor carry_in WHEN enable = '1' ELSE
        '0';
    overflow <= (a and b) or (b and carry_in) or (a and carry_in) when enable = '1' ELSE
        '0';
END Behave;
-------------------------------------------------------------------------------
ENTITY somador_4 IS
    PORT (
        a, b : IN bit_vector(3 downto 0);
        carry_in, enable : IN BIT;
        c : OUT bit_vector(3 downto 0);
        overflow : OUT BIT
    );
END somador_4;

ARCHITECTURE Behave OF somador_4 IS
        
    component somador_1 IS
    PORT (
        a, b, carry_in : IN bit;
        enable : IN BIT;
        c : OUT bit;
        overflow : OUT BIT
    );
    END component somador_1;

    signal overflow1, overflow2, overflow3, overflow4 : bit;
        
BEGIN
    sum_port1 : somador_1 PORT MAP(a(0), b(0), carry_in,  '1',  c(0), overflow1);
    sum_port2 : somador_1 PORT MAP(a(1), b(1), overflow1, '1',  c(1), overflow2);
    sum_port3 : somador_1 PORT MAP(a(2), b(2), overflow2, '1',  c(2), overflow3);
    sum_port4 : somador_1 PORT MAP(a(3), b(3), overflow3, '1',  c(3), overflow);

END Behave;


-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ENTITY somador_32 IS
    PORT (
        a, b : IN bit_vector(31 downto 0);
        enable : IN BIT;
        c : OUT bit_vector(31 downto 0);
        overflow : OUT BIT
    );
END somador_32;

ARCHITECTURE Behave OF somador_32 IS
        
    component somador_4 IS
        PORT (
            a, b : IN bit_vector(3 downto 0);
            carry_in, enable : IN BIT;
            c : OUT bit_vector(3 downto 0);
            overflow : OUT BIT
        );
    END component somador_4;

    signal overflow1, overflow2, overflow3, overflow4 : bit;
    signal overflow5, overflow6, overflow7, overflow8 : bit;
    
        
BEGIN
    sum_port1 : somador_4 PORT MAP(a(3 downto 0),   b(3 downto 0),   '0',        '1',  c(3 downto 0),   overflow1);
    sum_port2 : somador_4 PORT MAP(a(7 downto 4),   b(7 downto 4),   overflow1,  '1',  c(7 downto 4),   overflow2);
    sum_port3 : somador_4 PORT MAP(a(11 downto 8),  b(11 downto 8),  overflow2,  '1',  c(11 downto 8),  overflow3);
    sum_port4 : somador_4 PORT MAP(a(15 downto 12), b(15 downto 12), overflow3,  '1',  c(15 downto 12), overflow4);
    sum_port5 : somador_4 PORT MAP(a(19 downto 16), b(19 downto 16), overflow4,  '1',  c(19 downto 16), overflow5);
    sum_port6 : somador_4 PORT MAP(a(23 downto 20), b(23 downto 20), overflow5,  '1',  c(23 downto 20), overflow6);
    sum_port7 : somador_4 PORT MAP(a(27 downto 24), b(27 downto 24), overflow6,  '1',  c(27 downto 24), overflow7);
    sum_port8 : somador_4 PORT MAP(a(31 downto 28), b(31 downto 28), overflow7,  '1',  c(31 downto 28), overflow);


END Behave;


-------------------------------------------------------------------------------

ENTITY stepfun IS
    PORT (
        ai, bi, ci, di, ei, fi, gi, hi : IN bit_vector(31 DOWNTO 0);
        kpw : IN bit_vector(31 DOWNTO 0);
        ao, bo, co, do, eo, fo, go, ho : OUT bit_vector(31 DOWNTO 0)
    );
END stepfun;

ARCHITECTURE Behave OF stepfun IS
    COMPONENT somador_32 IS
        PORT (
            a, b : IN bit_vector(31 DOWNTO 0);
            enable : IN BIT;
            c : OUT bit_vector(31 DOWNTO 0);
            overflow : OUT BIT
        );
    END COMPONENT;

    COMPONENT ch IS
        PORT (
            x, y, z : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT maj IS
        PORT (
            x, y, z : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sum0 IS
        PORT (
            x : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sum1 IS
        PORT (
            x : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL sum1_out_adder, sum1_output, sum2, sum3, sum4, sum5, sum6 : bit_vector(31 DOWNTO 0);
    SIGNAL overflow1, overflow2, overflow3, overflow4, overflow5, overflow6 : BIT;
    SIGNAL ch_out, sum1_out, maj_out, sum0_out : bit_vector(31 DOWNTO 0);

BEGIN
    sum1_port : somador_32 PORT MAP(hi, kpw, '1', sum1_out_adder, overflow1);
    sum2_port : somador_32 PORT MAP(ch_out, sum1_out_adder, '1', sum2, overflow2);
    sum3_port : somador_32 PORT MAP(sum1_out, sum2, '1', sum3, overflow3);
    sum4_port : somador_32 PORT MAP(di, sum3, '1', sum4, overflow4);
    sum5_port : somador_32 PORT MAP(maj_out, sum3, '1', sum5, overflow5);
    sum6_port : somador_32 PORT MAP(sum0_out, sum5, '1', sum6, overflow6);

    ch_port : ch PORT MAP(ei, fi, gi, ch_out);
    sum1_func_port : sum1 PORT MAP(ei, sum1_out);
    maj_port : maj PORT MAP(ai, bi, ci, maj_out);
    sum0_port : sum0 PORT MAP(ai, sum0_out);

    ao <= sum6;

    bo <= ai;
    co <= bi;
    do <= ci;
    eo <= sum4;
    fo <= ei;
    go <= fi;
    ho <= gi;

END ARCHITECTURE;
