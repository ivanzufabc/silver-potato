library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0); -- KEY(1) = reset
        SW       : in  std_logic_vector(2 downto 0); -- SW(0)=5¢, SW(1)=10¢, SW(2)=25¢
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0)
    );
end vending_machine;

architecture behavioral of vending_machine is
    component vending_machine_controller is
    port
    (
        nickel_in   : IN  STD_LOGIC;
        dime_in     : IN  STD_LOGIC;
        quarter_in  : IN  STD_LOGIC;
        clock       : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        nickel_out  : OUT STD_LOGIC;
        dime_out    : OUT STD_LOGIC;
        candy_out   : OUT STD_LOGIC;
        state       : OUT STD_LOGIC_VECTOR(3 downto 0)
    );
    end component vending_machine_controller;

	type t_segments is array (-1 to 5) of STD_LOGIC_VECTOR(6 downto 0);

    signal vm_nickel_in     : std_logic;
    signal vm_dime_in       : std_logic;
    signal vm_quarter_in    : std_logic;
    signal vm_clock         : std_logic;
    signal vm_reset         : std_logic;
    signal vm_nickel_out    : std_logic;
    signal vm_dime_out      : std_logic;
    signal vm_candy_out     : std_logic;
    signal vm_state         : std_logic_vector(3 downto 0);

    signal button_prev      : std_logic := '0';
    signal button_edge      : std_logic;
    signal count            : integer range 0 to 50000000 := 0;

    signal display          : std_logic_vector(5 downto 1);
    constant segments       : t_segments := ("1111111", "1000000", "1111001", "0100100", "0110000", "0011001", "0010010");
    
    signal slow             : std_logic;
    signal clock_div        : std_logic_vector(25 downto 0) := (others => '0');
    signal clock_prev       : std_logic := '0';

begin

    slow <= vm_state(3) or (vm_state(2) and vm_state(0)) or (vm_state(2) and vm_state(1));

    -- Divisor de clock para gerar 1Hz
    process(CLOCK_50, KEY(1))
    begin
        if KEY(1) = '0' then
            clock_div(0) <= '0';
        elsif rising_edge(CLOCK_50) then
            clock_prev <= clock_div(25);
            if ((not clock_prev) and clock_div(25)) = '1' then
                vm_clock <= not vm_clock;
            elsif slow = '1' then
                clock_div(0) <= not clock_div(0);
            else
                vm_clock <= not vm_clock;
            end if;
        end if;
    end process;
    
    gen_div : for i in 0 to 24 generate
        process(clock_div(i), KEY(1))
        begin
            if KEY(1) = '0' then
                clock_div(i+1) <= '0';
            elsif rising_edge(clock_div(i)) then
                clock_div(i+1) <= not clock_div(i+1);
            end if;
        end process;
    end generate gen_div;

    process(vm_clock, KEY(1))
    begin
        if KEY(1) = '0' then
            button_prev <= '0';
        elsif rising_edge(vm_clock) then
            button_prev <= KEY(0);
        end if;
    end process;

    vm_reset        <= not KEY(1);
    button_edge     <= button_prev and (not KEY(0));
    vm_nickel_in    <= SW(0) and button_edge;
    vm_dime_in      <= SW(1) and button_edge;
    vm_quarter_in   <= SW(2) and button_edge;

    vm : component vending_machine_controller
    port map 
    (
        nickel_in   => vm_nickel_in,
        dime_in     => vm_dime_in,
        quarter_in  => vm_quarter_in,
        clock       => vm_clock,
        reset       => vm_reset,
        nickel_out  => vm_nickel_out,
        dime_out    => vm_dime_out,
        candy_out   => vm_candy_out,
        state       => vm_state
    );

    -- Displays
    HEX5 <= segments(1) when vm_candy_out = '1' else
            segments(0);

    HEX4 <= segments(-1);

    HEX3 <= segments(1) when vm_dime_out = '1' else
            segments(0);

    HEX2 <= segments(5) when vm_nickel_out = '1' else
            segments(0);
    
    display(4) <= vm_state(3);
    display(3) <=vm_state(2) and vm_state(1);
    display(2) <= vm_state(2) and (not vm_state(1));
    display(1) <= (not vm_state(2)) and vm_state(1);
    HEX1 <= segments(4) when display(4) = '1' else
            segments(3) when display(3) = '1' else
            segments(2) when display(2) = '1' else
            segments(1) when display(1) = '1' else
            segments(0);

    display(5) <= vm_state(0);
    HEX0 <= segments(5) when display(5) = '1' else
            segments(0);

end behavioral;