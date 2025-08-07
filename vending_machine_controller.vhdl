LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vending_machine_controller IS
    PORT
    (
        nickel_in   : IN  STD_LOGIC;
        dime_in     : IN  STD_LOGIC;
        quarter_in  : IN  STD_LOGIC;
        clock       : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        nickel_out  : OUT STD_LOGIC := '0';
        dime_out    : OUT STD_LOGIC := '0';
        candy_out   : OUT STD_LOGIC := '0';
        state       : OUT STD_LOGIC_VECTOR(3 downto 0)
    );
END vending_machine_controller;

ARCHITECTURE behavioral OF vending_machine_controller IS

CONSTANT S_0     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
CONSTANT S_5     : STD_LOGIC_VECTOR(3 downto 0) := "0001";
CONSTANT S_10    : STD_LOGIC_VECTOR(3 downto 0) := "0010";
CONSTANT S_15    : STD_LOGIC_VECTOR(3 downto 0) := "0011";
CONSTANT S_20    : STD_LOGIC_VECTOR(3 downto 0) := "0100";
CONSTANT S_25    : STD_LOGIC_VECTOR(3 downto 0) := "0101";
CONSTANT S_30    : STD_LOGIC_VECTOR(3 downto 0) := "0110";
CONSTANT S_35    : STD_LOGIC_VECTOR(3 downto 0) := "0111";
CONSTANT S_40    : STD_LOGIC_VECTOR(3 downto 0) := "1000";
CONSTANT S_45    : STD_LOGIC_VECTOR(3 downto 0) := "1001";

SIGNAL current_state    : STD_LOGIC_VECTOR(3 downto 0) := S_0;
SIGNAL next_state       : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

    state <= current_state;

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
                
            WHEN S_5 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF nickel_in = '1' THEN
                    next_state <= S_10;
                ELSIF dime_in = '1' THEN
                    next_state <= S_15;
                ELSIF quarter_in = '1' THEN
                    next_state <= S_30;
                ELSE
                    next_state <= S_5;
                END IF;
                
            WHEN S_10 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF nickel_in = '1' THEN
                    next_state <= S_15;
                ELSIF dime_in = '1' THEN
                    next_state <= S_20;
                ELSIF quarter_in = '1' THEN
                    next_state <= S_35;
                ELSE
                    next_state <= S_10;
                END IF;
                
            WHEN S_15 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF nickel_in = '1' THEN
                    next_state <= S_20;
                ELSIF dime_in = '1' THEN
                    next_state <= S_25;
                ELSIF quarter_in = '1' THEN
                    next_state <= S_40;
                ELSE
                    next_state <= S_15;
                END IF;
                
            WHEN S_20 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF nickel_in = '1' THEN
                    next_state <= S_25;
                ELSIF dime_in = '1' THEN
                    next_state <= S_30;
                ELSIF quarter_in = '1' THEN
                    next_state <= S_45;
                ELSE
                    next_state <= S_20;
                END IF;
                
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
        
            WHEN others =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF nickel_in = '1' THEN
                    next_state <= S_5;
                ELSIF dime_in = '1' THEN
                    next_state <= S_10;
                ELSIF quarter_in = '1' THEN
                    next_state <= S_25;
                ELSE
                    next_state <= S_0;
                END IF;
                
        END CASE;
    END PROCESS fsm;
END behavioral;