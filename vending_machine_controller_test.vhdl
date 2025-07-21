LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vending_machine_controller_test IS
END vending_machine_controller_test;

ARCHITECTURE test OF vending_machine_controller_test IS
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
            candy_out   : OUT STD_LOGIC
        );
    END COMPONENT vending_machine_controller;

    SIGNAL ni   : STD_LOGIC := '0';
    SIGNAL di   : STD_LOGIC := '0';
    SIGNAL qi   : STD_LOGIC := '0';
    SIGNAL clk  : STD_LOGIC := '0';
    SIGNAL rst  : STD_LOGIC := '0';
    SIGNAL no   : STD_LOGIC;
    SIGNAL do   : STD_LOGIC;
    SIGNAL co   : STD_LOGIC;

BEGIN
    vmc : COMPONENT vending_machine_controller
    PORT MAP
    (
        nickel_in   => ni,
        dime_in     => di,
        quarter_in  => qi,
        clock       => clk,
        reset       => rst,
        nickel_out  => no,
        dime_out    => do,
        candy_out   => co
    );

    init : PROCESS
    BEGIN
        di <= '1';
        WAIT FOR 600 ns;
        WAIT FOR 400 ns;

        WAIT FOR 400 ns;

        WAIT FOR 400 ns;

        WAIT FOR 400 ns;
        WAIT;
    END PROCESS init;

    always : PROCESS
    BEGIN
        FOR i in 0 to 10 LOOP
            WAIT FOR 200 ns;
            clk <= '1';
            WAIT FOR 200 ns;
            clk <= '0';
        END LOOP;
        WAIT;
    END PROCESS always;
END ARCHITECTURE test;