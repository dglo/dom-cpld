--      Project: Ice Cube -- Cool Runner CPLD Programming
--      Author: C.Vu
--      Version :       1
--              Rev     :       0       Date: Jan-03-2003
--              Rev     :       1       Date: Feb-05-2003
--              Rev     :       2       Date: Feb-13-2003
-- changed all chip select to opposite from register (SW chip select = H)
--              Rev     :       3       Date: Feb-22-2003
-- to match API v0.2
-- change temp_sensor Reg_8 to Reg_5, Reg_6, positions on Reg_6
-- Change all Chip select lines to NOT inverting
--
--
--      Documentations used:    
--              - Dom Schematics (V11.0)
--              - Excalibur devices Hardware Reference Manual pages (91-96)
--              - DOM CPLD Description and API (Gerald Przybylski v0.0 Nov-14-2002)
--
--
--      Compilation notes:
--              - Compile the Cool Runner CPLD in binary coding to save FF since it does not have a lot of FF 
--              - Set compiler to
--								- All output are Slow
--								- Output reference to LVCMOS3.3v
--
--==============================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity EB_Interface0 is
    port (
-- Excaliber EBI    
        EBI_Clk         : in STD_LOGIC;
        EBI_nCS         : in STD_LOGIC_VECTOR (3 downto 0);
        EBI_a           : in STD_LOGIC_VECTOR (3 downto 0);
        EBI_nOE         : in STD_LOGIC;
        EBI_data        : inout STD_LOGIC_VECTOR (7 downto 0);
        EBI_nWE         : in STD_LOGIC;
        
-- Excalibur special pins 
     Boot_Flash     		: out STD_LOGIC;    -- Register 15-d1
     Init_Done          : in STD_LOGIC; -- Register 15-d2
     nConfig            : out STD_LOGIC;        -- Register 15-d3 
             
-- LED Power Supply        
     PS_Up              : out STD_LOGIC;        -- Register 9-d6
     PS_Down            : out STD_LOGIC;        -- Register 9-d5
     PS_Enable          : out STD_LOGIC;        -- Register 9-d7
        
-- Flasher  Board
     ADC_Flasher_nCS    : out STD_LOGIC; 
     ADC_Flasher_Dout   : in STD_LOGIC;    -- changed from OUT to IN on 1/30/03 C.Vu
        
-- Barometer        
     Barometer_Enable   : out STD_LOGIC;                -- Register 9-d2
         
-- Input select Mux for ATWD  
     Mux_En0            : out STD_LOGIC;        -- Register 10-d0  
     Mux_En1            : out STD_LOGIC;        -- Register 10-d1  
     Sel_A0          	: out STD_LOGIC;        -- Register 10-d2 
     Sel_A1             : out STD_LOGIC;        -- Register 10-d3 
        
-- Input select Mux for ???                       
        MUX_nCS0        : out STD_LOGIC;   -- Register 4-d7 
             
-- Flash Memory signals
        Flash_nWP       : out STD_LOGIC;        -- active low
        Flash_Reset     : out STD_LOGIC;        -- active low
        Flash_nWE       : out STD_LOGIC;        -- EBInWE
        Flash_nOE       : out STD_LOGIC;        -- EBI_nOE
        Flash_nCS0      : out STD_LOGIC;        -- Register 15-d0
        Flash_nCS1      : out STD_LOGIC;        -- Register 15-d0
        
-- External PLL signals
        PLL_S0          : out STD_LOGIC;        -- Register 10-d4       
     	  PLL_S1          : out STD_LOGIC;        -- Register 10-d5
         
-- DAC Signals        
        DAC_nCS0      	: out STD_LOGIC;                -- Register 4-d0
        DAC_nCS1        : out STD_LOGIC;                -- Register 4-d1
        DAC_nCS2        : out STD_LOGIC;                -- Register 4-d2
        DAC_nCS3      	: out STD_LOGIC;                -- Register 4-d3
        DAC_nCS4        : out STD_LOGIC;                -- Register 4-d4
        DAC_SClk        : out STD_LOGIC;                -- Register 6-d1
        DAC_CL          : out STD_LOGIC;                -- Register 6-d5        
        DAC_Din         : out STD_LOGIC;
                
-- ADC Signals ( ADC_Sclk = DAC_Sclk; ADC_Din = DAC_Din)        
        ADC_nCS0        : out STD_LOGIC;
        ADC_nCS1        : out STD_LOGIC;
        ADC_Dout        : IN STD_LOGIC;   -- changed from OUT to IN on 1/30/03 C.Vu
        
-- BASE (High Voltage) Signals  
      
     BASE_Dout          : IN STD_LOGIC;                 -- changed from OUT to IN on 1/30/03 C.Vu
     BASE_nCS0          : out STD_LOGIC;                -- Register 5-d0
     BASE_nCS1          : out STD_LOGIC;                -- Register 5-d1
     BASE_On_Off     	: out STD_LOGIC;                -- Register 9-d0 (HV_PS-Enable)
                
-- Temperature Sensor        
     Temp_Sensor_IO    	: inout STD_LOGIC;      -- Register 5-d4
     Temp_Sensor_Clk    : out STD_LOGIC;        -- Register 6-d1
         
-- Communication ADC Signals
--      PLD_COM_ADC_D   : in STD_LOGIC_VECTOR (9 downto 0); -- take out because it will not be used

-- Communication DAC Signals
        PLD_COM_DAC_D   : out STD_LOGIC_VECTOR (13 downto 6);              
        
-- UARTs Signals 
        RxD_Local       : in STD_LOGIC;
        DSR             : in STD_LOGIC;                 
        Serial_Power    : in STD_LOGIC; -- SERPWR       Register 11-d0
        RxD             : out STD_LOGIC;        -- Serial_Receiver_Data Register 11-d2  ????? IN or OUT??? to Excalibur UART_RXD pin F21
        TxD             : in STD_LOGIC; -- Serial_Transmitter_Data      Register 11-d3


-- Other Signals 

        CPU_Clk         : in STD_LOGIC;         -- Clock frequency 20 MHz
        CLK_13          : out STD_LOGIC;        -- ???
        CLK_24          : out STD_LOGIC;        -- ???
        Int_Ext_pin_n   : OUT STD_LOGIC;        -- ??? -- 1/30/03
        AUX_CLT         : inout STD_LOGIC;      -- Register 10-d6       ( this is only one direction and depend on what ext device)     
        PLD_TP          : out STD_LOGIC;
                
     nRESET             : in STD_LOGIC; -- ???
     nPOR               : in STD_LOGIC  -- Last port of the Entity
--              Reset                   : in STD_LOGIC          
                
    );
