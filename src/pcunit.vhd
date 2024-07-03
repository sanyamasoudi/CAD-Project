library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pcunit is
    port ( clk_in : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           pc_out : out STD_LOGIC_VECTOR (15 downto 0));
end pcunit;			

architecture Behavioral of pcunit is
	signal pc_out_signal : STD_LOGIC_VECTOR (15 downto 0) := x"0000";	

begin  
	
    process (clk_in)
    begin	
		
        if rising_edge(clk_in) then	
			
            case pc_op_in is
                when "00" =>
				 pc_out_signal <= x"0000";  
                when "01" => 
                    pc_out_signal <= STD_LOGIC_VECTOR(unsigned(pc_out_signal) + 1);
                when "10" =>
                    pc_out_signal <= pc_in;
                when "11" => 
                when others =>
            end case;
			
        end if;	
		
    end process;
    
    pc_out <= pc_out_signal;
	
end Behavioral;