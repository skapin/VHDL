

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.frame_controller_fsm.ALL;


-- Add a CLR signal IN, to reset when stop bit receive ? 
-- Insurance to not have a deadLock somewhere (esp state 1)
entity frame_controller is
port (
	clk : IN std_logic; 	-- FPGA clock
	data_ready : IN std_logic;
	data_in : IN std_logic_vector (7 downto 0);
	data_out : OUT std_logic_vector (7 downto 0);
	addresses : OUT std_logic_vector ( 3 downto 0);
	actions : OUT std_logic_vector ( 3 downto 0);
	reset_rx : IN std_logic;
	activate : OUT std_logic
);
end frame_controller;

architecture behavioral of frame_controller is
signal state : integer range 0 to 3 :=0;
type DataBuffer is array(6 downto 0) of std_logic_vector(7 downto 0);

begin
process (clk)
variable addr_intern : std_logic_vector ( 3 downto 0 ) := x"0";
variable action_intern : std_logic_vector ( 3 downto 0 ) :=x"0";
variable count_byte : integer := 0;
variable chk : integer := 0;
variable data_buffer : DataBuffer;
variable send_data : boolean := FALSE;
begin
	if ( rising_edge(clk) ) then
		if ( reset_rx = '1' ) then
			state <= 0;
		end if;
		-- FSM
		case state is
		when 0 =>	-- idle, wait for @.
			addr_intern := x"0";
			action_intern := x"0";
			data_out <= x"00";

			addresses <= addr_intern;
			actions <= action_intern;
			activate <= '0';
			count_byte := 0;
			if ( data_ready = '1' ) then
				state <= 1;
				addr_intern := get_addresse( data_in );
				
				--calculate chk
			end if;
		when 1 =>	--@ received, wait for action.
			activate <= '0';
			data_out <= x"00";
			if ( data_ready = '1' ) then
				state <= 2;
				action_intern := get_action(data_in) ;
				count_byte := 0;
			end if;
		when 2 =>	-- Store the data inside datta_buffer, increate the PTR (count_byte)
			data_out <= x"00";
			activate <= '0';
			if ( data_ready = '1' ) then
				data_buffer(count_byte) := data_in;
				count_byte := count_byte +1;
				if ( count_byte = 7 ) then
					state <= 3;
				end if;
			end if;
		when 3 =>	-- wait for chk, the end of frame. Now  we can send data_buffer to data_out. 
					-- For each clk clock, we send a new Byte
			data_out <= x"00";
			activate <= '0';
			if ( data_ready = '1' ) then
				-- check chk
				send_data := TRUE;
				state <= 3;
				addresses <= addr_intern;
				actions <= action_intern;
			end if;
			if (  send_data ) then
			activate <= '1';
				data_out <= data_buffer( 7 - count_byte );
				count_byte := count_byte - 1;
				if ( count_byte <= 0 ) then
					state <= 0;
					send_data := FALSE;
				end if;
			end if;
		when others =>
			activate <= '0';
			state <= 0;
			data_out <= x"00";
		end case;
	end if; -- end of rising-edge
end process;


end behavioral;






