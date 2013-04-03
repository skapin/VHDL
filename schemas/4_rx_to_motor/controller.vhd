

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
	captor_value : IN std_logic_vector ( 15 downto 0 );	-- Bfm
	sense_value : IN std_logic_vector ( 15 downto 0 );	-- sense 
	command : OUT std_logic_vector(7 downto 0);
	direction : OUT std_logic;
	enable_motor : OUT std_logic;
	is_v12 : OUT std_logic
);
end controller;

architecture behavioral of controller is
component pid 
port (
    clk : IN std_logic;
    order : IN std_logic_vector(15 downto 0);
    captor_value : IN std_logic_vector(15 downto 0);
	enable_pid : IN std_logic;	-- if '0', command = order = pwm,
	Ki : IN std_logic_vector( 7 downto 0 );
	Kp : IN std_logic_vector( 7 downto 0 );
	Kd : IN std_logic_vector( 7 downto 0 );
	BFM_max : IN std_logic_vector( 15 downto 0 );
	command : OUT std_logic_vector ( 7 downto 0);
	direct : OUT std_logic
);
end component;
signal order : std_logic_vector( 15 downto 0 ) := x"0000";
signal Kp : std_logic_vector( 7 downto 0 ) := x"00";
signal Ki : std_logic_vector( 7 downto 0 ) := x"00";
signal Kd : std_logic_vector( 7 downto 0 ) := x"00";
signal enable_pid : std_logic :='1';
signal is_v12_intern : std_logic :='1';
signal bfm_max : std_logic_vector( 15 downto 0 ) := x"0000" ;
signal sense_max : std_logic_vector( 15 downto 0 ) := x"0000" ;
begin

pidd : pid port map ( clk, order, captor_value, enable_pid, Ki, Kp, Kd, bfm_max,  command, direction );

is_v12 <= is_v12_intern;
process (clk)


variable action : Action ;
variable byte_count : integer range 0 to 15 := 0;
variable tmp : std_logic_vector ( 15 downto 0 ) := x"0000";
begin
	if ( rising_edge( clk ) ) then
		if ( addresses = component_id ) then		-- is this order for this component ? (MUX)
			action := conv2Action( actions );		-- Convert the actions BUS to an Action (cf work.frame_controller_fsm.vhd)
			case action is 
			when  set_pid => 			-- do the action
				enable_motor <= '1';
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					order <= tmp;
					enable_pid <= '1';
				else
					tmp := x"0000";
				end if;
			when set_pwm =>
				enable_motor <= '1';
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					order <= tmp ;
					enable_pid <= '0';
				else
					tmp := x"0000";
				end if;
			when set_stop => 
				enable_motor <= '0';		-- Start motor ?
			when set_v_moteurs => 
				if ( byte_count = 0 ) then
					if ( data_in = b"00000110" ) then 	 -- 6V
						is_v12_intern <= '0';
					elsif ( data_in = b"000001100" ) then 	-- 12 V
						is_v12_intern <= '1';
					else
						is_v12_intern <= '0';
					end if;
				end if;				
			when  set_securite_sense =>
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					sense_max <= tmp;
				else
					tmp := x"0000";
				end if;
			when set_maxspeed =>
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					bfm_max <= tmp;
				else
					tmp := x"0000";
				end if;
			
			when set_kpkikd =>
				if ( byte_count = 0) then
					Kp <= data_in;
				elsif ( byte_count = 1) then
					Ki <= data_in;
				elsif ( byte_count = 2) then
					Kd <= data_in;					
				end if;			
			when set_reboot =>
				order <= x"0000";
				enable_motor <= '0';			
				byte_count := 6;	-- On met la valeur maximal, comme ca, le test va rectifier la valeur et mettre 0
			when get_param0 =>
			
			when get_param1 =>
			
			when others =>
				order <= x"0000";
				enable_motor <= '0';			
				byte_count := 0;
				enable_pid <='0';
			
			end case;	-- end of action Case Test - on recoit 7octets (de 0 a 5+1). 
			if ( byte_count < 6 ) then 
				byte_count := byte_count +1;
			else
				byte_count := 0;
			end if;
		end if;		-- end of addresses = component_id
		-- La tension est elle trop forte ?
		if ( sense_value > sense_max ) then
			order <= x"0000";
			enable_motor <= '0';
		end if;
	end if; -- end of rising-edge
	
end process;


end behavioral;







