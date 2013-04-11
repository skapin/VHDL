
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
package frame_controller_fsm is
type Action
is (	noone, set_pid, set_pwm, set_stop, 
		set_v_moteurs,	set_securite_sense, set_maxspeed,
		set_kpkikd,set_reboot,get_param0, get_param1);

function get_addresse( data_in: std_logic_vector (7 downto 0))  return std_logic_vector;
function get_action( data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector;
function conv2Action( data_in: std_logic_vector( 3 downto 0 ))  return Action;
function copyLeft( value: std_logic_vector( 15 downto 0 ); data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector;
function copyRight( value: std_logic_vector( 15 downto 0 ); data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector;
function conv_to_addresse( data_in: std_logic_vector( 3 downto 0 ))  return std_logic_vector ;
end frame_controller_fsm;


package body frame_controller_fsm is 


function copyLeft( value: std_logic_vector( 15 downto 0 ); data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector is 
variable result : std_logic_vector( 15 downto 0);
begin
	result := value;
	result(8) := data_in(0);
	result(9) := data_in(1);
	result(10) := data_in(2);
	result(11) := data_in(3);
	result(12) := data_in(4);
	result(13) := data_in(5);
	result(14) := data_in(6);
	result(15) := data_in(7);
	return result;
end function copyLeft;
function copyRight( value: std_logic_vector( 15 downto 0 ); data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector is
variable result : std_logic_vector( 15 downto 0);
begin
	result := value;
	result(0) := data_in(0);
	result(1) := data_in(1);
	result(2) := data_in(2);
	result(3) := data_in(3);
	result(4) := data_in(4);
	result(5) := data_in(5);
	result(6) := data_in(6);
	result(7) := data_in(7);
	return result;
end function copyRight;

function get_addresse( data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector is
begin
if ( data_in =  x"47") then 
	return b"0010";
elsif ( data_in = x"48" ) then 
	return b"0011";
elsif ( data_in = x"49" ) then 
	return b"0100";
elsif ( data_in = x"4A" ) then 
	return b"0101";
elsif ( data_in = x"4B" ) then 
	return b"1100";
elsif ( data_in = x"4C" ) then 
	return b"1101";
elsif ( data_in = x"4D" ) then 
	return b"1110";
elsif ( data_in = x"4E" ) then 
	return b"1111";
elsif ( data_in = x"4F" ) then 
	return b"1000";
elsif ( data_in = x"50") then 
	return b"1001" ;
elsif ( data_in = x"2D") then 
	return b"0000" ;
else 
	return b"0000" ;		
end if;
end function get_addresse;

function conv_to_addresse( data_in: std_logic_vector( 3 downto 0 ))  return std_logic_vector is
begin
if ( data_in = b"0010") then 
	return  x"47";
elsif ( data_in = b"0011" ) then 
	return x"48";
elsif ( data_in = b"0100" ) then 
	return x"49";
elsif ( data_in = b"0101" ) then 
	return x"4A";
elsif ( data_in = b"1100" ) then 
	return x"4B";
elsif ( data_in = b"1101" ) then 
	return x"4C";
elsif ( data_in = b"1110" ) then 
	return x"4D" ;
elsif ( data_in = b"1111" ) then 
	return x"4E";
elsif ( data_in = b"1000" ) then 
	return x"4F";
elsif ( data_in = b"1001" ) then 
	return x"50" ;
elsif ( data_in = b"0000" ) then 
	return x"2D" ;
else 
	return x"00" ;		
end if;
end function conv_to_addresse;

function get_action( data_in: std_logic_vector( 7 downto 0 ))  return std_logic_vector is
begin
if ( data_in =  x"01") then 
	return b"0010";
elsif ( data_in = x"02" ) then 
	return b"0011";
elsif ( data_in = x"04" ) then 
	return b"0100";
elsif ( data_in = x"55" ) then 
	return b"0101";
elsif ( data_in = x"58" ) then 
	return b"0110";
elsif ( data_in = x"57" ) then 
	return b"0111";
elsif ( data_in = x"53" ) then 
	return b"1100";
elsif ( data_in = x"5A" ) then 
	return b"1111";
elsif ( data_in = x"50" ) then 
	return b"1000";
elsif ( data_in = x"54") then 
	return b"1001" ;
else 
	return b"0000" ;		
end if;

end function get_action;

function conv2Action( data_in: std_logic_vector( 3 downto 0 ))  return Action is 
begin

if ( data_in =  b"0010") then 
	return set_pid;
elsif ( data_in = b"0011") then 
	return set_pwm;
elsif ( data_in = b"0100") then 
	return set_stop;
elsif ( data_in = b"0101") then 
	return set_v_moteurs;
elsif ( data_in = b"0110") then 
	return set_securite_sense;
elsif ( data_in = b"0111" ) then 
	return set_maxspeed;
elsif ( data_in = b"1100" ) then 
	return set_kpkikd;
elsif ( data_in = b"1111" ) then 
	return set_reboot;
elsif ( data_in = b"1000" ) then 
	return get_param0;
elsif ( data_in = b"1001") then 
	return get_param1  ;
else 
	return noone ;		
end if;
end function;

end frame_controller_fsm;
