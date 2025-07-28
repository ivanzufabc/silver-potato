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

TYPE STATE is (S_0, S_5, S_10, S_15, S_20, S_25, S_30, S_35, S_40, S_45);

SIGNAL current_state, next_state : STATE := S_0;
BEGIN
    fsm_update : PROCESS(clock, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= S_0;
        ELSIF rising_edge(clock) THEN
            current_state <= next_state;
        END IF;
	END PROCESS fsm_update;
	
    fsm : PROCESS(current_state, nickel_in, dime_in, quarter_in)
    BEGIN
        CASE current_state IS
        WHEN S_0|S_5|S_10|S_15|S_20 =>
            IF nickel_in = '1' THEN
                next_state <= STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_0;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_25 =>
            candy_out <= '1';
            nickel_out <= '0';
            dime_out <= '0';
            next_state <= S_0;
        WHEN S_30 =>
            candy_out <= '1';
            nickel_out <= '1';
            dime_out <= '0';
            next_state <= S_0;
        WHEN S_35 =>
            candy_out <= '1';
            nickel_out <= '0';
            dime_out <= '1';
            next_state <= S_0;
        WHEN S_40 =>
            candy_out <= '0';
            nickel_out <= '1';
            dime_out <= '0';
            next_state <= S_35;
        WHEN S_45 =>
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '1';
            next_state <= S_35;
        WHEN OTHERS =>
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
            next_state <= S_0;
        END CASE;
    END PROCESS fsm;
END behavioral;