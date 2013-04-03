--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: uart_to_motor.vhd
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
use IEEE.STD_LOGIC_ARITH.all;


entity uart_to_motor is
port (
	clk : IN std_logic;
	rx : IN std_logic;
	enable_motor : IN std_logic;
	tx : OUT std_logic;
	pwm_a : OUT std_logic;
	enable_a : OUT std_logic;
	pwm_b : OUT std_logic;
	enable_b : OUT std_logic
);
end uart_to_motor;


architecture behavioral of uart_to_motor is 
signal pwm_intern : std_logic_vector ( 7 downto 0) :=x"00";
signal sense_vector : std_logic_vector( 7 downto 0 ) :=x"4D";
signal tx_busy :std_logic ;
signal send : std_logic :='1';
component pwm_motor
	port (
		d : IN std_logic_vector( 7 downto 0 );
		clk : IN std_logic; 
		enable : IN std_logic;
		pwma : OUT std_logic;
		pwmb : OUT std_logic;
		ea : OUT std_logic;
		eb : OUT std_logic
	);
end component;

component uart_controler
	port (
		clk : IN std_logic; 	
		rx : IN std_logic;		
		rx_buffer : OUT std_logic_vector (7 downto 0);
		tx : OUT std_logic;
	--	tx_buffer : IN std_logic_vector (7 downto 0);
		enable_tx : IN std_logic;	
		tx_busy: OUT std_logic
	);
end component;
component conv_to_logic_vector
port (
	input : IN std_logic;
	output : OUT std_logic_vector( 7 downto 0)
);
end component;
begin	
	--conv : conv_to_logic_vector port map ( sense, sense_vector );
	uart : uart_controler port map ( clk, rx, pwm_intern, tx, '1', tx_busy );
	pwmmotor : pwm_motor port map ( pwm_intern, clk, enable_motor, pwm_a, pwm_b, enable_a, enable_b );


end behavioral;
