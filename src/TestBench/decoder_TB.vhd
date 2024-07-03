library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity decoder_tb is
end decoder_tb;

architecture TB_ARCHITECTURE of decoder_tb is
	-- Component declaration of the tested unit
	component decoder
	port(
		clk_in : in STD_LOGIC;
		enable_in : in STD_LOGIC;
		instruction_in : in STD_LOGIC_VECTOR(15 downto 0);
		alu_op_out : out STD_LOGIC_VECTOR(4 downto 0);
		imm_data_out : out STD_LOGIC_VECTOR(7 downto 0);
		write_enable_out : out STD_LOGIC;
		sel_rM_out : out STD_LOGIC_VECTOR(2 downto 0);
		sel_rN_out : out STD_LOGIC_VECTOR(2 downto 0);
		sel_rD_out : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_in : STD_LOGIC;
	signal enable_in : STD_LOGIC;
	signal instruction_in : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal alu_op_out : STD_LOGIC_VECTOR(4 downto 0);
	signal imm_data_out : STD_LOGIC_VECTOR(7 downto 0);
	signal write_enable_out : STD_LOGIC;
	signal sel_rM_out : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_rN_out : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_rD_out : STD_LOGIC_VECTOR(2 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : decoder
		port map (
			clk_in => clk_in,
			enable_in => enable_in,
			instruction_in => instruction_in,
			alu_op_out => alu_op_out,
			imm_data_out => imm_data_out,
			write_enable_out => write_enable_out,
			sel_rM_out => sel_rM_out,
			sel_rN_out => sel_rN_out,
			sel_rD_out => sel_rD_out
		);

	-- Add your stimulus here ...
    clk_process : process
    begin
        clk_in <= '0';
        wait for 10 ns;
        clk_in <= '1';
        wait for 10 ns;
    end process;

    main_proc: process
    begin
        enable_in <= '0';
        instruction_in <= (others => '0');

        enable_in <= '1';
        wait for 20 ns;

        instruction_in <= x"0001";
        wait for 20 ns;
        instruction_in <= x"6801"; -- opcode "1101"
        wait for 20 ns;
        instruction_in <= x"4801"; -- opcode "1001"
        wait for 20 ns;	
        instruction_in <= x"5001"; -- opcode "1010"
        wait for 20 ns;
        instruction_in <= x"1A01"; 
        wait for 20 ns;
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_decoder of decoder_tb is
	for TB_ARCHITECTURE
		for UUT : decoder
			use entity work.decoder(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_decoder;