end EB_Interface0;

architecture EB_Interface0_arch of EB_Interface0 is

--**************************** Constants ***************************************
-- Set the active reset level
constant RESET_ACTIVE : STD_LOGIC := '0';           -- default is active low reset
       
--**************************** Signal Definitions ***************************************

-- uc data bus signals
signal uc_data_out  		: std_logic_vector(7 downto 0); -- data to be output to 8051 
signal Reg_4_en         :std_logic;
signal Reg_5_en         :std_logic;

signal Reg_enable       : std_logic_vector(3 downto 0); 

signal Reg_4            : std_logic_vector(7 downto 0); -- Chip select 0 Register 
signal Reg_5            : std_logic_vector(7 downto 0);         -- Chip select 1 Register 
signal Reg_6            : std_logic_vector(7 downto 0); 
signal Reg_7            : std_logic_vector(7 downto 0);
-- signal       ADC0_Data               :std_logic;     -- for Future use
-- signal       ADC1_Data               :std_logic;     -- for Future use
signal Reg_8            : std_logic_vector(7 downto 0);
signal Reg_9            : std_logic_vector(7 downto 0);
signal Reg_10           : std_logic_vector(7 downto 0);
signal Reg_11           : std_logic_vector(7 downto 0);
signal Reg_12           : std_logic_vector(7 downto 0);
signal Reg_13           : std_logic_vector(7 downto 0);
signal Reg_14           : std_logic_vector(7 downto 0); -- Reboot control register 
signal Reg_15           : std_logic_vector(7 downto 0); -- Boot configuration register

