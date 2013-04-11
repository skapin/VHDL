--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: tx_buffer.vhd
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

entity tx_buffer is
port (
	clk : IN std_logic;
	data_in : IN std_logic_vector( 7 downto 0 );
	send_data : IN std_logic;
	tx_ready : IN std_logic;
	data_out : OUT std_logic_vector( 7 downto 0 );
	enable_tx : OUT std_logic
);
end tx_buffer;

architecture behavioral of tx_buffer is
type DataBufferTx is array(14 downto 0) of std_logic_vector(7 downto 0);
begin

process (clk)
variable fifo : DataBufferTx;
variable fifo_in : integer range 0 to 15 := 0;
variable fifo_out : integer range 0 to 15 := 0;
variable enabletx : std_logic := '0';
begin
	if ( rising_edge(clk) ) then
	--Mise en file
	if ( send_data = '1' ) then
		fifo( fifo_in ) := data_in;
		fifo_in := fifo_in +1;
		if ( fifo_in > 14 ) then
			fifo_in := 0;
		end if;
	end if;
	-- Envoie des données de la file vers le module TX
	if ( fifo_in /= fifo_out ) then
		if ( tx_ready = '1' and enabletx = '0' ) then
			data_out <= fifo( fifo_out );
			enabletx := '1';
			fifo_out := fifo_out + 1;
			if ( fifo_out > 14 ) then
				fifo_out := 0;
			end if;
		else
			enabletx := '0';
		end if;
	else
		enabletx := '0';
	end if;
	enable_tx <= enabletx;
	end if; 	--Risign_edge(CLK) ;

end process;


end behavioral;

