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

library ieee;
use ieee.std_logic_1164.all;

entity s3starter is
	port (
		--		s3s_anodes     : out std_logic_vector(3 downto 0) := (3 downto 0 => '1');
		--		s3s_segment_a  : out std_logic                    := '1';
		--		s3s_segment_b  : out std_logic                    := '1';
		--		s3s_segment_c  : out std_logic                    := '1';
		--		s3s_segment_d  : out std_logic                    := '1';
		--		s3s_segment_e  : out std_logic                    := '1';
		--		s3s_segment_f  : out std_logic                    := '1';
		--		s3s_segment_g  : out std_logic                    := '1';
		--		s3s_segment_dp : out std_logic                    := '1';
		--
		--		switches       : in std_logic_vector(7 downto 0)  := (7 downto 0 => '1');
		--		buttons        : in std_logic_vector(3 downto 0)  := (3 downto 0 => '1');
		leds           : out std_logic_vector(7 downto 0) := (7 downto 0 => '1');

		xtal          : in std_logic                     := '1';

		rs232_rxd     : in std_logic                     := '1';
		rs232_txd     : out std_logic                    := '1';

		-- vga_rgb       : out std_logic_vector(2 downto 0) := (2 downto 0 => '1');
		-- vga_hs        : out std_logic                    := '1';
		-- vga_vs        : out std_logic                    := '1';

		data_volt_in  : in std_logic;
		--data_volt_in_p : in std_logic;
		--data_volt_in_n : in std_logic;
		data_volt_out : out std_logic
	);

	attribute loc                         : string;
	attribute iostandard                  : string;
	attribute slew                        : string;
	attribute drive                       : string;

	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-------------------------------------------

	--	attribute loc of s3s_anodes            : signal is "E13 F14 G14 D14";
	--	attribute loc of s3s_segment_a         : signal is "E14";
	--	attribute loc of s3s_segment_b         : signal is "G13";
	--	attribute loc of s3s_segment_c         : signal is "N15";
	--	attribute loc of s3s_segment_d         : signal is "P15";
	--	attribute loc of s3s_segment_e         : signal is "R16";
	--	attribute loc of s3s_segment_f         : signal is "F13";
	--	attribute loc of s3s_segment_g         : signal is "N16";
	--	attribute loc of s3s_segment_dp        : signal is "P16";

	--	attribute loc of switches              : signal is "K13 K14 J13 J14 H13 H14 G12 F12";
	--	attribute loc of buttons               : signal is "L14 L13 M14 M13";

	attribute loc of leds                  : signal is "P11 P12 N12 P13 N14 L12 P14 K12";

	attribute loc of xtal                 : signal is "T9";
	attribute loc of rs232_rxd            : signal is "T13";
	attribute loc of rs232_txd             : signal is "R13";
	
	-- attribute loc of vga_rgb              : signal is "R12 T12 R11";
	-- attribute loc of vga_hs               : signal is "R9";
	-- attribute loc of vga_vs               : signal is "T10";
	
	attribute iostandard of data_volt_in  : signal is "SSTL2_I";
	attribute loc of data_volt_in         : signal is "E6";
	
	-- Entradas diferenciales
--	attribute iostandard of data_volt_in_p : signal is "LVDS_25";
--	attribute loc of data_volt_in_p        : signal is "A4";
--	attribute iostandard of data_volt_in_n : signal is "LVDS_25";
--	attribute loc of data_volt_in_n        : signal is "B4";

	-- Salida realimentada
	attribute loc of data_volt_out        : signal is "C5";
	--attribute loc of data_volt_out         : signal is "C7";
	attribute slew of data_volt_out       : signal is "FAST";
	attribute drive of data_volt_out      : signal is "8";
	attribute iostandard of data_volt_out  : signal is "LVCMOS33";
	-- attribute iostandard of data_volt_out : signal is "SSTL2_I";

end;