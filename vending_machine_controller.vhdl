LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vending_machine_controller IS
    PORT
    (
        nickel_in   : IN STD_LOGIC;
        dime_in     : IN STD_LOGIC;
        quarter_in  : IN STD_LOGIC;
        clock       : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        nickel_out  : OUT STD_LOGIC := '0';
        dime_out    : OUT STD_LOGIC := '0';
        candy_out   : OUT STD_LOGIC := '0'
    );
END vending_machine_controller;

ARCHITECTURE behavioral OF vending_machine_controller IS

CONSTANT S_0     : UNSIGNED(9 downto 0) := "0000000001";
CONSTANT S_5     : UNSIGNED(9 downto 0) := "0000000010";
CONSTANT S_10    : UNSIGNED(9 downto 0) := "0000000100";
CONSTANT S_15    : UNSIGNED(9 downto 0) := "0000001000";
CONSTANT S_20    : UNSIGNED(9 downto 0) := "0000010000";
CONSTANT S_25    : UNSIGNED(9 downto 0) := "0000100000";
CONSTANT S_30    : UNSIGNED(9 downto 0) := "0001000000";
CONSTANT S_35    : UNSIGNED(9 downto 0) := "0010000000";
CONSTANT S_40    : UNSIGNED(9 downto 0) := "0100000000";
CONSTANT S_45    : UNSIGNED(9 downto 0) := "1000000000";

SIGNAL state    : UNSIGNED(9 downto 0) := S_0;
BEGIN
    fsm : PROCESS(clock, reset)
    BEGIN
        IF reset = '1' THEN
            state <= S_0;
        END IF;
        IF rising_edge(clock) THEN
            CASE state IS
            WHEN S_0|S_5|S_10|S_15|S_20 =>
                IF nickel_in = '1' THEN
                    state <= rotate_left(state, 1);
                ELSIF dime_in = '1' THEN
                    state <= rotate_left(state, 2);
                ELSIF quarter_in = '1' THEN
                    state <= rotate_left(state, 5);
                END IF;
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
            WHEN S_25 =>
                candy_out <= '1';
                state <= S_0;
            WHEN S_30 =>
                candy_out <= '1';
                nickel_out <= '1';
                state <= S_0;
            WHEN S_35 =>
                candy_out <= '1';
                dime_out <= '1';
                nickel_out <= '0';
                state <= S_0;
            WHEN S_40 =>
                nickel_out <= '1';
                state <= S_35;
            WHEN S_45 =>
                dime_out <= '1';
                state <= S_35;
            WHEN OTHERS =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                state <= S_0;
            END CASE;
        END IF;
    END PROCESS fsm;
END behavioral;