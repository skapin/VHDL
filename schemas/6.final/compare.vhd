--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: compare.vhd
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

entity compare is
  port (a   : in  std_logic_vector( 7 downto 0 );
        b   : in  std_logic_vector(7 downto 0 );
        eq  : out std_logic);
end compare;

architecture behavioral of compare is

  begin
    eq <= '1' when (a = b) else
          '0';
  end behavioral;
