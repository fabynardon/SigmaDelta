--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_serrx is
	port (
		ser_clk	 	: in  std_logic;	
		ser_rx		: in std_logic;
		
		pll_rdy  : out std_logic;
		pll_data : out std_logic_vector);
end;

architecture mix of scopeio_serrx is

	signal ser_rxdv 	: std_logic;
	signal ser_rxd  : std_logic_vector(0 to 7);
begin

	UART_RX_e : entity hdl4fpga.UART_RX
	  generic map(
		g_CLKS_PER_BIT => 434     -- Needs to be set correctly (@ 50Mhz/434 = 115200)
		)
	  port map(
		i_Clk			=> ser_clk,
		i_RX_Serial		=> ser_rx,
		o_RX_DV			=> ser_rxdv,
		o_RX_Byte		=> ser_rxd
		);
	
	pll_p : process(ser_clk)
		variable data : unsigned(0 to pll_data'length-1);
	begin
		if rising_edge(ser_clk) then
		
			if ser_rxdv = '1' then 
				if ser_rxd = X"FF" then
					pll_rdy <= '1';
				else 
					data := data srl ser_rxd'length;
					data(ser_rxd'range) := unsigned(ser_rxd);
					pll_data <= reverse(std_logic_vector(data));
					pll_rdy <= '0';
				end if;
				
			end if;
		end if;
	end process;

end;
