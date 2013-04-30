--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: adc16b.vhd
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

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: timer16b.vhd
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

entity adc16b is
  port (clk : IN  std_logic;
		pwm : IN  std_logic;
        d   : OUT std_logic_vector(15 downto 0));
end adc16b;

architecture behavioral of adc16b is

  begin
    process (clk)
	variable intern : std_logic_vector(15 downto 0) :=x"0000";
	variable pwm_prev : std_logic := '0';
    begin
      if (rising_edge(clk)) then
		if ( pwm='1' and pwm_prev='0' ) then
			intern := x"0000";
		elsif ( pwm='1' ) then
			intern := intern + 1;
		else
			d <= intern;
		end if;
		pwm_prev := pwm;
      end if;
    end process;
  end behavioral;