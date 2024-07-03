library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity controlunit_tb is
end controlunit_tb;

architecture TB_ARCHITECTURE of controlunit_tb is
	-- Component declaration of the tested unit
	component controlunit
	port(
		clk_in : in STD_LOGIC;
		reset_in : in STD_LOGIC;
		alu_op_in : in STD_LOGIC_VECTOR(4 downto 0);
		stage_out : out STD_LOGIC_VECTOR(5 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_in : STD_LOGIC;
	signal reset_in : STD_LOGIC;
	signal alu_op_in : STD_LOGIC_VECTOR(4 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal stage_out : STD_LOGIC_VECTOR(5 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : controlunit
		port map (
			clk_in => clk_in,
			reset_in => reset_in,
			alu_op_in => alu_op_in,
			stage_out => stage_out
		);

	-- Add your stimulus here ...
    clk_process : process
    begin  
        clk_in <= '0';
        wait for 10 ns;
        clk_in <= '1';
        wait for 10 ns;	   
    end process;


    main_process: process
    begin
        reset_in <= '0';
        alu_op_in <= (others => '0');

        reset_in <= '1';
        wait for 20 ns;
        reset_in <= '0';
        wait for 20 ns;

        alu_op_in <= "00000";
        wait for 40 ns;
        alu_op_in <= "01100"; 
        wait for 40 ns;
        alu_op_in <= "01101"; 
        wait for 40 ns;
        alu_op_in <= "00001";
        wait for 40 ns;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_controlunit of controlunit_tb is
	for TB_ARCHITECTURE
		for UUT : controlunit
			use entity work.controlunit(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_controlunit;

