library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity pcunit_tb is
end pcunit_tb;

architecture TB_ARCHITECTURE of pcunit_tb is
	-- Component declaration of the tested unit
	component pcunit
	port(
		clk_in : in STD_LOGIC;
		pc_op_in : in STD_LOGIC_VECTOR(1 downto 0);
		pc_in : in STD_LOGIC_VECTOR(15 downto 0);
		pc_out : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_in : STD_LOGIC;
	signal pc_op_in : STD_LOGIC_VECTOR(1 downto 0);
	signal pc_in : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal pc_out : STD_LOGIC_VECTOR(15 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : pcunit
		port map (
			clk_in => clk_in,
			pc_op_in => pc_op_in,
			pc_in => pc_in,
			pc_out => pc_out
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
        pc_op_in <= "00";
        pc_in <= (others => '0');

        wait for 100 ns;

        pc_op_in <= "01";
        wait for 20 ns;
        pc_op_in <= "10";
        pc_in <= x"AAAA";
        wait for 20 ns;
        pc_op_in <= "00";
        wait for 20 ns;
        pc_op_in <= "11"; 
        wait for 20 ns;

        wait;
    end process;	

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_pcunit of pcunit_tb is
	for TB_ARCHITECTURE
		for UUT : pcunit
			use entity work.pcunit(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_pcunit;

