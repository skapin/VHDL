-- Company: <Name>
--
-- File: uart.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
port (
	clk : IN std_logic; 	-- FPGA clock
	rx : IN std_logic;		-- RX link
	data : OUT std_logic_vector (7 downto 0);
	data_ready : OUT std_logic
);
end uart_rx;

architecture behavioral of uart_rx is
signal baud_clock_enable : std_logic := '0' ;
signal baud_clk_8 : std_logic :='0';
signal baud_clk_16 : std_logic :='0';
signal state : integer range 0 to 7 :=0;

component baud_clock
port (
	clk : IN std_logic;		 	-- FPGA clock
--	divisor : IN integer;		-- Divisor
	enable : IN std_logic;		-- Enable the baudrate clock. set to '1' to enable, '0' to stop and reset values
	baud_clk_8 : OUT std_logic;	-- Output baudrate clock
	baud_clk_16 : OUT std_logic	-- Output baudrate clock
);
end component;

begin
	baud_component : baud_clock port map (clk, baud_clock_enable, baud_clk_8, baud_clk_16);
	process (baud_clk_8, baud_clk_16, clk)
	variable data_count : integer range 0 to 8 := 0;
	variable data_buffer : std_logic_vector ( 7 downto 0 ) := x"00" ;
	constant stop_bit : std_logic := '1';
	constant start_bit : std_logic := '0';
	constant data_length : integer := 8; 
	variable rx_in : std_logic;

	begin
		if ( rising_edge(clk) ) then
			rx_in := rx;
			data_ready <= '0';
			case state is
			when  0 => 		-- State Idle, wait for start bit
				data <= data_buffer;
				baud_clock_enable <= '0';
				if ( rx = start_bit ) then	-- Start bit : initialize values
					baud_clock_enable <= '1';
					state <= 1;
				end if;
			when 1 =>
				if ( baud_clk_8 ='1' ) then	-- time to check (half-bit-size)
					if ( rx_in = start_bit ) then --Still the start bit ?
						data_count := 0;
						state <= 2;
						data_buffer := x"FF";
					else
						state <= 0;
					end if;
				end if;
			when  2 => 
				if ( baud_clk_8 ='1' ) then	-- time to check (half-bit-size)
					data_buffer( data_length - (data_count+1) ) := rx;
					data_count := data_count +1;
				end if;
				if ( data_count >= data_length ) then	-- If all datas raceived, change state.
					state <= 3;
					data_count := 0;
				end if;
			when 3 => 
				if ( baud_clk_8 = '1' ) then 
					if ( rx_in = stop_bit ) then -- is a stop bit ?
						state <= 0;
						data <= data_buffer;
						baud_clock_enable <= '0';
						data_ready <= '1';
					else
						state <= 0;
						data_buffer := x"FF";
					end if;
				end if;
			when others =>
				state <= 0;
				data_buffer := x"00";
			end case;
		end if; -- end rising_edge()
	end process;
end behavioral;





