-------------------------------------------------------------------------------
-- Author: Guilherme Fortunato Miranda
-- Module Name: main_functions_exp2
-- Description:
-- VHDL module to convert from hex (4b) to 7-segment
-------------------------------------------------------------------------------


entity ch is
    port(
        x,y,z: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end ch;

architecture comportamental of ch is
    begin
        q <= (x and y) xor ((not x) and z);
end comportamental;

-------------------------------------------------------------------------------
entity maj is
    port(
        x,y,z: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end maj;

architecture comportamental of maj is
    begin
        q <= (x and y) xor (x and z) xor (y and z);
end comportamental;

-------------------------------------------------------------------------------
entity sum0 is
    port(
        x: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end sum0;

architecture comportamental of sum0 is
    begin
        q <= (x ror 2) xor (x ror 13) xor (x ror 22);
end comportamental;

-------------------------------------------------------------------------------
entity sum1 is
    port(
        x: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end sum1;

architecture comportamental of sum1 is
    begin
        q <= (x ror 6) xor (x ror 11) xor (x ror 25);
end comportamental;

-------------------------------------------------------------------------------
entity sigma0 is
    port(
        x: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end sigma0;

architecture comportamental of sigma0 is
    begin
        q <= (x ror 7) xor (x ror 18) xor (x srl 3);
end comportamental;

-------------------------------------------------------------------------------
entity sigma1 is
    port(
        x: in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end sigma1;

architecture comportamental of sigma1 is
    begin
        q <= (x ror 17) xor (x ror 19) xor (x srl 10);
end comportamental;