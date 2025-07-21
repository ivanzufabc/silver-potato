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
        candy_out   : OUT STD_LOGIC := '0';
        state_out   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END vending_machine_controller;

ARCHITECTURE behavioral OF vending_machine_controller IS

CONSTANT S_0     : STD_LOGIC_VECTOR(9 downto 0) := "0000000001";
CONSTANT S_5     : STD_LOGIC_VECTOR(9 downto 0) := "0000000010";
CONSTANT S_10    : STD_LOGIC_VECTOR(9 downto 0) := "0000000100";
CONSTANT S_15    : STD_LOGIC_VECTOR(9 downto 0) := "0000001000";
CONSTANT S_20    : STD_LOGIC_VECTOR(9 downto 0) := "0000010000";
CONSTANT S_25    : STD_LOGIC_VECTOR(9 downto 0) := "0000100000";
CONSTANT S_30    : STD_LOGIC_VECTOR(9 downto 0) := "0001000000";
CONSTANT S_35    : STD_LOGIC_VECTOR(9 downto 0) := "0010000000";
CONSTANT S_40    : STD_LOGIC_VECTOR(9 downto 0) := "0100000000";
CONSTANT S_45    : STD_LOGIC_VECTOR(9 downto 0) := "1000000000";

SIGNAL current_state, next_state : STD_LOGIC_VECTOR(9 downto 0) := S_0;
BEGIN
    state_out <= current_state;
    fsm_update : PROCESS(clock, reset)
    BEGIN
        IF reset = '0' THEN
            current_state <= S_0;
        ELSIF rising_edge(clock) THEN
            current_state <= next_state;
        END IF;
	END PROCESS fsm_update;
	
    fsm : PROCESS(current_state, nickel_in, dime_in, quarter_in)
    BEGIN
        CASE current_state IS
        WHEN S_0 =>
            IF nickel_in = '1' THEN
                next_state <= S_5;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= S_10;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= S_25;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_0;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_5 =>
            IF nickel_in = '1' THEN
                next_state <= S_10;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= S_15;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= S_30;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_5;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_10 =>
            IF nickel_in = '1' THEN
                next_state <= S_15;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= S_20;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= S_35;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_10;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_15 =>
            IF nickel_in = '1' THEN
                next_state <= S_20;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= S_25;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= S_40;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_15;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_20 =>
            IF nickel_in = '1' THEN
                next_state <= S_25;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 1));
            ELSIF dime_in = '1' THEN
                next_state <= S_30;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 2));
            ELSIF quarter_in = '1' THEN
                next_state <= S_45;--STD_LOGIC_VECTOR(rotate_left(UNSIGNED(current_state), 5));
            ELSE
                next_state <= S_20;
            END IF;
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        WHEN S_25 =>
            candy_out <= '1';
            next_state <= S_0;
        WHEN S_30 =>
            candy_out <= '1';
            nickel_out <= '1';
            next_state <= S_0;
        WHEN S_35 =>
            candy_out <= '1';
            dime_out <= '1';
            nickel_out <= '0';
            next_state <= S_0;
        WHEN S_40 =>
            nickel_out <= '1';
            next_state <= S_35;
        WHEN S_45 =>
            dime_out <= '1';
            next_state <= S_35;
        WHEN OTHERS =>
            candy_out <= '0';
            nickel_out <= '0';
            dime_out <= '0';
        END CASE;
    END PROCESS fsm;
END behavioral;