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

entity timer8b is
  port (clr : in  std_logic;
        clk : in  std_logic;
        q   : out std_logic_vector(7 downto 0));
end timer8b;

architecture behavioral of timer8b is

  signal internal : std_logic_vector(7 downto 0) :=x"00";

  begin
    process (clr, clk)
    begin
      if (clr = '1') then
        internal <= (others => '0');
      elsif (rising_edge(clk)) then
        internal <= internal + 1;
      end if;
    end process;
    q <= internal;
  end behavioral;