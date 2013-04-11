--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: pwm_motor.vhd
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


entity pwm_motor is
port (
	d : IN std_logic_vector( 7 downto 0 );
	clk : IN std_logic; 
	enable : IN std_logic;
	pwma : OUT std_logic;
	pwmb : OUT std_logic;
	ea : OUT std_logic;
	eb : OUT std_logic
);
end pwm_motor;

architecture behavioral of pwm_motor is 

	signal pwm_intern : std_logic := '0';
	component motor_controler
	port (
		clk : IN std_logic;
		enable : IN std_logic;
		pwm_in : IN std_logic;
		pwm_a : OUT std_logic;
		pwm_b : OUT std_logic;
		enable_a : OUT std_logic;
		enable_b : OUT std_logic);
	end component;

	component pwm
	port (
	    d : IN std_logic_vector( 7 downto 0 );
		clk : IN std_logic; 
		clr : in std_logic;
		pwm : out std_logic);
	end component;
begin
	pwm_1 : pwm port map( d , clk, '0', pwm_intern);
	motor_1 : motor_controler port map ( clk, enable,  pwm_intern, pwma, pwmb, ea, eb );
end behavioral;
