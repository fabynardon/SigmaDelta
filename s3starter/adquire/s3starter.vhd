library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

architecture Behavioral of s3starter is

	component FiltroCIC
		port (
			din  : in std_logic_vector(2 downto 0);
			clk  : in std_logic;
			dout : out std_logic_vector(15 downto 0);
			rdy  : out std_logic;
			rfd  : out std_logic);
	end component;

	signal sys_clk : std_logic;
	signal ser_clk	: std_logic;
	signal fs_clk	: std_logic;
	signal fs_clk180	: std_logic;

	signal Q0      : std_logic;
	signal Q1      : std_logic;
	
	signal D0      : std_logic;
	signal D1      : std_logic;

	signal Pulsos_Out : std_logic;
	signal Diff_Input : std_logic;
	
	signal cic_in  : std_logic_vector(2 downto 0);
	signal cic_out : std_logic_vector(15 downto 0);
	
	signal wr_ena	:	std_logic;

begin

	IBUFG_inst : IBUFG
	port map(
		O => sys_clk, -- Clock buffer output
		I => xtal -- Clock buffer input
	);

	fs_dfs_inst : entity hdl4fpga.dfs
	generic map(
		clkin_period	=> 20.000,
		clkfx_divide	=> 5,
		clkfx_multiply	=> 4)
	port map(
		clkin		=>	sys_clk,
		rst		=> '0',
		clkfx		=>	fs_clk,
		clkfx180 =>	fs_clk180);
		--clk0		=>	ser_clk);
	
--	dfs_inst : entity work.dfs
--		generic map(
--			dcm_per => 20.0, --Periodo
--			dfs_mul => 4,
--			dfs_div => 5)
--		port map(
--			dcm_rst    => '0',
--			dcm_clk    => sys_clk,
--			dfs_clk    => fs_clk,
--			dfs_clk180 => open);

	IFDDRRSE_inst : IFDDRRSE
	port map(
		Q0 => Q0, -- Posedge data output
		Q1 => Q1, -- Negedge data output
		C0 => fs_clk, -- 0 degree clock input
		C1 => fs_clk180, -- 180 degree clock input
		CE => '1', -- Clock enable input
		D  => data_volt_in, -- Data input (connect directly to top-level port)
		R  => '0', -- Synchronous reset input
		S  => '0' -- Synchronous preset input
	);

	D0 <= not Q1;
	D1 <= not Q0;

	OFDDRRSE_inst : OFDDRRSE
	port map(
		Q  => data_volt_out, -- Data output (connect directly to top-level port)
		C0 => fs_clk, -- 0 degree clock input
		C1 => fs_clk180, -- 180 degree clock input
		CE => '1', -- Clock enable input
		D0 => D0, -- Posedge data input
		D1 => D1, -- Negedge data input
		R  => '0', -- Synchronous reset input
		S  => '0' -- Synchronous preset input
	);

	cic_in(0) <= Q0 xor Q1;
	cic_in(1) <= Q0 and Q1;
	cic_in(2) <= '0';
	
	-- IBUFDS_inst : IBUFDS
	-- port map(
		-- I  => data_volt_in_p,
		-- IB => data_volt_in_n,
		-- O  => Diff_Input
	-- );
	
	-- process(C0)
	-- begin
		-- if rising_edge(C0) then
			-- Pulsos_Out <= Diff_Input;
		-- end if;
	-- end process;

	-- data_volt_out <= not Pulsos_Out;
	
	-- cic_in(0) <= Pulsos_Out;
	-- cic_in(1) <= '0';

	FiltroCIC_inst : FiltroCIC
	port map(
		din  => cic_in,
		clk  => fs_clk,
		dout => cic_out,
		rdy  => wr_ena,
		rfd  => open);

	adquire_inst : entity work.adquire
	port map(
		i_fs_clk    => fs_clk,
		i_ser_clk   => sys_clk,
		i_rst       => '0',
		i_data      => cic_out,
		--i_data => std_logic_vector(to_unsigned(15837,16)),
		i_data_ena  => wr_ena,
		--i_data_ena => '1',
		i_rx_serial => rs232_rxd,
		o_tx_active => leds(0),
		o_tx_serial => rs232_txd);
		
	leds(7 downto 1) <= (others => '0');

	vga_rgb          <= (others    => '0');
	vga_hs           <= '0';
	vga_vs           <= '0';

end Behavioral;