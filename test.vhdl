library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VendingMachine2 is
   port(
		MAX10_CLK1_50: in std_logic;
      KEY: in std_logic_vector(1 downto 0);
      HEX0: out std_logic_vector(6 downto 0);
      HEX1: out std_logic_vector(6 downto 0);
      HEX2: out std_logic_vector(6 downto 0);
      HEX3: out std_logic_vector(6 downto 0);
      HEX4: out std_logic_vector(6 downto 0);
      HEX5: out std_logic_vector(6 downto 0);
      LEDR: out std_logic_vector(9 downto 0)
   );
end VendingMachine2;

architecture arch of VendingMachine2 is
   type coin is (nickel, dime, quarter);
   signal selected_coin: coin := nickel;
   type state is (
      st0, st5, st10, st15, st20, st25, st30, st35, st40, st45
   );
   signal present_state, next_state: state := st0;
   signal dime_in, nickel_in, quarter_in: std_logic := '0';
   signal dime_out, nickel_out, candy_out: std_logic := '0';
   signal coin_taken: std_logic := '0';
	signal clk: std_logic := '0';
	signal counter: integer := 0;
begin
	clock: process (MAX10_CLK1_50)
	begin
		if rising_edge(MAX10_CLK1_50) then
			if counter < 25_000_000 then
				counter <= counter + 1;
				clk <= '0'; 
			elsif counter < 50_000_000 then 
				counter <= counter + 1;
				clk <= '1';
			else
				counter <= 0;
				clk <= '0';
			end if;
		end if;
	end process;

	-- Processo sequencial para atualizar o estado
   process (clk)
   begin
      if (clk = '1') then
         present_state <= st35;
      end if;
   end process;
			
   -- Define qual moeda está sendo inserida baseado no pulso
   coin_in: process (KEY(1), selected_coin)
   begin
		if (KEY(1) = '0') then
			case selected_coin is
				when nickel =>
					nickel_in <= '1';
					dime_in <= '0';
					quarter_in <= '0';
				when dime =>
					nickel_in <= '0';
					dime_in <= '1';
					quarter_in <= '0';
				when quarter =>
					nickel_in <= '0';
					dime_in <= '0';
					quarter_in <= '1';
			end case;
		else
			nickel_in <= '0';
			dime_in <= '0';
			quarter_in <= '0';
		end if;
   end process;
	
   state_machine: process (present_state, nickel_in, dime_in, quarter_in)
   begin
		case present_state is
			when st0 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '0';
				if (nickel_in = '1') then
					next_state <= st5;
				elsif (dime_in = '1') then
					next_state <= st10;
				elsif (quarter_in = '1') then
					next_state <= st25;
				else
					next_state <= st0;
				end if;
			when st5 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '0';
				if (nickel_in = '1') then
					next_state <= st10;
				elsif (dime_in = '1') then
					next_state <= st15;
				elsif (quarter_in = '1') then
					next_state <= st30;
				else
					next_state <= st5;
				end if;
			when st10 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '0';
				if (nickel_in = '1') then
					next_state <= st15;
				elsif (dime_in = '1') then
					next_state <= st20;
				elsif (quarter_in = '1') then
					next_state <= st35;
				else
					next_state <= st10;
				end if;
			when st15 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '0';
				if (nickel_in = '1') then
					next_state <= st20;
				elsif (dime_in = '1') then
					next_state <= st25;
				elsif (quarter_in = '1') then
					next_state <= st40;
				else
					next_state <= st15;
				end if;
			when st20 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '0';
				if (nickel_in = '1') then
					next_state <= st25;
				elsif (dime_in = '1') then
					next_state <= st30;
				elsif (quarter_in = '1') then
					next_state <= st45;
				else
					next_state <= st20;
				end if;
			when st25 =>
				candy_out <= '1';
				nickel_out <= '0';
				dime_out <= '0';
				next_state <= st0;
			when st30 =>
				candy_out <= '1';
				nickel_out <= '1';
				dime_out <= '0';
				next_state <= st0;
			when st35 =>
				candy_out <= '1';
				nickel_out <= '0';
				dime_out <= '1';
				next_state <= st0;
			when st40 =>
				candy_out <= '0';
				nickel_out <= '1';
				dime_out <= '0';
				next_state <= st30;
			when st45 =>
				candy_out <= '0';
				nickel_out <= '0';
				dime_out <= '1';
				next_state <= st35;
		end case;   
   end process;
   
   selection: process (KEY(0))
   begin
      if (falling_edge(KEY(0))) then
         case selected_coin is
            when nickel => selected_coin <= dime;
            when dime => selected_coin <= quarter;
            when quarter => selected_coin <= nickel;
         end case;
      end if;
   end process;
   
   display_total: process (present_state)
   begin
		case present_state is
			when st0 =>
				HEX0(6 downto 0) <= "1000000";
				HEX1(6 downto 0) <= "1000000";
			when st5 =>
				HEX0(6 downto 0) <= "0010010";
				HEX1(6 downto 0) <= "1000000";
			when st10 =>
				HEX0(6 downto 0) <= "1000000";
				HEX1(6 downto 0) <= "1111001";
			when st15 =>
				HEX0(6 downto 0) <= "0010010";
				HEX1(6 downto 0) <= "1111001";
			when st20 =>
				HEX0(6 downto 0) <= "1000000";
				HEX1(6 downto 0) <= "0100100";
			when st25 =>
				HEX0(6 downto 0) <= "0010010";
				HEX1(6 downto 0) <= "0100100";
			when others =>
			   HEX0(6 downto 0) <= "1111111";
			   HEX1(6 downto 0) <= "1111111";
		end case;
	end process;
   
   display_current: process (selected_coin, present_state)
   begin
		if (present_state = st0
			or present_state = st5
			or present_state = st10
			or present_state = st15
			or present_state = st20
		) then
         case selected_coin is
            when nickel =>
               HEX4(6 downto 0) <= "0010010";
               HEX5(6 downto 0) <= "1000000";
            when dime =>
               HEX4(6 downto 0) <= "1000000";
               HEX5(6 downto 0) <= "1111001";
            when quarter =>
               HEX4(6 downto 0) <= "0010010";
               HEX5(6 downto 0) <= "0100100";
         end case;
      else
         HEX4(6 downto 0) <= "1111111";
         HEX5(6 downto 0) <= "1111111";
      end if;
   end process;

   display_change: process (present_state)
   begin
		case present_state is
			when st25 =>
				HEX2(6 downto 0) <= "1000000";
				HEX3(6 downto 0) <= "1000000";
				LEDR <= "1000000000";
			when st30 =>
				HEX2(6 downto 0) <= "0010010";
				HEX3(6 downto 0) <= "1000000";
				LEDR <= "1000000010";
			when st35 =>
				HEX2(6 downto 0) <= "1000000";
				HEX3(6 downto 0) <= "1111001";
				LEDR <= "1000000001";
			when st40 =>
				HEX2(6 downto 0) <= "0010010";
				HEX3(6 downto 0) <= "1111001";
				LEDR <= "1000000001";
			when st45 =>
				HEX2(6 downto 0) <= "1000000";
				HEX3(6 downto 0) <= "0100100";
				LEDR <= "1000000001";
			when others =>
				HEX2(6 downto 0) <= "1111111";
				HEX3(6 downto 0) <= "1111111";
				LEDR <= "0000000000";
		end case;
   end process;
end arch;