signal EBI_data_in      : std_logic_vector(7 downto 0); 
signal EBI_data_out     : std_logic_vector(7 downto 0);
signal Reset                    :std_logic;
signal CPU_Reboot_Pulse         :std_logic;
signal count                    : unsigned(3 downto 0);

--**************************** Start ***************************************
begin

--************************** Bi-directional EBI Data Bus *****************************

        EBI_data   	<= EBI_data_out  when (EBI_nOE = '0' and EBI_nCS(3)= '0')  else (others => 'Z');
        EBI_data_in  <= EBI_data      when (EBI_nWE = '0' and EBI_nCS(3)= '0') else "00000000";
------
--      ADC0_Data   <=  Reg_7(1)        when (Reg_7(2) = '1')  else 'Z';    ADC_Data0 & 1 is taking out 2/3/03
--      Reg_7(1)  <= ADC0_Data  when (Reg_7(2) = '0')  else '0';        
------
--      ADC1_Data   <=  Reg_7(5)        when (Reg_7(6) = '1')  else 'Z';
--      Reg_7(5)  <= ADC1_Data  when (Reg_7(6) = '0')  else '0';                
------
        Temp_Sensor_IO  <=  Reg_5(4)   when (Reg_5(4) = '0')  else 'Z';

        AUX_CLT   		<=  Reg_10(7)  when (Reg_10(6) = '1')  else 'Z'; 	-- Write
        
        PLD_COM_DAC_D  <=  "ZZZZZZZZ" ; --  Add on 1/30/03 C.Vu
--************************** Concurrent Statements **********************************

        DAC_nCS0        <=      Reg_4 (0); 
        DAC_nCS1        <=      Reg_4 (1);  
        DAC_nCS2        <=      Reg_4 (2);   
        DAC_nCS3        <=      Reg_4 (3);  
        DAC_nCS4        <=      Reg_4 (4);   
        ADC_nCS0        <=      Reg_4 (5);   
        ADC_nCS1        <=      Reg_4 (6);  
        MUX_nCS0        <=      Reg_4 (7);   
        
        BASE_nCS0       <=      Reg_5 (0);
     	  BASE_nCS1       <=      Reg_5 (1);
        ADC_Flasher_nCS <=      Reg_5 (2);
        
        DAC_SClk        <=      Reg_6 (1);
		  Temp_Sensor_Clk <=      Reg_6 (1); -- same as DAC_Sclk      
        DAC_Din        	<=      Reg_6 (2);
        DAC_CL          <=      Reg_6 (5);      
                
        BASE_On_Off      <=     Reg_9 (0);
        Barometer_Enable <=     Reg_9 (2);                
        PS_Down         <=      Reg_9 (5);
        PS_Up           <=      Reg_9 (6);
     	  PS_Enable       <=      Reg_9 (7);
        
        Mux_En0         <=      Reg_10 (0);     
        Mux_En1         <=      Reg_10 (1);  
        Sel_A0          <=      Reg_10 (2);  
        Sel_A1          <=      Reg_10 (3); 
        PLL_S0          <=      Reg_10 (4); 
        PLL_S1          <=      Reg_10 (5);
                         
--      RxD                     <= RXD_Local when ((Serial_Power = '1') and (Reg_11 (1) = '1'))  -- Force DOM communication through on board serial interface
--   This line is temporary put in to by-pass Reg_11(1) 2/5/03 by Thorsten
        RxD                     <= RXD_Local when ((Serial_Power = '1'))  -- Force DOM communication through on board serial interface
        else    '1';            -- Hold Excalibur Uart inactive and let DOM communication through twisted pair with DOM Hub or Serrogate        
                       
        Flash_nWP       <=  '1'; -- Write Protection active low
        Flash_Reset     <=  nRESET ; 
        Flash_nOE       <=  EBI_nOE;
        Flash_nWE       <=  EBI_nWE;
        Flash_nCS0      <=  '0'   when ((not EBI_nCS(0) and EBI_nCS(1) and not Reg_15(0) ) ='1') or ((EBI_nCS(0) and not EBI_nCS(1) and Reg_15(0) ) ='1')
         else    '1' ;
        Flash_nCS1      <=  '0'   when ((not EBI_nCS(0) and EBI_nCS(1) and Reg_15(0) ) ='1') or ((EBI_nCS(0) and not EBI_nCS(1) and not Reg_15(0) ) ='1')
         else    '1' ;
        
        Boot_Flash     	<=      Reg_15(1);      -- Register 15-d1 
        nConfig         <= '0'  when ( ( not Reg_15(3) and Reg_15(1)) = '1') else 'Z';  -- Register 15-d3
	     Reset           <=      nPOR;

        CLK_13          <=  Init_Done and CPU_Clk;      -- 1/30/03      
        CLK_24          <=  Init_Done and CPU_Clk;      -- 1/30/03              
     	Int_Ext_pin_n  <=  '1';    
        
