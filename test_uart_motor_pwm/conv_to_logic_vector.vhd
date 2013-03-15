--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: conv_to_logic_vector.vhd
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

entity conv_to_logic_vector is
port (
	input : IN std_logic;
	output : OUT std_logic_vector( 7 downto 0)
);
end conv_to_logic_vector;

architecture beh of conv_to_logic_vector is

begin
	output <= conv_std_logic_vector(input,8);
end beh;