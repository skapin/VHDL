
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pwm is
port (
    d : IN std_logic_vector( 7 downto 0 );
	clk : IN std_logic; 
	clr : in std_logic;
	pwm : out std_logic);
end pwm;


architecture behavioral of pwm is 
	signal intern : std_logic_vector(7 downto 0);
	signal cmp_flag : std_logic;
	signal zero_flag : std_logic;
	component timer8b 
	  port (clr : in  std_logic;
    	    clk : in  std_logic;
        	q   : out std_logic_vector(7 downto 0));
	end component;

	component rs
	  port (clr : in  std_logic;
        clk : in  std_logic;
        s   : in  std_logic;
        r   : in  std_logic;
        q   : out std_logic);
	end component;

	component compare
	  port (a   : in  std_logic_vector(7 downto 0);
    		  b   : in  std_logic_vector(7 downto 0);
       		 eq  : out std_logic);
	end component;

	begin

	incr_timer : timer8b port map ( clr, clk, intern );
	eq : compare port map( intern, d, cmp_flag );
	eqz : compare port map( intern, x"00", zero_flag );
	rss : rs port map( clr, clk, zero_flag, cmp_flag, pwm );

end behavioral;


	

