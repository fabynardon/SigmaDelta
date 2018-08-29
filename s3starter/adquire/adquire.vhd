library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity adquire is
	port (
		i_fs_clk    : in std_logic;
		i_ser_clk   : in std_logic;
		i_rst       : in std_logic;
		i_data      : in std_logic_vector(15 downto 0);
		i_data_ena  : in std_logic;
		i_rx_serial : in std_logic;
		o_tx_active	:	out	std_logic;
		o_tx_serial : out std_logic);
end entity adquire;

architecture adquire_arq of adquire is

	constant c_CLKS_PER_BIT : integer := 217;
	constant g_address_bits : positive  := 13;

	signal rst              : std_logic := '0';
	signal write_done       : std_logic;
	signal send_done        : std_logic;
	signal selector         : std_logic;

	signal rst_cont_0       : std_logic := '0';
	signal ena_cont_0       : std_logic := '1';
	signal out_cont_0       : std_logic_vector(g_address_bits - 1 downto 0);

	signal rst_cont_1       : std_logic := '0';
	signal ena_cont_1       : std_logic := '1';
	signal out_cont_1       : std_logic_vector(g_address_bits downto 0);

	signal rd_addr          : std_logic_vector(g_address_bits - 1 downto 0);
	signal rd_data          : std_logic_vector(15 downto 0);

	signal start            : std_logic;

	signal tx_done          : std_logic;
	signal tx_dv            : std_logic;
	signal tx_byte          : std_logic_vector(7 downto 0);

	signal rx_dv            : std_logic;
	signal rx_byte          : std_logic_vector(7 downto 0);

begin

	Contador_Saturado_0 : entity work.contador_saturado
		generic map(bits => g_address_bits)
		port map(
			i_clk  => i_fs_clk,
			i_ena  => ena_cont_0,
			i_rst  => rst_cont_0,
			o_cnt  => out_cont_0,
			o_full => write_done
		);

	ena_cont_0 <= i_data_ena and not write_done;
	rst_cont_0 <= i_rst or rst;

	Contador_Saturado_1 : entity work.contador_saturado
		generic map(bits => g_address_bits + 1)
		port map(
			i_clk  => i_ser_clk,
			i_ena  => ena_cont_1,
			i_rst  => rst_cont_1,
			o_cnt  => out_cont_1,
			o_full => send_done
		);

	start_process : process (i_ser_clk)
		variable flag : std_logic := '0';
	begin
		if rising_edge(i_ser_clk) then
			if write_done = '1' and flag = '0' then
				flag := '1';
				start <= '1';
			elsif write_done = '1' and flag = '1' then
				start <= '0';
			elsif write_done = '0' and flag = '1' then
				flag := '0';
			else
				start <= '0';
			end if;
		end if;
	end process;

	rst_cont_1 <= i_rst or rst;
	ena_cont_1 <= write_done and (tx_done or start);

	Bram_registers : process (i_ser_clk)
	begin
		if rising_edge(i_ser_clk) then
			rd_addr <= out_cont_1(g_address_bits downto 1);
			if selector = '1' then
				tx_byte <= rd_data(7 downto 0);
			else
				tx_byte <= rd_data(15 downto 8);
			end if;
			selector <= out_cont_1(0);

			tx_dv    <= not send_done and (tx_done or start);
		end if;
	end process;

	Block_Ram : entity work.dpram
		port map(
			rd_addr => rd_addr,
			rd_data => rd_data,
			wr_clk  => i_fs_clk,
			wr_ena  => ena_cont_0,
			wr_addr => out_cont_0,
			wr_data => i_data);

	Uart_Tx : entity work.uart_tx
		generic map(
			g_CLKS_PER_BIT => c_CLKS_PER_BIT
		)
		port map(
			i_clk       => i_ser_clk,
			i_tx_dv     => tx_dv,
			i_tx_byte   => tx_byte,
			o_tx_active => o_tx_active,
			o_tx_serial => o_tx_serial,
			o_tx_done   => tx_done
		);

	Uart_Rx : entity work.uart_rx
		generic map(
			g_CLKS_PER_BIT => c_CLKS_PER_BIT
		)
		port map(
			i_Clk       => i_ser_clk,
			i_RX_Serial => i_rx_serial,
			o_RX_DV     => rx_dv,
			o_RX_Byte   => rx_byte
		);

	process (i_ser_clk)
	begin
		if rising_edge(i_ser_clk) then
			if rx_dv = '1' then
				case rx_byte is
					when "00110011" =>
						rst <= '1';
					when "00001010" =>
						rst <= '0';
					when others =>
						rst <= '0';
				end case;
			end if;
		end if;
	end process;

end architecture adquire_arq;