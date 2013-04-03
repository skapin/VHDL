--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: motor_controler.vhd
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

entity motor_controler is
port (
	clk : IN std_logic;
	enable : IN std_logic;
	pwm_in : IN std_logic;
	pwm_a : OUT std_logic;
	pwm_b : OUT std_logic;
	enable_a : OUT std_logic;
	enable_b : OUT std_logic
);
end motor_controler;

-- State  :  0=Reset , 1=PwmA, 2=PwmB, others
architecture behavioral of motor_controler is   
signal state : integer := 0;  
begin
	process (clk)

	variable enable_activation_time : integer :=0;
	constant compute_delay : integer := 10; --Minimum time before send the PWM signal (allow the CMOS to compute H-brige)
	begin
	if ( rising_edge ( clk) ) then
		-- Reset state 
		if ( enable = '1' ) then
			if ( state = 0 ) then
					pwm_a <= '0';
					pwm_b <= '0';
					enable_a <= '0';
					enable_b <= '0';
					enable_activation_time := 0;
					state <= 1;
			elsif ( state = 1 ) then			
					if ( enable_activation_time < compute_delay ) then
						pwm_a <= '0';
						pwm_b <= '0';
						enable_a <= '0';
						enable_b <= '1';
						enable_activation_time := enable_activation_time +1;
					else
						pwm_a <= pwm_in;
						pwm_b <= '0';
						enable_a <= '0';
						enable_b <= '1';			
					end if;
			else
					state <= 0;
					pwm_a <= '0';
					pwm_b <= '0';
					enable_a <= '0';
					enable_b <= '0';
					enable_activation_time := 0;
			end if;
		else
			state <= 0;
			pwm_a <= '0';
			pwm_b <= '0';
			enable_a <= '0';
			enable_b <= '0';
		end if; -- enable = 1 ?
	end if;
	end process;


end behavioral;
