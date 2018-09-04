library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dfs is
		generic (
		clkin_period 	: real := 20.0;
		clkfx_divide 	: natural := 3;
		clkfx_multiply	: natural := 10);
	port (
		clkin    		: in std_logic;
		rst      		: in std_logic;
		clkfx				: out std_logic;
		clkfx180			: out std_logic;
		clk0     		: out std_logic);
end dfs;

architecture dfs_arq of dfs is

	signal clkfb_in     	: std_logic;
	signal clkfx_buf    	: std_logic;
	signal clkfx180_buf	: std_logic;
	signal clk0_buf     	: std_logic;
	signal gnd_bit      	: std_logic;
	
begin

	gnd_bit <= '0';
	clk0    <= clkfb_in;

	CLKFX_BUFG_INST : BUFG
	port map(
		I => clkfx_buf,
		O => clkfx);

	CLKFX180_BUFG_INST : BUFG
	port map(
		I => clkfx180_buf,
		O => clkfx180);

	CLK0_BUFG_INST : BUFG
	port map(
		I => clk0_buf,
		O => clkfb_in);

	DCM_INST : DCM
	generic map(
		CLK_FEEDBACK          => "1X",
		CLKDV_DIVIDE          => 2.0,
		CLKFX_DIVIDE          => clkfx_divide,
		CLKFX_MULTIPLY        => clkfx_multiply,
		CLKIN_DIVIDE_BY_2     => FALSE,
		CLKIN_PERIOD          => clkin_period,
		CLKOUT_PHASE_SHIFT    => "NONE",
		DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
		DFS_FREQUENCY_MODE    => "low",
		DLL_FREQUENCY_MODE    => "low",
		DUTY_CYCLE_CORRECTION => TRUE,
		FACTORY_JF            => x"c080",
		PHASE_SHIFT           => 0,
		STARTUP_WAIT          => FALSE)
	port map(
		CLKFB    	=> clkfb_in,
		CLKIN    	=> clkin,
		DSSEN    	=> gnd_bit,
		PSCLK    	=> gnd_bit,
		PSEN     	=> gnd_bit,
		PSINCDEC 	=> gnd_bit,
		RST      	=> rst,
		CLKDV    	=> open,
		CLKFX    	=> clkfx_buf,
		CLKFX180		=> clkfx180_buf,
		CLK0     	=> clk0_buf,
		CLK2X    	=> open,
		CLK2X180 	=> open,
		CLK90    	=> open,
		CLK180   	=> open,
		CLK270   	=> open,
		LOCKED   	=> open,
		PSDONE   	=> open,
		STATUS   	=> open);

end dfs_arq;