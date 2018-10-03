library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity s3starter is
	port(
		leds				: out std_logic_vector(7 downto 0) := (7 downto 0 => '1');
		xtal				: in std_logic                     := '1';

		rs232_rxd		: in std_logic                     := '1';
		rs232_txd		: out std_logic                    := '1';

		data_volt_in_p	: in std_logic;
		data_volt_in_n	: in std_logic;
		
		data_volt_out	: out std_logic);
end;

architecture Behavioral of s3starter is

	component FiltroCIC
		port (
			din  : in std_logic_vector(1 downto 0);
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
	
	-- signal cic_in  : std_logic_vector(2 downto 0);
	signal cic_in  : std_logic_vector(1 downto 0);
	signal cic_out : std_logic_vector(15 downto 0);
	
	signal wr_ena	:	std_logic;
	
	signal Diff_Output : std_logic;
	signal Pulsos_Out	:	std_logic;
	
begin

	IBUFG_inst : IBUFG
	port map(
		O => sys_clk, -- Clock buffer output
		I => xtal -- Clock buffer input
	);
	
	fs_dfs_inst : entity hdl4fpga.dfs
	generic map(
		dcm_per	=> 20.0,
		dfs_div	=> 5,
		dfs_mul	=> 4)
	port map(
		dcm_clk		=>	sys_clk,
		dcm_rst		=> '0',
		dfs_clk		=>	fs_clk,
		dfs_clk180 	=>	open,
		dcm_lck		=> leds(7));

	IBUFDS_inst : IBUFDS
	generic map (
		CAPACITANCE => "DONT_CARE",
		DIFF_TERM => FALSE,
		IBUF_DELAY_VALUE => "0",
		IFD_DELAY_VALUE => "AUTO",
		IOSTANDARD => "DEFAULT")
	port map (
		O => Diff_Output,
		I => data_volt_in_p,
		IB => data_volt_in_n);

	FDCE_inst : FDCE
	generic map (
		INIT => '0') -- Initial value of register ('0' or '1')
	port map (
		Q => Pulsos_Out,
		C => fs_clk,
		CE => '1',
		CLR => '0',
		D => Diff_Output);
	
	
	cic_in(0) <= Pulsos_Out;
	cic_in(1) <= '0';
	
	data_volt_out <= not Pulsos_Out;
	
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
		-- i_data		=> std_logic_vector(to_unsigned(14876,16)),
		i_data_ena  => wr_ena,
		-- i_data_ena  => '1',
		i_rx_serial => rs232_rxd,
		o_tx_active => leds(0),
		o_tx_serial => rs232_txd);
		
	leds(6 downto 1) <= (others => '0');

end Behavioral;