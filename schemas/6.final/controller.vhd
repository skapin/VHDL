

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
	tx_data_chain_out : OUT std_logic_vector(7 downto 0);
	use_tx_data_chain_out : OUT std_logic;
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
signal command_intern : std_logic_vector ( 7 downto 0) := x"00";
begin

pidd : pid port map ( clk, order, captor_value, enable_pid, Ki, Kp, Kd, bfm_max,  command_intern, direction );
command <= command_intern ;
is_v12 <= is_v12_intern;
process (clk)


variable action : Action ;
variable byte_count : integer range 0 to 15 := 0;
variable byte_count_tx : integer range 0 to 15 := 0;
variable cpmt_fuse : std_logic_vector(7 downto 0 ) := x"00";
variable tmp : std_logic_vector ( 15 downto 0 ) := x"0000";
variable send_data : integer range 0 to 3 := 0;
variable chk : std_logic_vector(7 downto 0 ) := x"00";
variable tx_data_chain_out_intern : std_logic_vector(7 downto 0 ) := x"00";
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
			when set_stop => 				-- Stop le moteur. Start implicite au niveua de l'affect du pid et du pwm
				enable_motor <= '0';
			when set_v_moteurs => 			-- Mise en tension du moteur a 6 ou 12 V
				if ( byte_count = 0 ) then
					if ( data_in = b"00000110" ) then 	 -- 6V
						is_v12_intern <= '0';
					elsif ( data_in = b"000001100" ) then 	-- 12 V
						is_v12_intern <= '1';
					else
						is_v12_intern <= '0';
					end if;
				end if;				
			when  set_securite_sense =>		-- Affectation du sense maximum possible, si ce max est dépasé, on stop le PWM/Moteur
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					sense_max <= tmp;
				else
					tmp := x"0000";
				end if;
			when set_maxspeed =>		-- Affectation de la valeur maximal du bfm mesuré
				if ( byte_count = 0) then
					tmp := x"0000";
					tmp := copyLeft(tmp, data_in);
				elsif ( byte_count = 1) then
					tmp := copyRight( tmp, data_in );
					bfm_max <= tmp;
				else
					tmp := x"0000";
				end if;
			
			when set_kpkikd =>		-- Affectation des coefficient pour le calcul du PID
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
				cpmt_fuse := x"00";
				byte_count := 6;	-- On met la valeur maximal, comme ca, le test va rectifier la valeur et mettre 0
			when get_param0 =>
				send_data := 1;
			when get_param1 =>
				send_data := 2;			
			when others =>		-- Tout les autres cas, prevu ou non
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
		-- ===============TX FSM=========================

			if ( send_data /= 0 ) then		-- Des données sont à envoyer; Get_param0
				if ( send_data = 1 ) then		-- Des données sont à envoyer; Get_param0
					use_tx_data_chain_out <= '1';
					case byte_count_tx is
						when 0 =>
							tx_data_chain_out_intern :=  conv_to_addresse( component_id );
						when 1 =>
							tx_data_chain_out_intern := x"50";
						when 2 =>
							tx_data_chain_out_intern := sense_value(15 downto 8);
						when 3 =>
							tx_data_chain_out_intern := sense_value(7 downto 0);
						when 4 =>
							tx_data_chain_out_intern := captor_value(15 downto 8);
						when 5 =>
							tx_data_chain_out_intern := captor_value(7 downto 0);
						when 6 =>
							tx_data_chain_out_intern := order(15 downto 8);
						when 7 =>
							tx_data_chain_out_intern := order(7 downto 0);
						when 8 =>
							tx_data_chain_out_intern := command_intern ;
						when 9 =>
							tx_data_chain_out_intern := cpmt_fuse ;	
							send_data := 3;		-- envoyer chk
						when others =>
							tx_data_chain_out_intern := x"00";
							send_data := 0;
						end case;
					if ( byte_count_tx < 9 ) then 
						byte_count_tx := byte_count_tx +1;
					else
						byte_count_tx := 0;
					end if; 
				elsif ( send_data = 2 ) then		-- Get_param1
					use_tx_data_chain_out <= '1';
					case byte_count_tx is
						when 0 =>
							tx_data_chain_out_intern :=  conv_to_addresse( component_id );
						when 1 =>
							tx_data_chain_out_intern := x"51";
						when 2 =>
							tx_data_chain_out_intern := Kp;
						when 3 =>
							tx_data_chain_out_intern := Ki;
						when 4 =>
							tx_data_chain_out_intern := Kd;
						when 5 =>
							tx_data_chain_out_intern := sense_max(15 downto 8);
						when 6 =>
							tx_data_chain_out_intern := sense_max(7 downto 0);
						when 7 =>
							tx_data_chain_out_intern := x"DE" ;	
						when 8 =>
							tx_data_chain_out_intern := x"AD" ;	
							send_data := 0;
						when others =>
							tx_data_chain_out_intern := x"00";
							send_data := 3;
						end case;
					if ( byte_count_tx < 8 ) then 
						byte_count_tx := byte_count_tx +1;
					else
						byte_count_tx := 0;
					end if;
				elsif ( send_data = 3 ) then
					tx_data_chain_out_intern := chk ;	-- Envoyer CHK !
					send_data := 0 ;
				end if;		-- end send_data = 1 or 2
				chk := chk XOR tx_data_chain_out_intern;
				-- l'affectation de send_data se fait dans le 'case' get_param[0|1]; le reset se fait a la fin du TX FSM 
			else	-- send_data = 0
				chk := x"00";
				tx_data_chain_out_intern := x"00";
				use_tx_data_chain_out <= '0' ;
			end if;--end if ( send != 0 )

		-- La tension est elle trop forte ?
		if ( sense_value > sense_max ) then
			order <= x"0000";
			cpmt_fuse := cpmt_fuse + 1 ;
			if ( cpmt_fuse >= x"FB" ) then
				cpmt_fuse := x"FA";
			end if;
			enable_motor <= '0';
		end if;

	tx_data_chain_out <= tx_data_chain_out_intern;
	end if; -- end of rising-edge
	
end process;


end behavioral;







