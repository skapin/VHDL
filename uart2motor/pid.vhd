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


--
--
--	TRANSFORMER PID.VHD EN FONCTION !!!!!!
--
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;   

entity pid is
port (
    clk : IN std_logic;
    order : IN std_logic_vector(15 downto 0);
    captor_value : IN std_logic_vector(15 downto 0);
	enable_pid : IN std_logic;	-- if '0', command = order = pwm,
	Ki : IN std_logic_vector( 7 downto 0 );
	Kp : IN std_logic_vector( 7 downto 0 );
	Kd : IN std_logic_vector( 7 downto 0 );
	BFM_max : IN std_logic_vector( 15 downto 0 );
	command : OUT std_logic_vector (7 downto 0);
	direct : OUT std_logic
);
end pid;

architecture behavioral of pid is 
begin
	process (clk)
	variable error, error_prev : signed(15 downto 0) := x"0000";
	variable p, i, d : signed(23 downto 0) := x"000000";
	variable tmp16 : signed(15 downto 0) := x"0000";
	variable command_intern : signed(31 downto 0) := x"00000000";
	variable BFM_16 : signed(15 downto 0) := x"0000";
	variable pid : signed(23 downto 0 ) := x"000000";
	begin
		if ( rising_edge( clk ) ) then
			if ( enable_pid = '1' ) then	-- Calcul du PID necessaire
				command_intern := signed(BFM_max) * signed(order);
				BFM_16 := command_intern( 23 downto 8 ); -- COPIER LES Octets [1] [2] (de 0..3)
				error_prev := error;
				error :=  BFM_16 - signed(captor_value) ;
				p := signed( signed(Kp) * error);
				i := signed( signed(Kp) * ( error - error_prev ));
				d := signed(signed(Kd) * ( error - error_prev ));
	
				pid := (p + i + d) ; 

--				pid := pid / 1024;
				if ( pid >= 0 ) then
					pid( 13 downto 0) := pid ( 23 downto 10 );
					pid( 23 downto 14 ) := b"0000000000" ;
				else
					pid( 13 downto 0) := pid ( 23 downto 10 );
					pid( 23 downto 14 ) := b"1111111111" ;
				end if;
--   / 1024;
				-- on born le PID calculé. Celui-ci ne doti PAS depasser 255 (8bits)
				if ( pid > 255 ) then
					direct <= '1';
					command <= x"FF";
				elsif ( pid < -255 ) then
					direct <= '0';
					command <= x"FF";
					command(0) <= pid(0);
					command(1) <= pid(1);
					command(2) <= pid(2);
					command(3) <= pid(3);
					command(4) <= pid(4);
					command(5) <= pid(5);
					command(6) <= pid(6);
					command(7) <= pid(7);
				elsif ( pid < 0 ) then
					pid := - pid;
					direct <= '0';
					command(0) <= pid(0);
					command(1) <= pid(1);
					command(2) <= pid(2);
					command(3) <= pid(3);
					command(4) <= pid(4);
					command(5) <= pid(5);
					command(6) <= pid(6);
					command(7) <= pid(7);
				else
					direct <= '1';
					command(0) <= pid(0);
					command(1) <= pid(1);
					command(2) <= pid(2);
					command(3) <= pid(3);
					command(4) <= pid(4);
					command(5) <= pid(5);
					command(6) <= pid(6);
					command(7) <= pid(7);
			--		command <= command_intern ( 7 downto 0 );
				end if;
			else
				if ( order(15) = '1' ) then	-- Si le nombre est negatif
				--tmp16 := order xor x"FFFF";	-- On fait *(-1)
					tmp16 := signed(order);-- * (-1);-- x"01";
					tmp16 := -tmp16;
					direct <= '0';
				else
					direct <= '1';
					tmp16 := signed(order);
				end if ;
					command(0) <= tmp16(0);
					command(1) <= tmp16(1);
					command(2) <= tmp16(2);
					command(3) <= tmp16(3);
					command(4) <= tmp16(4);
					command(5) <= tmp16(5);
					command(6) <= tmp16(6);
					command(7) <= tmp16(7);
				-- Le PWM calculé ou prit en parametre est entre 0 et 255 apres mise a valeur positive
				--command <= tmp16 ( 7 downto 0);
			end if;
		end if; -- end rising edge
	end process;
	
	
	
end behavioral;

