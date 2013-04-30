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
	tx : OUT std_logic;
	reset_rx : IN std_logic;
	active_controller : IN std_logic;
	activate : OUT std_logic;


	--clk_captor_m1 : IN std_logic;
	--pwm_captor_m1 : IN std_logic;
	pwm_a_m1 : OUT std_logic;
	enable_a_m1 : OUT std_logic;
	pwm_b_m1 : OUT std_logic;
	enable_b_m1 : OUT std_logic;
	isV12_m1 : OUT std_logic
--  pwm_a_m2 : OUT std_logic;
--	enable_a_m2 : OUT std_logic;
--	pwm_b_m2 : OUT std_logic;
--	enable_b_m2 : OUT std_logic;
--	isV12_m2 : OUT std_logic

);
end uart_to_motor;


architecture behavioral of uart_to_motor is 
signal data_rx : std_logic_vector ( 7 downto 0) :=x"00";
signal data_rx_ready : std_logic := '0' ;
signal data_byte : std_logic_vector (7 downto 0) := x"00";
signal addresses : std_logic_vector ( 3 downto 0):= x"0";
signal actions : std_logic_vector ( 3 downto 0):= x"0";

signal captor_value_m1 : std_logic_vector( 15 downto 0 ) :=x"0004";
signal sense_value_m1 : std_logic_vector ( 15 downto 0 ) := x"0FF0";
signal command_m1 : std_logic_vector( 7 downto 0) := x"00" ;
signal direct_m1: std_logic := '0' ;
signal enable_m1 : std_logic := '0' ;
signal use_tx_chain_m1 : std_logic := '0';
signal tx_chain_m1 : std_logic_vector( 7 downto 0) := x"00";

signal captor_value_m2 : std_logic_vector( 15 downto 0 ) :=x"0000";
signal sense_value_m2 : std_logic_vector ( 15 downto 0 ) := x"0000";
signal command_m2 : std_logic_vector( 7 downto 0) := x"00" ;
signal direct_m2: std_logic := '0' ;
signal enable_m2 : std_logic := '0' ;
signal use_tx_chain_m2 : std_logic := '0';
signal tx_chain_m2 : std_logic_vector( 7 downto 0) := x"00";


signal use_tx_chain_all : std_logic := '0';
signal tx_chaine_all : std_logic_vector( 7 downto 0) := x"00";
signal byte_to_send : std_logic_vector( 7 downto 0) := x"00";
signal enable_tx : std_logic :='0';
signal tx_ready : std_logic;
signal trash: std_logic;

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
	data_ready : OUT std_logic;
	rst : in std_logic
);
end component;

component frame_controller
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
end component;
component controller
port (
	clk : IN std_logic; 	-- FPGA clock
	activate : IN std_logic;
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

component adc16b 
  port (clk : IN  std_logic;
		pwm : IN  std_logic;
        d   : OUT std_logic_vector(15 downto 0));
end component;
begin	
	--conv : conv_to_logic_vector port map ( sense, sense_vector );

	-- ===============Logic elementaires
	tx_chaine_all <= tx_chain_m1 OR tx_chain_m2;		--Resultat des TX des differents controller. 1 seul peut etr eutilisé a la fois grace a use_tx_data_chain. ( systeme de jeton )
	use_tx_chain_all <= use_tx_chain_m1 OR use_tx_chain_m2;
	-- ===============Composants
	uartrx : uart_rx port map ( clk, rx, data_rx, data_rx_ready, reset_rx);
	--uarttx : uart_tx port map ( clk, data_rx, data_rx_ready, tx, tx_ready);
	uarttx : uart_tx port map ( clk, byte_to_send, enable_tx, tx, tx_ready);

	framecontroller : frame_controller port map( clk, data_rx_ready, data_rx, data_byte, addresses, actions, reset_rx, trash );


--	captor_value : adc16b port map( clk_captor_m1, pwm_captor_m1, captor_value_m1);
	controller_1 : controller port map( clk, active_controller, data_byte, addresses, actions, b"0010", captor_value_m1, sense_value_m1, tx_chain_m1, use_tx_chain_m1 , command_m1, direct_m1, enable_m1, isV12_m1 );
	--controller_2 : controller port map( clk, data_byte, addresses, actions, b"0011", captor_value_m2, sense_value_m2, tx_chain_m2, use_tx_chain_m2 , command_m2, direct_m2, enable_m2, isV12_m2 );

	txbuffer : tx_buffer port map( clk, tx_chaine_all, use_tx_chain_all, tx_ready, byte_to_send, enable_tx );
	pwmmotor_1 : pwm_motor port map ( command_m1, clk, enable_m1, pwm_a_m1, pwm_b_m1, enable_a_m1, enable_b_m1 );
	--pwmmotor_2 : pwm_motor port map ( command_m2, clk, enable_m2, pwm_a_m2, pwm_b_m2, enable_a_m2, enable_b_m2 );


end behavioral;
