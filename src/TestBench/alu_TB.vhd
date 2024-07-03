library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity alu_tb is
end alu_tb;

architecture TB_ARCHITECTURE of alu_tb is
	-- Component declaration of the tested unit
	component alu
	port(
		clk_in : in STD_LOGIC;
		enable_in : in STD_LOGIC;
		alu_op_in : in STD_LOGIC_VECTOR(4 downto 0);
		pc_in : in STD_LOGIC_VECTOR(15 downto 0);
		rM_data_in : in STD_LOGIC_VECTOR(15 downto 0);
		rN_data_in : in STD_LOGIC_VECTOR(15 downto 0);
		imm_data_in : in STD_LOGIC_VECTOR(7 downto 0);
		result_out : out STD_LOGIC_VECTOR(15 downto 0);
		branch_out : out STD_LOGIC;
		rD_write_enable_in : in STD_LOGIC;
		rD_write_enable_out : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_in : STD_LOGIC;
	signal enable_in : STD_LOGIC;
	signal alu_op_in : STD_LOGIC_VECTOR(4 downto 0);
	signal pc_in : STD_LOGIC_VECTOR(15 downto 0);
	signal rM_data_in : STD_LOGIC_VECTOR(15 downto 0);
	signal rN_data_in : STD_LOGIC_VECTOR(15 downto 0);
	signal imm_data_in : STD_LOGIC_VECTOR(7 downto 0);
	signal rD_write_enable_in : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal result_out : STD_LOGIC_VECTOR(15 downto 0);
	signal branch_out : STD_LOGIC;
	signal rD_write_enable_out : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : alu
		port map (
			clk_in => clk_in,
			enable_in => enable_in,
			alu_op_in => alu_op_in,
			pc_in => pc_in,
			rM_data_in => rM_data_in,
			rN_data_in => rN_data_in,
			imm_data_in => imm_data_in,
			result_out => result_out,
			branch_out => branch_out,
			rD_write_enable_in => rD_write_enable_in,
			rD_write_enable_out => rD_write_enable_out
		);

	-- Add your stimulus here ...  
    clk_process : process
    begin
        clk_in <= '0';
        wait for 10 ns;
        clk_in <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    main_proc: process
    begin        

        enable_in <= '1'; 
		wait for 20 ns;
        -- Test ADD operation
        alu_op_in <= "00000"; -- ADD unsigned
        rM_data_in <= "0000000000000010"; -- 2
        rN_data_in <= "0000000000000011"; -- 3
        wait for 20 ns;

        alu_op_in <= "10000"; -- ADD signed
        rM_data_in <= "0000000000000100"; -- 4
        rN_data_in <= "1111111111111111"; -- -1 
        wait for 20 ns;

        -- Test SUB operation
        alu_op_in <= "00001"; -- SUB unsigned
        rM_data_in <= "0000000000000100"; -- 4
        rN_data_in <= "0000000000000001"; -- 1
        wait for 20 ns;

        alu_op_in <= "10001"; -- SUB signed
        rM_data_in <= "0000000000000010"; -- 2
        rN_data_in <= "1111111111111111"; -- -1 
        wait for 20 ns; 
		
		-- Test NOT operation
		alu_op_in <= "00010"; -- NOT
		rM_data_in <= "0000000000000011"; -- 3
		wait for 20 ns;
		
		-- Test AND operation
		alu_op_in <= "00011"; -- AND
		rM_data_in <= "0000000000001100"; -- 12
		rN_data_in <= "0000000000001010"; -- 10
		wait for 20 ns;
		
		-- Test OR operation
		alu_op_in <= "00100"; -- OR
		rM_data_in <= "0000000000001100"; -- 12
		rN_data_in <= "0000000000001010"; -- 10
		wait for 20 ns;
		
		-- Test XOR operation
		alu_op_in <= "00101"; -- XOR
		rM_data_in <= "0000000000001100"; -- 12
		rN_data_in <= "0000000000001010"; -- 10
		wait for 20 ns;
		
		-- Test LSR operation
		alu_op_in <= "00110"; -- LSR
		rM_data_in <= "0000000000001100"; -- 12
		rN_data_in <= "0000000000000010"; -- 2 (shift amount)
		wait for 20 ns;
		
		-- Test LSL operation
		alu_op_in <= "00111"; -- LSL
		rM_data_in <= "0000000000001100"; -- 12
		rN_data_in <= "0000000000000010"; -- 2 (shift amount)
		wait for 20 ns;
		
		-- Test CMP operation
		alu_op_in <= "01000"; -- CMP signed
		rM_data_in <= "0000000000000100"; -- 4
		rN_data_in <= "0000000000000010"; -- 2
		wait for 20 ns;
		
		-- Test B operation (Branch)
		alu_op_in <= "01001"; -- B with immediate
		imm_data_in <= "00000001"; -- Branch address (immediate value)
		wait for 20 ns;
		
		-- Test BEQ operation (Branch if Equal)
		alu_op_in <= "01010"; -- BEQ
		rM_data_in <= "0000000000000100"; -- Branch address (register value)
		rN_data_in(14) <= '1'; -- Set zero flag to simulate equality
		wait for 20 ns;
		
		-- Test IMMEDIATE operation
		alu_op_in <= "01011"; -- IMMEDIATE high
		imm_data_in <= "00000001"; -- Immediate data
		wait for 20 ns;
		
		-- Test LD operation (Load)
		alu_op_in <= "01100"; -- LD
		rM_data_in <= "0000000000000100"; -- Memory address to load from
		wait for 20 ns;
		
		-- Test ST operation (Store)
		alu_op_in <= "01101"; -- ST
		rM_data_in <= "0000000000000100"; -- Memory address to store to
		rN_data_in <= "0000000000000010"; -- Data to store
		wait for 20 ns;
		
		

		
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_alu of alu_tb is
	for TB_ARCHITECTURE
		for UUT : alu
			use entity work.alu(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_alu;

