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

entity uart_controler is
port (
	clk : IN std_logic; 	-- FPGA clock
	rx : IN std_logic;		-- RX link
--	rx_buffer : OUT std_logic_vector (7 downto 0);	-- Data received from RX
	tx : OUT std_logic;		-- TX link
--	tx_buffer : IN std_logic_vector (7 downto 0);	-- Data to send (TX)
--	use_tx : IN std_logic;		-- Set to '1' to send data (TX), Set '0' to disable (TX is off)
	tx_busy: OUT std_logic
);
end uart_controler;

architecture behavioral of uart_controler is
signal buffer_intern : std_logic_vector ( 7 downto 0 ) := x"00";
signal use_tx : std_logic :='1';
component uart_rx
port (
	clk : IN std_logic; 	-- FPGA clock
	rx : IN std_logic;		-- RX link
	data : OUT std_logic_vector (7 downto 0)
);
end component;
component uart_tx
port (
	wake_up : IN std_logic;
	clk : IN std_logic; 	-- FPGA clock
	data : IN std_logic_vector (7 downto 0);	-- Data to send 
	tx : OUT std_logic;		-- TX link
	busy : OUT std_logic
);
end component;
begin

uart_rxx: uart_rx port map(clk, rx, buffer_intern );
uart_txx : uart_tx port map( use_tx, clk, buffer_intern, tx, tx_busy );
--rx_buffer <= buffer_intern;

end behavioral;





