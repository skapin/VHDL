

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.frame_controller_fsm.ALL;

entity controller is
port (
	clk : IN std_logic; 	-- FPGA clock
	data_in : IN std_logic_vector (7 downto 0);
	addresses : IN std_logic_vector (3 downto 0);
	actions : IN std_logic_vector (3 downto 0);
	component_id : IN std_logic_vector (3 downto 0); 		-- Better if Generic MAP, check this dude.
	pwm : OUT std_logic;
	direction : OUT std_logic;
	enable_motor : OUT std_logic
);
end controller;

architecture behavioral of controller is

component pid
port(


end component;

begin
--instancier les components !!!
process (clk)

variable Kp : integer ;
variable Ki : integer ;
variable Kd : integer ;

variable sense_max : integer ;
variable bfm_max : integer ;
variable order : integer ;
variable direction : std_logic := '0';
variable pwm : integer := 0;

variable action : Action ;
variable byte_count : integer := 0;
variable tmp : std_logic_vector ( 15 downto 0 ) := x"0000";

begin
	if ( rising_edge( clk ) ) then
		if ( addresses = component_id ) then		-- is this order for this component ? (MUX)
		
			-- GET THE ACTION
			if ( action = set_pid ) then 			-- do the action
				if ( byte_count = 0) then
					tmp := data_in;
					tmp := tmp < 8;
				elsif ( byte_count = 1) then
					tmp := tmp | data_in;
					order <= tmp;
				else
					tmp := 00;
				end if;
			elsif ( action = set_pwm ) then 
				if ( byte_count = 0) then
					tmp := data_in;
					tmp := tmp < 8;
				elsif ( byte_count = 1) then
					tmp := tmp | data_in;
					pwm <= tmp;
				else
					tmp := 00;
				end if;
				
			elsif ( action = set_stop ) then 
				enable_motor <= '0';
			elsif ( action = set_v_moteurs ) then 
				if ( byte_count = 0 ) then
					if ( data_in = b"00000110" ) then 
						tension_12v <= '0';
					elsif ( data_in = b"000001100" ) then 
						tension_12v <= '1';
					else
						tension_12v <= '0';
					end if;
				end if;				
			elsif ( action = set_securite_sense ) then 
				if ( byte_count = 0) then
					tmp := data_in;
					tmp := tmp < 8;
				elsif ( byte_count = 1) then
					tmp := tmp | data_in;
					sense_max <= tmp;
				else
					tmp := 00;
				end if;
			elsif ( action = set_maxspeed ) then
				if ( byte_count = 0) then
					tmp := data_in;
					tmp := tmp < 8;
				elsif ( byte_count = 1) then
					tmp := tmp | data_in;
					bfm_max <= tmp;
				else
					tmp := 00;
				end if;
			
			elsif ( action = set_kpkikd ) then 
				if ( byte_count = 0) then
					Kp := data_in;
				elsif ( byte_count = 1) then
					Ki := data_in;
				elsif ( byte_count = 2) then
					Kd := data_in;					
				end if;			
			elsif ( action = set_reboot ) then 
			
			elsif ( action = get_param0 ) then 
			
			elsif ( action = get_param1 ) then 
			
			else
			
			end if;	-- end of action test
			if ( byte_count < 8 ) then 
				byte_count := byte_count +1;
			else
				byte_count := 0;
		end if;		-- end of addresses = component_id
	end if; -- end of rising-edge
	
end process;


end behavioral;







