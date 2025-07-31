library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VendMachine is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        button      : in  std_logic;
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
    signal s_troco           : unsigned(3 downto 0);

    signal tmp               : std_logic := '0';

    -- Função de conversão para display 7 segmentos
    function to7seg(input: integer range 0 to 9) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case input is
            when 0 => seg := "1000000"; when 1 => seg := "1111001";
            when 2 => seg := "0100100"; when 3 => seg := "0110000";
            when 4 => seg := "0011001"; when 5 => seg := "0010010";
            when 6 => seg := "0000010"; when 7 => seg := "1111000";
            when 8 => seg := "0000000"; when 9 => seg := "0010000";
            when others => seg := "1111111";
        end case;
        return seg;
    end function;

begin
    
    acc <= s_valor_acumulado;

    -- Processo de clock e reset
    process(reset, clock)
    begin
        if reset = '1' then
            present_state     <= S_ACUMULANDO;
            s_valor_acumulado <= (others => '0');
            tmp <= '0';
        elsif rising_edge(clock) then
            present_state     <= next_state;
            s_valor_acumulado <= s_proximo_valor;
            tmp <= button;
        end if;
    end process;

    -- FSM: lógica combinacional
    process (present_state, s_valor_acumulado, nickel_in, dime_in, quarter_in, button, tmp)
    begin

        case present_state is
            when S_ACUMULANDO =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '0';
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
                elsif ((not tmp) and button) = '1' then
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
                else
                    next_state      <= S_ACUMULANDO;
                    s_proximo_valor <= s_valor_acumulado;
                end if;

            when S_DISPENSANDO_DOCE =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '1';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= S_ACUMULANDO;

            when S_DISPENSANDO_DOCE_E_NICKEL =>
                nickel_out      <= '1';
                dime_out        <= '0';
                candy_out       <= '1';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= S_ACUMULANDO;

            when S_DISPENSANDO_DOCE_E_DIME =>
                nickel_out      <= '0';
                dime_out        <= '1';
                candy_out       <= '1';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= S_ACUMULANDO;

            when S_DEVOLVENDO_NICKEL =>
                nickel_out      <= '1';
                dime_out        <= '0';
                candy_out       <= '0';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= S_ACUMULANDO;

            when S_DEVOLVENDO_DIME =>
                nickel_out      <= '0';
                dime_out        <= '1';
                candy_out       <= '0';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= S_ACUMULANDO;

            when others =>
                nickel_out      <= '0';
                dime_out        <= '0';
                candy_out       <= '0';
                s_proximo_valor <= s_valor_acumulado;
                next_state      <= present_state;
        end case;
    end process;

    -- Lógica do Display de Troco
--    s_troco <= to_unsigned(5, 7)  when s_nickel_out = '1' else
--               to_unsigned(10, 7) when s_dime_out   = '1' else
--               (others => '0');

end behavioral;