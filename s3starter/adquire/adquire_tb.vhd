library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity adquire_tb is

end entity adquire_tb;

architecture adquire_arq of adquire_tb is

	constant c_BIT_PERIOD : time      := 40 ns; --c_CLKS_PER_BIT*period
	signal rst			: std_logic := '1';
	signal fs_clk         : std_logic := '1';
	signal ser_clk        : std_logic := '1';
	signal i_wr_ena       : std_logic := '0';
	signal rs232_rxd      : std_logic := '1';
	signal rs232_txd      : std_logic := '1';
	signal data           : std_logic_vector(15 downto 0);
	signal myinteger      : integer;
	
	-- Low-level byte-write
	procedure UART_WRITE_BYTE (
		i_data_in       : in std_logic_vector(7 downto 0);
		signal o_serial : out std_logic) is
	begin

		-- Send Start Bit
		o_serial <= '0';
		wait for c_BIT_PERIOD;

		-- Send Data Byte
		for ii in 0 to 7 loop
			o_serial <= i_data_in(ii);
			wait for c_BIT_PERIOD;
		end loop; -- ii

		-- Send Stop Bit
		o_serial <= '1';
		wait for c_BIT_PERIOD;
		
	end UART_WRITE_BYTE;

begin

	adquire_e : entity work.adquire
		port map(
			i_fs_clk  => fs_clk,
			i_ser_clk => ser_clk,
			i_rst	=> rst,
			i_data    => data,
			i_data_ena  => i_wr_ena,
			i_rx_serial => rs232_rxd,
			o_tx_serial => rs232_txd
		);

	data     <= std_logic_vector(to_unsigned(myinteger, 16));
	--data <= std_logic_vector(to_unsigned(65280, 16));
	fs_clk   <= not fs_clk after 12.5 ns;
	ser_clk  <= not ser_clk after 10 ns;
	
	i_wr_ena <= '1' after 800 ns;
	rst <= '0' after 100 ns;
	
	Rx_Receiver : process
	begin
		wait for 800000 ns;
		UART_WRITE_BYTE(X"33", rs232_rxd);
		wait for 500 ns;
		UART_WRITE_BYTE(X"0A", rs232_rxd);
		wait;
	end process;

	Random_Numbers : process (fs_clk)
		variable seed1, seed2  : positive; -- seed values for random generator
		variable rand          : real; -- random real-number value in range 0 to 1.0  
		variable range_of_rand : real := 65535.0; -- the range of random values created will be 0 to +1000.
	begin
		if rising_edge(fs_clk) then
			uniform(seed1, seed2, rand); -- generate random number
			myinteger <= integer(rand * range_of_rand); -- rescale to 0..1000, convert integer part 
		end if;
	end process;

end architecture adquire_arq;