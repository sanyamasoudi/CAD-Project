library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    --Port ( clk_in : in STD_LOGIC;
    --       reset : in STD_LOGIC);
end cpu;

architecture Behavioral of cpu is

    component registerfile
    Port ( clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            write_enable_in : in STD_LOGIC;
            rM_data_out : out STD_LOGIC_VECTOR (15 downto 0);
            rN_data_out : out STD_LOGIC_VECTOR (15 downto 0);
            rD_data_in : in STD_LOGIC_VECTOR (15 downto 0);
            sel_rM_in : in STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_in : in STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_in : in STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component decoder
    Port ( clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            instruction_in : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_out : out STD_LOGIC_VECTOR (4 downto 0);
            imm_data_out : out STD_LOGIC_VECTOR (7 downto 0); -- 16 or 8
            write_enable_out : out STD_LOGIC;
            sel_rM_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_out : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component alu
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
    end component;
    
    component controlunit
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           stage_out : out STD_LOGIC_VECTOR (5 downto 0));
    end component;
    
    component pcunit
    Port ( clk_in : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           pc_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component ram
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           write_enable_in : in STD_LOGIC;
           address_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    signal reg_enable : STD_LOGIC := '0'; --regfile
    signal reg_write_enable : STD_LOGIC := '0'; --regfile
    signal rM_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rN_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rD_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rM_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    signal rN_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    signal rD_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    
    signal instruction : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --decoder --alu
    signal alu_op : STD_LOGIC_VECTOR (4 downto 0) := (others => '0'); --decoder --alu --controlunit
    signal immediate : STD_LOGIC_VECTOR (7 downto 0) := (others => '0'); --decoder --alu
    
    signal result : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --alu
    signal branch : STD_LOGIC := '0'; --alu
    signal rD_write_enable : STD_LOGIC := '0'; --alu
    signal rD_write_enable_1 : STD_LOGIC := '0'; --alu
    
    signal cpu_reset : STD_LOGIC := '0'; --controlunit --ram
    
    signal stage : STD_LOGIC_VECTOR (5 downto 0) := (others => '0'); --controlunit
    
    signal pc_op : STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); --pc
    signal pc_in : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --pc
    signal pc_out : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --pc
    
    signal ram_write_enable : STD_LOGIC := '0'; -- ram
    signal address : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    signal ram_data_in : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    signal ram_data_out : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    
    signal fetch_enable : STD_LOGIC := '0'; --pipeline
    signal reg_read : STD_LOGIC := '0'; --pipeline
    signal decoder_enable : STD_LOGIC := '0'; --pipeline
    signal alu_enable : STD_LOGIC := '0'; --pipeline
    signal ram_enable : STD_LOGIC := '0'; --pipeline
    signal reg_write : STD_LOGIC := '0'; --pipeline
    
    signal cpu_clock : STD_LOGIC := '0';   --all
    
    constant clk_period : time := 10 ns;
    

begin

    cpu_registerfile : registerfile PORT MAP (
        clk_in => cpu_clock,
        enable_in => reg_enable,
        write_enable_in => reg_write_enable,
        rM_data_out => rM_data,
        rN_data_out => rN_data,
        rD_data_in => rD_data,
        sel_rM_in => rM_sel,
        sel_rN_in => rN_sel,
        sel_rD_in => rD_sel
    );
    
    cpu_decoder : decoder PORT MAP (
        clk_in => cpu_clock,
        enable_in => decoder_enable,
        instruction_in => instruction,
        alu_op_out => alu_op,
        imm_data_out => immediate,
        write_enable_out => rD_write_enable,
        sel_rM_out => rM_sel,
        sel_rN_out => rN_sel,
        sel_rD_out => rD_sel
    );
    
    cpu_alu : alu PORT MAP (
        clk_in => cpu_clock,
        enable_in => alu_enable,
        alu_op_in => alu_op,
        pc_in => pc_out,
        rM_data_in => rM_data,
        rN_data_in => rN_data,
        imm_data_in => immediate,
        result_out => result,
        branch_out => branch,
        rD_write_enable_in => rD_write_enable,
        rD_write_enable_out => rD_write_enable_1
    );
    
    cpu_controlunit : controlunit PORT MAP (
        clk_in => cpu_clock,
        reset_in => cpu_reset,
        alu_op_in => alu_op,
        stage_out => stage
    );
        
    cpu_pcunit : pcunit PORT MAP (
        clk_in => cpu_clock,
        pc_op_in => pc_op,
        pc_in => pc_in,
        pc_out => pc_out
    );
        
    cpu_ram : ram PORT MAP (
        clk_in => cpu_clock,
        reset => cpu_reset,
        enable_in => ram_enable,
        write_enable_in => ram_write_enable,
        address_in => address,
        data_in => ram_data_in,
        data_out => ram_data_out
    );
    
--CPU    
    --cpu_clock <= clk_in;
    --cpu_reset <= reset;
    
--REGISTER FILE
    reg_enable <= reg_read or reg_write;
    reg_write_enable <= rD_write_enable_1 and reg_write;
    
--PIPELINE   
    fetch_enable <= stage(0); -- fetch
    decoder_enable <= stage(1); -- decode
    reg_read <= stage(2); -- register read
    alu_enable <= stage(3); -- execute
    ram_enable <= stage(4); -- memory
    reg_write <= stage(5); -- register write

--PC
    pc_op <= "00" when cpu_reset = '1' else -- reset
             "01" when branch = '0' and stage(5) = '1' else -- increment
             "10" when branch = '1' and stage(5) = '1' else -- jump
             "11"; -- nop

    pc_in <= result;

--MEMORY   
    address <= result when ram_enable = '1' else pc_out; -- the ram access is either during memory stage or fetch stage
    ram_data_in <= rN_data; -- rN contains data, rM contains address for ST
    ram_write_enable <= '1' when ram_enable = '1' and alu_op(3 downto 0) = "1101" else '0'; -- ram_enable and a ST
    
    rD_data <= ram_data_out when reg_write = '1' and alu_op(3 downto 0) = "1100" else result; --register data is either ram when LD or alu result
    
    instruction <= ram_data_out when fetch_enable = '1'; -- data from ram goes to decoder


    clk_process : process
    begin
         cpu_clock <= '0';
         wait for clk_period/2;
         cpu_clock <= '1';
         wait for clk_period/2;
    end process;  
	
     main_proc: process
    begin      
        
        cpu_reset <= '1'; 
        wait for clk_period*2; -- Wait for two clock periods
        cpu_reset <= '0';
        wait until reg_write = '1';
        
        -- Initialize instruction
        instruction <= x"0000";
        
        -- Load immediate values into registers
        instruction <= "0101100000001010"; -- imm r0 = 0x000A
        wait until reg_write = '1';
        
        instruction <= "0101100101010101"; -- imm r1 = 0x0055
        wait until reg_write = '1';
        
        -- Perform NOT operation
        instruction <= "0010000100010000"; -- not r1 = ~r1
        wait until reg_write = '1';
        
        -- Perform ADD operation
        instruction <= "0000010001001000"; -- ADD r2, r1, r0
        wait until reg_write = '1';
        
        -- Load immediate value into r3
        instruction <= "0101101100001000"; -- imm r3 = 0x0008
        wait until reg_write = '1';
        
        -- Perform LSL operation
        instruction <= "0110010001001100"; -- LSL r2, r2, r3
        wait until reg_write = '1';
        
        -- Load immediate value into r4
        instruction <= "0101110000000100"; -- imm r4 = 0x0004
        wait until reg_write = '1';
        
        -- Perform LSR operation
        instruction <= "0111010001000100"; -- LSR r2, r2, r4
        wait until reg_write = '1';
        
        -- Branch instruction
        instruction <= "1101100000001011"; -- Branch to address 0x000B
        wait until reg_write = '1';
        
        -- NOP instructions
        instruction <= x"0000"; -- NOP
        wait until reg_write = '1';
        
        instruction <= x"0000"; -- NOP
        wait until reg_write = '1';
        
        instruction <='0' & "0100" & "011" & "010" & "001" & "00"; -- OR r3 r2 r1, r3 = 0x14 (2344)                  
        wait until reg_write = '1';
         
        instruction <='0' & "0101" & "100" & "011" & "011" & "00"; -- XOR r4 r3 r3, r4 = 0x00  (2C6C)             
        wait until reg_write = '1';
        
        wait; 
        
    end process;
	


end Behavioral;
