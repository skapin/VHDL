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

	pwm_a_m1 : OUT std_logic;
	enable_a_m1 : OUT std_logic;
	pwm_b_m1 : OUT std_logic;
	enable_b_m1 : OUT std_logic;
	isV12_m1 : OUT std_logic

);
end uart_to_motor;


architecture behavioral of uart_to_motor is 
signal data_rx : std_logic_vector ( 7 downto 0) :=x"00";
signal data_rx_ready : std_logic := '0' ;
signal data_byte : std_logic_vector (7 downto 0) := x"00";
signal addresses : std_logic_vector ( 3 downto 0):= x"0";
signal actions : std_logic_vector ( 3 downto 0):= x"0";
signal captor_value_m1 : std_logic_vector( 15 downto 0 ) :=x"0000";
signal sense_value_m1 : std_logic_vector ( 15 downto 0 ) := x"0000";

signal command_m1 : std_logic_vector( 7 downto 0) := x"00" ;
signal direct_m1: std_logic := '0' ;
signal enable_m1 : std_logic := '0' ;
signal use_tx_chain_m1 : std_logic := '0';
signal tx_chain_m1 : std_logic_vector( 7 downto 0) := x"00";
signal tx_chaine_all : std_logic_vector( 7 downto 0) := x"00";
signal byte_to_send : std_logic_vector( 7 downto 0) := x"00";
signal enable_tx : std_logic :='0';
signal tx_busy : std_logic;

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

component uart_rx
port (
	clk : IN std_logic; 	-- FPGA clock
	rx : IN std_logic;		-- RX link
	data : OUT std_logic_vector (7 downto 0);
	data_ready : OUT std_logic
);
end component;

component frame_controller
port (
	clk : IN std_logic; 	-- FPGA clock
	data_ready : IN std_logic;
	data_in : IN std_logic_vector (7 downto 0);
	data_out : OUT std_logic_vector (7 downto 0);
	addresses : OUT std_logic_vector ( 3 downto 0);
	actions : OUT std_logic_vector ( 3 downto 0)
);
end component;
component controller
port (
	clk : IN std_logic; 	-- FPGA clock
	data_in : IN std_logic_vector (7 downto 0);
	addresses : IN std_logic_vector (3 downto 0);
	actions : IN std_logic_vector (3 downto 0);
	component_id : IN std_logic_vector (3 downto 0); 		-- Better if Generic MAP, check this dude.
	captor_value : IN std_logic_vector ( 15 downto 0 );	-- Bfm
	sense_value : IN std_logic_vector ( 15 downto 0 );	-- sense 
	tx_data_chain_out : OUT std_logic_vector(7 downto 0);
	use_tx_data_chain_in : IN std_logic;
	use_tx_data_chain_out : OUT std_logic;
	command : OUT std_logic_vector(7 downto 0);
	direction : OUT std_logic;
	enable_motor : OUT std_logic;
	is_v12 : OUT std_logic
);
end component;

component tx_buffer
port (
	clk : IN std_logic;
	data_in : IN std_logic_vector( 7 downto 0 );
	send_data : IN std_logic;
	tx_ready : IN std_logic;
	data_out : OUT std_logic_vector( 7 downto 0 );
	enable_tx : OUT std_logic
);
end component;

component uart_tx
port (
	clk : IN std_logic; 	-- FPGA clock
	data : IN std_logic_vector (7 downto 0);
	enable : IN std_logic;
	tx : OUT std_logic;		-- TX link
	ready : OUT std_logic
);
end component;

begin	
	--conv : conv_to_logic_vector port map ( sense, sense_vector );

	-- ===============Logic elementaires
	tx_chaine_all <= tx_chain_m1;		--Resultat des TX des differents controller. 1 seul peut etr eutilisé a la fois grace a use_tx_data_chain. ( systeme de jeton )

	-- ===============Composants
	uartrx : uart_rx port map ( clk, rx, data_rx, data_rx_ready);
	uarttx : uart_tx port map ( clk, tx_chaine_all, enable_tx, tx, tx_busy);

	framecontroller : frame_controller port map( clk, data_rx_ready, data_rx, data_byte, addresses, actions );
	txbuffer : tx_buffer port map( clk, tx_chaine_all, use_tx_chain_m1, tx_busy, byte_to_send, enable_tx );

	controller_1 : controller port map( clk, data_byte, addresses, actions, b"0010", captor_value_m1, sense_value_m1, tx_chain_m1, '0', use_tx_chain_m1 , command_m1, direct_m1, enable_m1, isV12_m1 );
	pwmmotor : pwm_motor port map ( command_m1, clk, enable_m1, pwm_a_m1, pwm_b_m1, enable_a_m1, enable_b_m1 );


end behavioral;
