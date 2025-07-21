LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vending_machine IS
    PORT
    (
        KEY         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW          : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        HEX0        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        LEDR        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END vending_machine;

ARCHITECTURE behavioral OF vending_machine IS
    COMPONENT vending_machine_controller IS
        PORT
        (
            nickel_in   : IN STD_LOGIC;
            dime_in     : IN STD_LOGIC;
            quarter_in  : IN STD_LOGIC;
            clock       : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            nickel_out  : OUT STD_LOGIC;
            dime_out    : OUT STD_LOGIC;
            candy_out   : OUT STD_LOGIC;
            state_out   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL zero : STD_LOGIC := '0';
    SIGNAL zero2 : STD_LOGIC := '0';
BEGIN
    vmc : vending_machine_controller PORT MAP 
    (
        nickel_in   => SW(0),
        dime_in     => SW(1),
        quarter_in  => SW(2),
        clock       => KEY(0),
        reset       => KEY(1),
        nickel_out  => zero,
        dime_out    => zero,
        candy_out   => zero,
        state_out   => LEDR
    );
END behavioral;