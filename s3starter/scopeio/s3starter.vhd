library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of s3starter is

	signal ser_clk    : std_logic;
	signal sys_clk		: std_logic;
	signal vga_clk    : std_logic;
	
	signal input_clk 	: std_logic;
	signal input_data : std_logic_vector(31 downto 0);
	signal input_ena	: std_logic;
	
	signal fs_clk      : std_logic;
	signal fs_clk180   : std_logic;

	signal Q0      : std_logic;
	signal Q1      : std_logic;
	signal D0      : std_logic;
	signal D1      : std_logic;

	signal Pulsos_Out : std_logic;
	signal Diff_Input : std_logic;
	
	signal cic_in  : std_logic_vector(1 downto 0);
	signal cic_out : std_logic_vector(15 downto 0);
	
	constant inputs : natural := 2;

	constant hz_scales : scale_vector(0 to 16-1) := (
		(from => 0.0, step => 2.50001*5.0*10.0**(-1), mult => 10**0*2**0*5**0, scale => "0001", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(-1), mult => 10**0*2**0*5**0, scale => "0010", deca => x"E6"),
                                                                                                 
		(from => 0.0, step => 1.00001*5.0*10.0**(+0), mult => 10**0*2**1*5**0, scale => "0100", deca => x"E6"),
		(from => 0.0, step => 2.50001*5.0*10.0**(+0), mult => 10**0*2**0*5**1, scale => "0101", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(+0), mult => 10**1*2**0*5**0, scale => "0110", deca => x"E6"),
                                                   
		(from => 0.0, step => 1.00001*5.0*10.0**(+1), mult => 10**1*2**1*5**0, scale => "1000", deca => x"E6"),
		(from => 0.0, step => 2.50001*5.0*10.0**(+1), mult => 10**1*2**0*5**1, scale => "1001", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(+1), mult => 10**2*2**0*5**0, scale => "1010", deca => x"E6"),
                                                   
		(from => 0.0, step => 1.00001*5.0*10.0**(-1), mult => 10**2*2**1*5**0, scale => "0000", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(-1), mult => 10**2*2**0*5**1, scale => "0001", deca => to_ascii('m')),
		(from => 0.0, step => 5.00001*5.0*10.0**(-1), mult => 10**3*2**0*5**0, scale => "0010", deca => to_ascii('m')),

		(from => 0.0, step => 1.00001*5.0*10.0**(+0), mult => 10**3*2**1*5**0, scale => "0100", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(+0), mult => 10**3*2**0*5**1, scale => "0101", deca => to_ascii('m')),
		(from => 0.0, step => 5.00001*5.0*10.0**(+0), mult => 10**4*2**0*5**0, scale => "0110", deca => to_ascii('m')),

		(from => 0.0, step => 1.00001*5.0*10.0**(+1), mult => 10**4*2**1*5**0, scale => "1000", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(+1), mult => 10**4*2**0*5**1, scale => "1001", deca => to_ascii('m')));

	constant vt_scales : scale_vector(0 to 16-1) := (
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**1*5**0), scale => "1000", deca => to_ascii('m')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**0*5**1), scale => "1001", deca => to_ascii('m')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**1*5**1), scale => "1010", deca => to_ascii('m')),
                                                                                                                
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**1*5**0), scale => "0000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**0*5**1), scale => "0001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**1*5**1), scale => "0010", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**1*5**0), scale => "0100", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+0), step => -2.50001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**0*5**1), scale => "0101", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+0), step => -5.00001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**1*5**1), scale => "0110", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**1*5**0), scale => "1000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**0*5**1), scale => "1001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**1*5**1), scale => "1010", deca => to_ascii(' ')),
                                                                                                              
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**1*5**0), scale => "0000", deca => to_ascii('k')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**0*5**1), scale => "0001", deca => to_ascii('k')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**1*5**1), scale => "0010", deca => to_ascii('k')),
                                                                                                              
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (125*2**18)/(128*10**5*2**0*5**0), scale => "0100", deca => to_ascii('k')));
		
	component FiltroCIC
	port (
		din: in std_logic_vector(1 downto 0);
		clk: in std_logic;
		dout: out std_logic_vector(15 downto 0);
		rdy: out std_logic;
		rfd: out std_logic);
	end component;
	
begin

	xtal_bufg_inst : BUFG
	port map(
		I => xtal,
		O => sys_clk);
		
	vga_dfs_inst : entity hdl4fpga.dfs
	generic map(
		clkin_period	=> 20.000,
		clkfx_divide	=> 5,
		clkfx_multiply	=> 4)
	port map(
		clkin		=>	sys_clk,
		rst		=> '0',
		clkfx		=>	vga_clk,
		clkfx180 =>	open,
		clk0		=>	ser_clk);
	
	fs_dfs_inst : entity hdl4fpga.dfs
	generic map(
		clkin_period	=> 20.000,
		clkfx_divide	=> 5,
		clkfx_multiply	=> 4)
	port map(
		clkin		=>	sys_clk,
		rst		=> '0',
		clkfx		=>	fs_clk,
		clkfx180 =>	fs_clk180,
		clk0		=>	open);
	
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		layout_id    => 1,
		hz_scales    => hz_scales,
		vt_scales    => vt_scales,
		input_preamp 	=> (0 to  1 => 1.0),
		inputs       => inputs,		--cantidad de entradas deseadas
		gauge_labels => to_ascii(string'(
			"Escala     : " &
			"Posicion   : " &
			"Escala     : " &
			"Posicion   : " &
			"Horizontal : " &
			"Disparo    : ")),
		unit_symbols => to_ascii(string'(
			"V" &
			"V" &
			"V" &
			"V" &
			"s" &
			"V")),
		channels_fg  => b"001" & b"100",	-- un string para cada canal
		channels_bg  => b"000" & b"000",
		hzaxis_fg    => b"010",
		hzaxis_bg    => b"000",
		grid_fg      => b"100",
		grid_bg      => b"000")
	port map (
		ser_clk 		=> ser_clk,
		ser_rx 		=> rs232_rxd,
		input_clk   => fs_clk,
		input_data  => input_data,
		input_ena 	=> input_ena,
		video_clk   => vga_clk,
		video_rgb   => vga_rgb,
		video_hsync => vga_hs,
		video_vsync => vga_vs);

	FiltroCIC_inst : FiltroCIC
	port map(
		din  => cic_in,
		clk  => fs_clk,
		dout => cic_out,
		rdy  => input_ena,
		rfd  => open);
	
	IBUFDS_inst : IBUFDS
	 port map(
		 I  => data_volt_in_p,
		 IB => data_volt_in_n,
		 O  => Diff_Input
	 );
	
	 process(fs_clk)
	 begin
		 if rising_edge(fs_clk) then
			 Pulsos_Out <= Diff_Input;
		 end if;
	 end process;

	 data_volt_out <= not Pulsos_Out;
	
	 cic_in(0) <= Pulsos_Out;
	 cic_in(1) <= '0';
	
	input_data <= cic_out & x"0000";
	
end;