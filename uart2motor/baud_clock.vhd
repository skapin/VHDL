

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baud_clock is
port (
	clk : IN std_logic;		 	-- FPGA clock
--	divisor : IN integer;		-- Divisor
	enable : IN std_logic;		-- Enable the baudrate clock. set to '1' to enable, '0' to stop and reset values
	baud_clk_8 : OUT std_logic;	-- Output baudrate clock, offset 8
	baud_clk_16 : OUT std_logic	-- Output baudrate clock, offset 16
);
end baud_clock;


architecture behavioral of baud_clock is 
begin
	process(enable, clk)
	variable baud_count : integer range 0 to 16 := 0;
	variable clock_count : integer range 0 to 1023 := 0;
	constant divisor : integer := 87;
	begin

	if ( rising_edge(clk) ) then
		if (enable = '1' ) then
			clock_count := clock_count +1;		-- increase the clock counter.
			if ( clock_count >= divisor ) then
				baud_count := baud_count + 1;	-- increase the baudrate counter
				clock_count := 0;
			end if;
			if ( baud_count = 1 and clock_count = 0) then	-- we need to set the baud_clk to '1' only once
				baud_clk_16 <= '0';
				baud_clk_8 <= '1'; 	-- set the output to '1',
			elsif ( baud_count = 2 and clock_count = 0 ) then
				baud_clk_16 <= '1';
				baud_clk_8 <= '0';
				baud_count := 0;
			else
				baud_clk_8 <= '0';
				baud_clk_16 <= '0';
			end if;
		elsif ( enable = '0' ) then
			baud_count := 0;
			clock_count := 0;
			baud_clk_8 <= '0';
			baud_clk_16 <= '0';
		end if;
	end if;
	end process;
end behavioral;
