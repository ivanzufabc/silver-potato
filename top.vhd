library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0); -- KEY(1) = reset
        SW       : in  std_logic_vector(2 downto 0); -- SW(0)=nickel(5), SW(1)=dime(10), SW(2)=quarter(25)
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0)
    );
end top;

architecture behavioral of top is
    component VendMachine is
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
    end component VendMachine;

    signal vm_clock         : std_logic := '0';
    signal vm_reset         : std_logic;
    signal vm_nickel_in     : std_logic;
    signal vm_dime_in       : std_logic;
    signal vm_quarter_in    : std_logic;
    signal vm_nickel_out    : std_logic;
    signal vm_dime_out      : std_logic;
    signal vm_candy_out     : std_logic;
    signal acc              : unsigned(3 downto 0);

    signal button_prev      : std_logic := '0';
    signal button_edge      : std_logic;

    signal count            : integer range 0 to 50000000 := 0;
begin

    -- Divisor de clock para gerar 1Hz
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if count = 50000 - 1 then
                count <= 0;
                vm_clock <= not vm_clock;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    process(vm_clock, KEY(1))
    begin
        if KEY(1) = '0' then
            button_prev <= '0';
        elsif rising_edge(vm_clock) then
            button_prev <= KEY(0);
        end if;
    end process;

    vm_reset <= not KEY(1);
    button_edge <= (button_prev and (not KEY(0)));
    vm_nickel_in <= SW(0) and button_edge;
    vm_dime_in <= SW(1) and button_edge;
    vm_quarter_in <= SW(2) and button_edge;

    vm : component VendMachine
    port map (
        clock       => vm_clock,
        reset       => vm_reset,
        nickel_in   => vm_nickel_in,
        dime_in     => vm_dime_in,
        quarter_in  => vm_quarter_in,
        nickel_out  => vm_nickel_out,
        dime_out    => vm_dime_out,
        candy_out   => vm_candy_out,
        acc         => acc
    );

    -- Displays
    HEX5 <= "1111001" when vm_candy_out = '1' else "1000000"; -- 1 para candy, 0 para nada
    HEX4 <= "1111111"; -- apagado
    HEX3 <= "1111001" when vm_dime_out = '1' else
            "1000000";
    HEX2 <= "0010010" when vm_nickel_out = '1' else
            "1000000";
    HEX1 <= "0011001" when acc(3 downto 1) = 4 else
            "0110000" when acc(3 downto 1) = 3 else
            "0100100" when acc(3 downto 1) = 2 else
            "1111001" when acc(3 downto 1) = 1 else
            "1000000";
    HEX0 <= "0010010" when acc(0) = '1' else "1000000";
end behavioral;