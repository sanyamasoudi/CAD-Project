library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity alu is
    Port ( clk_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           rM_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           rN_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           imm_data_in : in STD_LOGIC_VECTOR (7 downto 0);
           result_out : out STD_LOGIC_VECTOR (15 downto 0);
           branch_out : out STD_LOGIC;
           rD_write_enable_in : in STD_LOGIC;
           rD_write_enable_out : out STD_LOGIC);
end alu;


architecture Behavioral of alu is
    signal bpositive_signal : STD_LOGIC;
    signal bnegative_signal : STD_LOGIC;  
    signal signed_add_signal : STD_LOGIC_VECTOR (15 downto 0);
    signal signed_sub_signal : STD_LOGIC_VECTOR (15 downto 0);
    signal overflow_signal : STD_LOGIC;
     
begin 
	
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if enable_in='1' then  
				
	            signed_add_signal <= STD_LOGIC_VECTOR(signed(rM_data_in) + signed(rN_data_in)); 
			   signed_sub_signal <= STD_LOGIC_VECTOR(signed(rM_data_in) - signed(rN_data_in));           
			   rD_write_enable_out <= rD_write_enable_in;
	            
	
	            if rM_data_in(rM_data_in'left) = '0' and rN_data_in(rN_data_in'left) = '0' then
	                bpositive_signal <= '1';
	            else
	                bpositive_signal <= '0';
	            end if;
	
	            if rM_data_in(rM_data_in'left) = '1' and rN_data_in(rN_data_in'left) = '1' then
	                bnegative_signal <= '1';
	            else
	                bnegative_signal <= '0';
	            end if;
	
	            if (signed(signed_add_signal) < 0 and bpositive_signal = '1') or (signed(signed_add_signal) > 0 and bnegative_signal = '1') then
	                overflow_signal <= '1';
	            else
	                overflow_signal <= '0';
	            end if;
				
				
				
	            case alu_op_in(3 downto 0) is 
	               -- ADD
	                when "0000" => 
	                    if alu_op_in(4) = '1' then
	                        if overflow_signal = '1' then
	                            result_out <= signed_add_signal;
	                        else
	                            result_out <= signed_add_signal;
	                     end if;    
	                    else
	                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) + unsigned(rN_data_in));
	                    end if;
	                    branch_out <= '0';
						
				  -- SUB
	                when "0001" => 
	                    if alu_op_in(4) = '1' then
	                        if overflow_signal = '1' then
	                            result_out <= signed_sub_signal;
	                        else
	                            result_out <= signed_sub_signal;
	                        end if;
	                    else
	                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) - unsigned(rN_data_in));
	                    end if;		
	                    branch_out <= '0'; 
						
	                -- NOT    
	                when "0010" => 
	                    result_out <= not rM_data_in;
	                    branch_out <= '0';
						
	                -- AND    
	                when "0011" =>
	                    result_out <= rM_data_in and rN_data_in;
	                    branch_out <= '0';
						
	                -- OR  
	                when "0100" =>
	                    result_out <= rM_data_in or rN_data_in;
	                    branch_out <= '0';
						
	                -- XOR   
	                when "0101" =>	
	                    result_out <= rM_data_in xor rN_data_in;
	                    branch_out <= '0';	
						
	                -- LSR    
	                when "0110" =>
	                    result_out <= STD_LOGIC_VECTOR(shift_left(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
	                    branch_out <= '0'; 
						
	                -- LSL  
	                when "0111" => 
	                    result_out <= STD_LOGIC_VECTOR(shift_right(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
	                    branch_out <= '0'; 
						
	                -- CMP    
	                when "1000" => 
	                    -- negative bit
	                    if alu_op_in(4) = '1' and signed(signed_sub_signal) < 0 then
	                        result_out(15) <= '1';
	                    else
	                        result_out(15) <= '0';
	                    end if;
	                    -- zero bit
	                    if unsigned(rM_data_in) - unsigned(rN_data_in) = 0 then
	                        result_out(14) <= '1';
	                    else 
	                        result_out(14) <= '0';
	                    end if;
	                    -- carry bit
	                    if alu_op_in(4) = '0' and unsigned(rM_data_in) - unsigned(rN_data_in) > unsigned(rM_data_in) + unsigned(rN_data_in) then
	                        result_out(13) <= '1';
	                    else
	                        result_out(13) <= '0';
	                    end if;
	                    -- overflow bit
	                    if alu_op_in(4) = '1' and overflow_signal ='1' then
	                        result_out(12) <= '1';
	                    else
	                        result_out(12) <= '0';
	                    end if;
	                    
	                    result_out(11 downto 0) <= x"000";
	                    branch_out <= '0';
						
	                -- B    
	                when "1001" => 
	                    if alu_op_in(4) = '1' then
	                        result_out <= x"00" & imm_data_in;
	                    else
	                        result_out <= rM_data_in;
	                    end if;
	                    branch_out <= '1';
						
	                -- BEQ    
	                when "1010" => 
	                    if rN_data_in(14) = '1' then
	                        result_out <= rM_data_in;
	                        branch_out <= '1';
	                    else
	                        branch_out <= '0';
	                    end if;
	                 
				  -- IMMEDIATE		
	                when "1011" => 
	                    if alu_op_in(4) = '1' then
	                        result_out <= imm_data_in & x"00";
	                    else
	                        result_out <= x"00" & imm_data_in;
	                    end if;
	                    branch_out <= '0';
	                
				  -- LD
	                when "1100" =>
	                    result_out <= rM_data_in;
	                    branch_out <= '0';	 
						
	                -- ST   
	                when "1101" => 
	                    result_out <= rM_data_in;
	                    branch_out <= '0';
	                    
	                when others =>
	                    NULL;
	            end case; 
		 end if; 
        end if;                                           
    end process;


end Behavioral;
