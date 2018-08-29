library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Contador_saturado is
	generic (
		bits : positive := 8
	);
	port (
		i_clk : in std_logic;
		i_ena : in std_logic;
		i_rst : in std_logic;
		o_cnt : out std_logic_vector(bits - 1 downto 0);
		o_full : out std_logic
	);
end entity Contador_saturado;

architecture Contador_saturado_arq of Contador_saturado is
	signal counter : unsigned(bits downto 0);
	signal counter_ena : std_logic;
begin
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_rst = '1' then
				counter <= to_unsigned(0, bits + 1);
			elsif counter_ena = '1' then
				counter <= counter + 1;
			end if;
		end if;
	end process;

	counter_ena <= i_ena and not counter(bits);
	o_cnt <= std_logic_vector(counter(bits - 1 downto 0));
	o_full <= counter(bits);

end architecture Contador_saturado_arq;