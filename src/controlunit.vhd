library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controlunit is
	port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           stage_out : out STD_LOGIC_VECTOR (5 downto 0));
end controlunit;			

architecture Behavioral of controlunit is  
	  signal stage_out_signal : STD_LOGIC_VECTOR (5 downto 0) := "000001";
begin  
	
	process (clk_in)		
	begin  	
		
		if rising_edge (clk_in) then   	
			if reset_in = '1' then
				stage_out_signal <="000001";
			else
				case stage_out_signal is
					when "000001" =>
						stage_out_signal <="000010";
					when "000010" =>
						stage_out_signal <="000100";
					when "000100" =>
						stage_out_signal <="001000";
					when "001000" =>
	                        if alu_op_in(3 downto 0) = "1100" or alu_op_in(3 downto 0) = "1101" then 
	                            stage_out_signal <= "010000";
	                        else
	                            stage_out_signal <= "100000";
	                        end if;
					when "010000" =>
						stage_out_signal <="100000";
					when "100000" =>
						stage_out_signal <="000001";
					when others =>
						stage_out_signal <="000001";
				end case; 
			end if;	 
	    end if;	
		
	end process;
	
	stage_out <=  stage_out_signal;
	
end Behavioral;