--************************** EBI Address Decode ***********************************
-- This process decodes the address and sets enables for the registers use EBInCS3
address_decode: process (reset, CPU_clk)
begin
    if reset = RESET_ACTIVE then        
       Reg_enable <= "0000";
        -- Synchronize with falling edge of clock
       elsif EBI_Clk'event and (EBI_Clk = '0') then                
                  if EBI_nCS(3 downto 2) = "01" then
                        Reg_enable <= EBI_a;
                 else
                        Reg_enable <= "0000";
                 end if ;                                                         
       end if;        
    end process; 

--************************** nCONFIG pulse width ***********************************
-- This process extend the nCONFIG pulse
nCONFIG_pulse: process (reset, CPU_Clk)
begin
    if reset = RESET_ACTIVE then 
                Reg_15(3) <= '1';       
--       Reg_enable <= "0000";
        -- Synchronize with falling edge of clock
    elsif CPU_Clk'event and (CPU_Clk = '1') then
                if (Reg_15(1) and  Reg_14(0)) = '1' then
                        Reg_15(3) <= '0';
                elsif count = 15 then
                        Reg_15(3) <= '1';
                end if;                                           
    end if;        
end process;             

--************************** nCONFIG count ***********************************
-- This process extend the nCONFIG pulse
nCONFIG_count: process (reset, CPU_Clk)
begin
    if reset = RESET_ACTIVE then 
                count <= "0000";       
--       Reg_enable <= "0000";
        -- Synchronize with falling edge of clock
    elsif CPU_Clk'event and (CPU_Clk = '0') then
                if Reg_15(3) = '0' then
                        count <= count + 1;
                else
                        count <= "0000";
                end if;                                           
    end if;        
end process; 
--************************** Read/Write to Register **********************************
-- This process Write to or Read from registers

register_rw: process(EBI_Clk, reset)
begin
    if reset = RESET_ACTIVE then    
                EBI_data_out            <= "00000000";  
	             Reg_4                   <= "11111111"; 

                Reg_5                   <= "11111111"; 
					  
                Reg_6 (2 downto 0)      <= "000";
                Reg_6 (7 downto 4)      <= "0010";

                Reg_7 (0)               <= '0';                 
                Reg_7 (3 downto 2)      <= "00";                
                Reg_7 (4)               <= '0';                 
                Reg_7 (7 downto 6)      <= "00";
                
                Reg_8 (0)               <= '0';
                Reg_8 (7 downto 2)      <= "000000";
                                
                Reg_9 (7 downto 0)      <= "00100000";
                
                Reg_10 (6 downto 0)     <= "1000000";
                
                Reg_11 (1) <= '0'; 
                Reg_11(7 downto 4)      <= "0000"; 
                                
