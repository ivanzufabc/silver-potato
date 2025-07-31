library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0); -- KEY(1) = reset
        LEDS     : out std_logic_vector(5 downto 0)
    );
end top;

architecture behavioral of top is
    component VendMachine is
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
    end component VendMachine;

    signal HEX0     :  std_logic_vector(6 downto 0);
    signal HEX1     :  std_logic_vector(6 downto 0);
    signal HEX2     :  std_logic_vector(6 downto 0);
    signal HEX3     :  std_logic_vector(6 downto 0);
    signal HEX4     :  std_logic_vector(6 downto 0);
    signal HEX5     :  std_logic_vector(6 downto 0);
    signal SW       :  std_logic_vector(2 downto 0) := "010"; -- SW(0)=5¢, SW(1)=10¢, SW(2)=25¢

    signal one : std_logic := '1';
    signal zero : std_logic := '0';

    signal vm_clock     : std_logic := '0';
    signal vm_reset     : std_logic;
    signal vm_button    : std_logic;
    signal vm_leds      : std_logic_vector(5 downto 0);
    signal acc          : unsigned(3 downto 0);

    signal count             : integer range 0 to 50000000 := 0;
begin

    -- Divisor de clock para gerar 1Hz
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if count = 50000000 - 1 then
                count <= 0;
                vm_clock <= not vm_clock;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    vm : component VendMachine
    port map (
        clock       => vm_clock,
        reset       => KEY(1),
        button      => KEY(0),
        nickel_in   => zero,
        dime_in     => one,
        quarter_in  => zero,
        nickel_out  => vm_leds(0),
        dime_out    => vm_leds(1),
        candy_out   => vm_leds(2),
        acc         => acc
    );
    LEDS <= not vm_leds;
    vm_leds(5 downto 3) <= "000";

    -- Displays
    HEX5 <= "1111001" when vm_leds(2) = '1' else "1000000"; -- 1 para candy, 0 para nada
    HEX4 <= "1111111"; -- apagado
    HEX3 <= "1000000" when vm_leds(0) = '1' else
            "1111001";
    HEX2 <= "0010010" when vm_leds(0) = '1' else
            "1000000";
    HEX1 <= "0011001" when acc(3 downto 1) = 4 else
            "0110000" when acc(3 downto 1) = 3 else
            "0100100" when acc(3 downto 1) = 2 else
            "1111001" when acc(3 downto 1) = 1 else
            "1000000";
    HEX0 <= "0010010" when acc(0) = '1' else "1000000";
end behavioral;