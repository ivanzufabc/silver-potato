library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VendMachine is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        nickel_in   : in  std_logic;
        dime_in     : in  std_logic;
        quarter_in  : in  std_logic;
        nickel_out  : out std_logic;
        dime_out    : out std_logic;
        candy_out   : out std_logic;
        acc         : out unsigned(3 downto 0)
    );
end VendMachine;

architecture behavioral of VendMachine is

    type t_state is (
        S_ACUMULANDO, S_DISPENSANDO_DOCE, S_DISPENSANDO_DOCE_E_NICKEL,
        S_DISPENSANDO_DOCE_E_DIME, S_DEVOLVENDO_NICKEL, S_DEVOLVENDO_DIME
    );
    signal present_state, next_state : t_state;

    signal s_valor_acumulado : unsigned(3 downto 0) := (others => '0');
    signal s_proximo_valor   : unsigned(3 downto 0);
    
    signal count             : integer range 0 to 50000000 := 0;
    signal s_done            : std_logic := '0';
    signal s_wait            : std_logic := '0';

begin
    
    acc <= s_valor_acumulado;

    -- Processo de clock e reset
    process(reset, clock)
    begin
        if reset = '1' then
            present_state     <= S_ACUMULANDO;
            s_valor_acumulado <= (others => '0');
        elsif rising_edge(clock) then
            present_state     <= next_state;
            s_valor_acumulado <= s_proximo_valor;
        end if;
    end process;

    -- FSM: lógica combinacional
    process (present_state, s_valor_acumulado, nickel_in, dime_in, quarter_in)
    begin

        case present_state is
            when S_ACUMULANDO =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '0';
                if s_done = '1' then
                    if to_integer(s_valor_acumulado) = 5 then
                        next_state      <= S_DISPENSANDO_DOCE;
                        s_proximo_valor <= (others => '0');
                    elsif to_integer(s_valor_acumulado) = 6 then
                        next_state      <= S_DISPENSANDO_DOCE_E_NICKEL;
                        s_proximo_valor <= (others => '0');
                    elsif to_integer(s_valor_acumulado) = 7 then
                        next_state      <= S_DISPENSANDO_DOCE_E_DIME;
                        s_proximo_valor <= (others => '0');
                    elsif to_integer(s_valor_acumulado) = 8 then
                        next_state      <= S_DEVOLVENDO_NICKEL;
                        s_proximo_valor <= to_unsigned(7, 4);
                    elsif to_integer(s_valor_acumulado) = 9 then
                        next_state      <= S_DEVOLVENDO_DIME;
                        s_proximo_valor <= to_unsigned(7, 4);
                    else
                        s_wait <= '0';
                        next_state <= S_ACUMULANDO;
                        if nickel_in = '1' then
                            s_proximo_valor <= s_valor_acumulado + 1;
                        elsif dime_in = '1' then
                            s_proximo_valor <= s_valor_acumulado + 2;
                        elsif quarter_in = '1' then
                            s_proximo_valor <= s_valor_acumulado + 5;
                        else
                            s_proximo_valor <= s_valor_acumulado;
                        end if;
                    end if;
                else
                    next_state <= present_state;
                    s_proximo_valor <= s_valor_acumulado;
                end if;

            when S_DISPENSANDO_DOCE =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '1';
                s_wait          <= '1';
                s_proximo_valor <= s_valor_acumulado;
                if s_done = '1' then
                    next_state  <= S_ACUMULANDO;
                else
                    next_state  <= present_state;
                end if;

            when S_DISPENSANDO_DOCE_E_NICKEL =>
                nickel_out      <= '1';
                dime_out        <= '0';
                candy_out       <= '1';
                s_wait          <= '1';
                s_proximo_valor <= s_valor_acumulado;
                if s_done = '1' then
                    next_state  <= S_ACUMULANDO;
                else
                    next_state  <= present_state;
                end if;

            when S_DISPENSANDO_DOCE_E_DIME =>
                nickel_out      <= '0';
                dime_out        <= '1';
                candy_out       <= '1';
                s_wait          <= '1';
                s_proximo_valor <= s_valor_acumulado;
                if s_done = '1' then
                    next_state  <= S_ACUMULANDO;
                else
                    next_state  <= present_state;
                end if;

            when S_DEVOLVENDO_NICKEL =>
                nickel_out      <= '1';
                dime_out        <= '0';
                candy_out       <= '0';
                s_wait          <= '1';
                s_proximo_valor <= s_valor_acumulado;
                if s_done = '1' then
                    next_state  <= S_ACUMULANDO;
                else
                    next_state  <= present_state;
                end if;

            when S_DEVOLVENDO_DIME =>
                nickel_out      <= '0';
                dime_out        <= '1';
                candy_out       <= '0';
                s_wait          <= '1';
                s_proximo_valor <= s_valor_acumulado;
                if s_done = '1' then
                    next_state  <= S_ACUMULANDO;
                else
                    next_state  <= present_state;
                end if;

            when others =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '0';
                s_wait          <= '0';
                s_proximo_valor <= (others => '0');
                next_state      <= S_ACUMULANDO;
        end case;
    end process;
    
    process(clock, s_wait)
    begin
        if rising_edge(clock) and s_wait = '1' then
            if count = 1000 - 1 then
                count <= 0;
                s_done <= '1';
            else
                count <= count + 1;
                s_done <= '0';
            end if;
        end if;
    end process;

end behavioral;