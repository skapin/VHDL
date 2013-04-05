--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: pid.vhd
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

entity pid is
port (
    order : IN std_logic_vector(15 downto 0);
	enable_pid : IN std_logic;	-- if '0', command = order = pwm,
    rotation_way : IN std_logic;
    clk : IN std_logic;
    clr : IN std_logic;
	command : OUT std_logic_vector (15 downto 0);
	Ki : IN integer
);
end pid;

architecture behavioral of pid is 
	signal Kp : std_logic := 7;
	signal Ki : std_logic := 5;
	signal Kd : std_logic := 10;
begin

	process (clr, clk)
	variable : error, error_prev :=0;
	variable : p, i, d :=0;
	variable : command_intern range 0 to x"ffff":=0;	
	begin

		if ( clr = '1' ) then
			error := 0;
			error_prev := 0;
			p := 0; i := 0; d :=0;
			command_intern := 0;
		elsif ( rising_edge( clk ) ) then
			error_prev := error;
			error :=  conv_integer(order) - sens ;
			p := Kp * error;
			i := Kp * ( error - error_prev );
			d := Kd * ( error - error_prev );

			command_intern <= (p + i + d) ; 
			command <= conv_std_logic_vector(command_intern ,16);
	
		end if; -- end rising edge
	end process;
	
	
	
end behavioral