--              Reg_12  <= "00100000";          -- Spare
--              Reg_13          <= "00100000";  -- Spare
                                
                Reg_14          <= "00000000";
                
                Reg_15 (1 downto 0)     <= "10";                     
                Reg_15 (7 downto 4)     <= "0000" ;
                                        
        -- Synchronize with falling edge of clock
        elsif EBI_Clk'event and (EBI_Clk = '0') then  
        
        -- Register 4
                if Reg_enable = "0100" then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_4      <=EBI_data_in;
                    else
                        -- uC read
                        EBI_data_out <= Reg_4;              
                    end if;
                end if;
                
        -- Register 5
                    if Reg_enable = "0101"then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_5      <=EBI_data_in;
                    else
                        -- uC read
                        EBI_data_out(3 downto 0) <= Reg_5(3 downto 0); 
								EBI_data_out(4)			 <= Temp_Sensor_IO;
								EBI_data_out(7 downto 5) <= Reg_5(7 downto 5);             
                    end if;
                end if;
                
        -- Register 6
                    if Reg_enable = "0110"then
                    if EBI_nWE = '0' then
                        -- uC write            
               --         Reg_6      <=EBI_data_in;
                                    Reg_6 (2 downto 0)  <= EBI_data_in (2 downto 0);
                                    Reg_6 (7 downto 4)  <= EBI_data_in (7 downto 4);
                    else
                        -- uC read
                        EBI_data_out(1 downto 0) <= Reg_6(1 downto 0);
								EBI_data_out(2) 	<=	ADC_Dout; 
								EBI_data_out(3)	<=	BASE_Dout;
								EBI_data_out(4)	<=	ADC_Flasher_Dout;
								EBI_data_out(7 downto 5) <= Reg_6(7 downto 5);            
                    end if;
                end if;
                
        -- Register 7
                    if Reg_enable = "0111"then
                    if EBI_nWE = '0' then
                        -- uC write 
                    		Reg_7 (0)            <= EBI_data_in(0);              
                    		Reg_7 (3 downto 2)   <= EBI_data_in(3 downto 2) ;                    
                    		Reg_7 (4)          	<= EBI_data_in(4);              
                    		Reg_7 (7 downto 6)   <= EBI_data_in(7 downto 6) ;
                    else
                        -- uC read
                        EBI_data_out <= Reg_7;              
                    end if;
                end if;
                
         -- Register 8 (Support Register 1)
                    if Reg_enable = "1000"then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_8     <=EBI_data_in;
                    else
                        -- uC read
                        EBI_data_out <= Reg_8;              
                    end if;
                end if;       

          -- Register 9 (System control)
                    if Reg_enable = "1001"then
                    if EBI_nWE = '0' then
                        Reg_9(7 downto 0) <= EBI_data_in(7 downto 0);
                    end if;
                end if;       
                
          -- Register 10 (ATWD Input Multiplexor Control)
                    if Reg_enable = "1010"then
                    if EBI_nWE = '0' then
                        -- uC write                                    
                        Reg_10(6 downto 0)   <=EBI_data_in(6 downto 0);
                    else
                        -- uC read
								EBI_data_out(6 downto 0) 	<= Reg_10(6 downto 0);
								EBI_data_out(7)  				<=  AUX_CLT;                                      
                    end if;
                end if;
                
          -- Register 11 (Communication Control Register UART)
                    if Reg_enable = "1011"then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_11(1)      		<=EBI_data_in(1);
                        Reg_11(7 downto 4)   <=EBI_data_in(7 downto 4);
                    else
                        -- uC read
								EBI_data_out(0)  				<= Serial_Power;
								EBI_data_out(2 downto 1) 	<= Reg_11(2 downto 1);
								EBI_data_out(3)  			 	<= TxD;
			               EBI_data_out(7 downto 4) 	<= Reg_11(7 downto 4);              
                    end if;
                end if;
                
        -- Register 14 (ReBoot Control Register bit 0 write only)
                    if Reg_enable = "1110"then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_14      <=EBI_data_in;
                    else
                        Reg_14      <="00000000";
                        -- uC read
                        EBI_data_out <= Reg_14;              
                    end if;
                end if;
                
        -- Register 15 (Boot Configuration Register)
                    if Reg_enable = "1111"then
                    if EBI_nWE = '0' then
                        -- uC write            
                        Reg_15(1 downto 0)      <=	EBI_data_in (1 downto 0);
                        Reg_15(7 downto 4)      <=	EBI_data_in (7 downto 4);                        
                    else
                        -- uC read
								EBI_data_out(1 downto 0) 	<= Reg_15(1 downto 0);
								EBI_data_out(2)      		<= Init_Done;      -- Register 15-d2   
                        EBI_data_out(7 downto 4) 	<= Reg_15(7 downto 4);              
                    end if;
                end if;
                   
        end if;        
    end process;      
    
end EB_Interface0_arch;
