-- Project: Ice Cube -- Dom board rev 2 Cool Runner CPLD Programming
-- Author: C.Vu
-- Version : 1
--      Rev  : 0       Date: Feb-18-2003
--                              (This is the modification of code in Ice_cube3 project on Feb-18-03)
--
--    Rev  : 1       Date: April-16-2003
--                      - Add by Thorsten on ~ 4-11-03)
--                              1) SC_nCS7   <=  'Z' WHEN Reg_4(7)='1' ELSE '0';   
--                         2) Reg_4(7) in read register   
--                      - Add by Chinh on ~ 4-16-03)                                            
--                         3) nCONFIG_pulse: process  the if statement are reversed order to alway clear the counter
--                      - Add by Chinh on ~ 4-17-03)                                            
--                         4) Add nCONFIG_delay: to delay the start of nCONFIG pulse 
--                         5) change nCONFIG <= --------------------                                                               
--    Rev   : 2          Date: June-4-2003
--                                                              - Add by Arthur on 6-2-03
--                                                                      1) Add the one wire codes at Wisconsin
--                                                              - Add by Chinh on 6-4-03
--                                                                      1)      Change the MISO concurrent statement to be controlled by both (Reg_12(7) = '1' and Reg_4 (1)='1')
--                                                                      2) Add CPLD_Power_Up_nRESET cycle to allow the CPLD to issue the Reset pulse after it power up
--                                                              - Added by
--                                                              Arthur,Thorsten
--                                                              10-27-03
--                                                                 1) version number
--      Documentations used:    
--              --Dom Schematics (V11.0)
--              --Excalibur devices Hardware Reference Manual pages (91-96)
--              -- DOM CPLD Description and API (Gerald Przybylski v0.0 Nov-14-2002)
--
--
--      Compilation notes:
-- Compile the Cool Runner CPLD in binary coding to save FF since it does not have a lot of FF 
--              
--==============================================================================

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY EB_Interface_rev2 IS
    PORT (
-- Excaliber EB    
        EB_Clk  : IN    STD_LOGIC;
        EB_nCS  : IN    STD_LOGIC_VECTOR (3 DOWNTO 0);
        EBA     : IN    STD_LOGIC_VECTOR (5 DOWNTO 0);
        EB_nOE  : IN    STD_LOGIC;
        EBD     : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        EB_nWE  : IN    STD_LOGIC;
        PLD_Clk : IN    STD_LOGIC;      -- Clock frequency = 20 MHz

-- Flasher board interface          
        FL_D         : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        FL_A         : OUT   STD_LOGIC_VECTOR (5 DOWNTO 0);
        FL_nWE       : OUT   STD_LOGIC;
        FL_nOE       : OUT   STD_LOGIC;
        FL_ON_OFF    : OUT   STD_LOGIC;
        FL_UNDEFINED : OUT   STD_LOGIC;


-- Excalibur special pins 
        Boot_Flash : OUT   STD_LOGIC;   -- Register 15-d1
        Init_Done  : IN    STD_LOGIC;   -- Register 15-d2
        nConfig    : OUT   STD_LOGIC;   -- Register 15-d3       
        Conf_Done  : IN    STD_LOGIC;   -- from CPU     to R15-d4       
        nRESET     : IN    STD_LOGIC;   -- from CPU     to R15-d6
        nSTATUS    : IN    STD_LOGIC;   -- from CPU to R15-d7
        nPOR       : INOUT STD_LOGIC;   --reg_14 power on reset switch
        soft_reset : IN    STD_LOGIC;  -- normal High, push to Low, OR with Reg_14(0) to force nCONFIG down 

-- Barometer        
        Barometer_Enable : OUT STD_LOGIC;  -- Register 9-d2

-- Input select Mux for ATWD  
        Mux_En0 : OUT STD_LOGIC;        -- Register 10-d0  
        Mux_En1 : OUT STD_LOGIC;        -- Register 10-d1  
        Sel_A0  : OUT STD_LOGIC;        -- Register 10-d2 
        Sel_A1  : OUT STD_LOGIC;        -- Register 10-d3 



-- Flash Memory signals
        Flash_nWP  : OUT STD_LOGIC;     -- active low
--      Flash_Reset     : out STD_LOGIC;        -- active low 
        Flash_nWE  : OUT STD_LOGIC;     -- EBnWE
        Flash_nOE  : OUT STD_LOGIC;     -- EB_nOE
        Flash_nCS0 : OUT STD_LOGIC;     -- Register 15-d0
        Flash_nCS1 : OUT STD_LOGIC;     -- Register 15-d0


-- SPI/I2C/1-Wire Signals        
        SC_nCS0 : OUT STD_LOGIC;        -- Register 4-d0
        SC_nCS1 : OUT STD_LOGIC;        -- Register 4-d1
        SC_nCS2 : OUT STD_LOGIC;        -- Register 4-d2
        SC_nCS3 : OUT STD_LOGIC;        -- Register 4-d3
        SC_nCS4 : OUT STD_LOGIC;        -- Register 4-d4
        SC_SClk : OUT STD_LOGIC;        -- Register 6-d1
        SC_CL   : OUT STD_LOGIC;        -- Register 6-d5        
        SC_MOSI : OUT STD_LOGIC;

-- ADC Signals ( ADC_Sclk = DAC_Sclk; ADC_Din = DAC_Din)        
        SC_nCS5 : OUT STD_LOGIC;
        SC_nCS6 : OUT STD_LOGIC;
        SC_MISO : IN  STD_LOGIC;  -- changed from OUT to IN on 1/30/03 C.Vu

-- BASE (High Voltage) Signals        
        BASE_nCS0   : OUT   STD_LOGIC;  -- Register 5-d0
        BASE_nCS1   : OUT   STD_LOGIC;  -- Register 5-d1
        BASE_On_Off : OUT   STD_LOGIC;  -- Register 9-d0 (HV_PS-Enable)
        BASE_Sclk   : OUT   STD_LOGIC;  -- the same as sc_sclk
        BASE_MISO   : INOUT STD_LOGIC;
        BASE_MOSI   : OUT   STD_LOGIC;
-- Temperature Sensor        
        SC_nCS7     : INOUT STD_LOGIC;  -- Register 8-d1 



-- UARTs Signals 
        serial_power : IN  STD_LOGIC;  -- IN from the pulldown, with jumper in = High
        RxD_Local    : IN  STD_LOGIC;   -- IN from RS232 Tranceiver
        DSR_Local    : IN  STD_LOGIC;   -- IN from RS232 Tranceiver 
        CTS_Local    : IN  STD_LOGIC;   -- IN from RS232 Tranceiver
        TxD_Local    : OUT STD_LOGIC;   -- OUT to RS232 Tranceiver
        RTS_Local    : OUT STD_LOGIC;   -- OUT to RS232 Tranceiver
        DTR_Local    : OUT STD_LOGIC;   -- OUT to RS232 Tranceiver


        EX_TxD : IN  STD_LOGIC;  -- Serial_Transmitter_Data      Register 11-d3  IN from Excalibur UART_TXD pin G21
        Ex_RTS : IN  STD_LOGIC;         -- IN from Excalibur UART_TXD pin H21
        EX_DTR : IN  STD_LOGIC;  -- IN from Excalibur UART_TXD pin J20                 
        EX_RxD : OUT STD_LOGIC;  -- Serial_Receiver_Data Register 11-d2 OUT to Excalibur UART_RXD pin F21
        EX_DSR : OUT STD_LOGIC;         -- OUT to Excalibur UART_RXD pin H22 
        EX_CTS : OUT STD_LOGIC;         -- OUT to Excalibur UART_RXD pin G22




-- Excalibur'FPGA & DOM's CPLD Signals
        Int_Ext_pin_n : OUT   STD_LOGIC;  -- ??? -- 1/30/03
        FPGA_PLD_nWE  : INOUT STD_LOGIC;
        FPGA_PLD_nOE  : INOUT STD_LOGIC;
        FPGA_PLD_BUSY : INOUT STD_LOGIC;
        FPGA_PLD_D    : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);

-- Other Signals 

        AUX_CLT : INOUT STD_LOGIC;  -- Register 10-d6       ( this is only one direction and depend on what ext device)     

        PLD_Mode : IN    STD_LOGIC;  -- normal High, jumper to Low, OR with Reg_15(1) to force reboot from flash memory
        PLD_TP   : INOUT STD_LOGIC      -- Last port of the Entity


--              Reset                   : in STD_LOGIC                          
        );
END EB_Interface_rev2;

ARCHITECTURE EB_Interface_rev2_arch OF EB_Interface_rev2 IS

    -- CPLD version number
    COMPONENT version
        PORT (
            vsn : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
            );
    END COMPONENT;

--**************************** Constants ***************************************
-- Set the active reset level
    CONSTANT RESET_ACTIVE : STD_LOGIC := '0';  -- default is active low reset

--**************************** Signal Definitions ***************************************

-- uc data bus signals
    SIGNAL uc_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- data to be output to 8051 
    SIGNAL Reg_4_en    : STD_LOGIC;
    SIGNAL Reg_5_en    : STD_LOGIC;

    SIGNAL Reg_enable : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL Reg_4  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Chip select 0 Register 
    SIGNAL Reg_5  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Chip select 1 Register 
    SIGNAL Reg_6  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_7  : STD_LOGIC_VECTOR(7 DOWNTO 0);
-- signal       ADC0_Data               :std_logic;     -- for Future use
-- signal       ADC1_Data               :std_logic;     -- for Future use
    SIGNAL Reg_8  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_9  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_10 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_11 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_12 : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- temporary use for one wire commands
    SIGNAL Reg_13 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reg_14 : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Reboot control register 
    SIGNAL Reg_15 : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Boot configuration register

    SIGNAL EBD_in                            : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL EBD_out                           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Reset                             : STD_LOGIC;
    SIGNAL CPU_Reboot_Pulse                  : STD_LOGIC;
    SIGNAL count                             : UNSIGNED(3 DOWNTO 0);
    SIGNAL one_wire_counter                  : UNSIGNED(15 DOWNTO 0);
    SIGNAL One_Wire_Count_Enable             : STD_LOGIC;
    SIGNAL SW_reboot                         : STD_LOGIC;  -- to delay the nConfig signal 
-- Signals for CPLD_Power_Up_Reset
    SIGNAL CPLD_Power_Up_nRESET              : STD_LOGIC;
    SIGNAL CPLD_Power_Up_nRESET_Count_Enable : STD_LOGIC;
    SIGNAL CPLD_Power_Up_nRESET_Counter      : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL CPLD_Power_Up_nRESET_Done         : STD_LOGIC;

    SIGNAL vsn : STD_LOGIC_VECTOR (31 DOWNTO 0);  -- cpld version number
--**************************** Start ***************************************
BEGIN

    inst_version : version
        PORT MAP (
            vsn => vsn
            );

--************************** Bi-directional EB Data Bus *****************************

    PLD_TP <= '0' WHEN (CPLD_Power_Up_nRESET_Count_Enable = '1') ELSE 'Z';  -- Add on 6-4-03 C.Vu
    nPOR   <= '0' WHEN (CPLD_Power_Up_nRESET_Count_Enable = '1') ELSE 'Z';  -- Add on 6-5-03 C.Vu

    EBD <= EBD_out WHEN (EB_nOE = '0' AND EB_nCS(2) = '0')
             ELSE FL_D WHEN (EB_nOE = '0' AND EB_nCS(3) = '0' AND Reg_9(1) = '1')
             ELSE (OTHERS => 'Z');

    EBD_in <= EBD WHEN (EB_nWE = '0' AND EB_nCS(2) = '0') ELSE "00000000";

    FL_D <= EBD WHEN (EB_nWE = '0' AND EB_nCS(3) = '0') ELSE "ZZZZZZZZ";

    FL_A <= EBA WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '0')
             ELSE "000000" WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '1')
             ELSE "ZZZZZZ";
    
    FL_nOE <= EB_nOE WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '0')
               ELSE '1' WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '1')
               ELSE 'Z';

    FL_nWE <= EB_nWE WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '0')
               ELSE '1' WHEN (Reg_9(1) = '1' AND EB_nCS(3) = '1')
               ELSE 'Z';
    
    FL_ON_OFF    <= Reg_9(1);
    FL_UNDEFINED <= Reg_9(4);

-- FPGA & CPLD bus temporary logic for compiling purpose only Feb-19-03 
--=============================================================================
--      FPGA_PLD_D        <= EBD        when (EB_nCS(2)= '0') 
--              else    "ZZZZZZZZ";
    FPGA_PLD_nOE <= EB_nOE WHEN (EB_nCS(2) = '0')
                     ELSE 'Z';
    FPGA_PLD_nWE <= EB_nWE WHEN (EB_nCS(2) = '0')
                     ELSE 'Z';
    FPGA_PLD_BUSY <= EB_nWE WHEN (EB_nCS(2) = '0')
                     ELSE 'Z';


    Reg_13 <= FPGA_PLD_D;
--==============================================================================


    BASE_MISO <= '0' WHEN (Reg_12(7) = '1' AND Reg_5 (1) = '1') ELSE 'Z';  -- changed by C.Vu 6-4-03



------
--      SC_nCS7   <=  Reg_8(1)          when (Reg_8(2) = '1')  else 'Z';
--      Reg_8(1)  <=  SC_nCS7   when (Reg_8(2) = '0')  else '0';
    SC_nCS7   <= 'Z'       WHEN Reg_4(7) = '1'    ELSE '0';  -- add by Thorsten on ~ 4-11-03
------
    AUX_CLT   <= Reg_10(7) WHEN (Reg_10(6) = '1') ELSE 'Z';  -- Write
    Reg_10(7) <= AUX_CLT   WHEN (Reg_10(6) = '0') ELSE '0';  -- Read as default

    Reg_11(4) <= Reg_11(1) OR DSR_Local;

--************************** Concurrent Statements **********************************

    SC_nCS0 <= Reg_4 (0);
    SC_nCS1 <= Reg_4 (1);
    SC_nCS2 <= Reg_4 (2);
    SC_nCS3 <= Reg_4 (3);
    SC_nCS4 <= Reg_4 (4);
    SC_nCS5 <= Reg_4 (5);
    SC_nCS6 <= Reg_4 (6);


    BASE_nCS0 <= Reg_5 (0);
    BASE_nCS1 <= Reg_5 (1);

    BASE_SClk <= Reg_6 (1);
    SC_SClk   <= Reg_6 (1);
    SC_MOSI   <= Reg_6 (2);
    BASE_MOSI <= Reg_6 (3);
    SC_CL     <= Reg_6 (5);


    BASE_On_Off      <= Reg_9 (0);
    Barometer_Enable <= Reg_9 (2);

--      Base Signals

    Mux_En0 <= Reg_10 (0);
    Mux_En1 <= Reg_10 (1);
    Sel_A0  <= Reg_10 (2);
    Sel_A1  <= Reg_10 (3);

    Reg_11 (0) <= Serial_Power;
    --      RxD                     <= '1' when ((Serial_Power = '0') or (Reg_11 (1) = '0'))
    --      else    RXD_Local;              
--      RxD                     <= RXD_Local when ((Serial_Power = '1') and (Reg_11 (1) = '1'))  
--   This line is temporary put in to by-pass Reg_11(1) 2/5/03 by Thorsten

-- When Ser_power is low, DOM communication through twisted pair with DOM Hub or Serrogate
-- When Ser_power is High, DOM communication through on board serial interface
    EX_RxD <= RXD_Local               WHEN ((Serial_Power = '1')) ELSE '1';
    EX_DSR <= DSR_Local AND Reg_11(1) WHEN ((Serial_Power = '1')) ELSE '1';
    EX_CTS <= CTS_Local               WHEN ((Serial_Power = '1')) ELSE '1';

    TxD_Local <= EX_TXD WHEN ((Serial_Power = '1')) ELSE 'Z';
    RTS_Local <= EX_RTS WHEN ((Serial_Power = '1')) ELSE 'Z';
    DTR_Local <= EX_DTR WHEN ((Serial_Power = '1')) ELSE 'Z';

-- Flash memory signals         
    Flash_nWP  <= '1';                  -- Write Protection active low
    Flash_nOE  <= EB_nOE;
    Flash_nWE  <= EB_nWE;
    Flash_nCS0 <= '0' WHEN ((NOT EB_nCS(0) AND EB_nCS(1) AND NOT Reg_15(0)) = '1') OR ((EB_nCS(0) AND NOT EB_nCS(1) AND Reg_15(0)) = '1')
                       ELSE '1';
    Flash_nCS1 <= '0' WHEN ((NOT EB_nCS(0) AND EB_nCS(1) AND Reg_15(0)) = '1') OR ((EB_nCS(0) AND NOT EB_nCS(1) AND NOT Reg_15(0)) = '1')
                       ELSE '1';
    
    Boot_Flash <= Reg_15(1) OR (NOT PLD_Mode);  -- Register 15-d1     
--      nConfig         <= '0'  when ( ( not Reg_15(3) and Reg_15(1)) = '1') else 'Z';  -- Register 15-d3
--      nConfig         <= '0'  when ( ( SW_reboot and Reg_15(1)) = '1') else 'Z';      -- Register 15-d3
    nConfig    <= '0' WHEN (SW_reboot = '1' OR FPGA_PLD_D(6) = '0') ELSE 'Z';  -- Register 15-d3
    Reset      <= nPOR;

    Int_Ext_pin_n <= '1';


--************************** EB Address Decode ***********************************
-- This process decodes the address and sets enables for the registers
    address_decode : PROCESS (reset, EB_Clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            Reg_enable <= "0000";
            -- Synchronize with falling edge of EBI clock
        ELSIF EB_Clk'EVENT AND (EB_Clk = '0') THEN
            IF EB_nCS(3 DOWNTO 2) = "10" THEN
                Reg_enable <= EBA(3 DOWNTO 0);
            ELSE
                Reg_enable <= "0000";
            END IF;
        END IF;
    END PROCESS;

--************************** nCONFIG pulse width ***********************************
-- This process to setup the nCONFIG pulse
    nCONFIG_pulse : PROCESS (reset, PLD_Clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            Reg_15(3) <= '1';
--       Reg_enable <= "0000";
            -- Synchronize with rising edge of PLD clock
        ELSIF PLD_Clk'EVENT AND (PLD_Clk = '1') THEN
--         if (Reg_15(1) and  (Reg_14(0) or not soft_reset)) = '1' then -- Recheck operation feb-19-03
--              Reg_15(3) <= '0';
--         elsif count = 15 then
--              Reg_15(3) <= '1';
--          end if; 
            IF count = 15 THEN          -- changed April-16-03
                Reg_15(3) <= '1';
--              elsif (Reg_15(1) and  (Reg_14(0) or not soft_reset)) = '1' then
            ELSIF (Reg_14(0) OR NOT soft_reset) = '1' THEN
                Reg_15(3) <= '0';
            END IF;
        END IF;
    END PROCESS;

--************************** nCONFIG count ***********************************
-- This process extend the nCONFIG pulse
    nCONFIG_count : PROCESS (reset, PLD_Clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            count <= "0000";
            -- Synchronize with falling edge of PLD clock
        ELSIF PLD_Clk'EVENT AND (PLD_Clk = '0') THEN
            IF Reg_15(3) = '0' THEN
                count <= count + 1;
            ELSE
                count <= "0000";
            END IF;
        END IF;
    END PROCESS;

--************************** nCONFIG delay ***********************************
-- This process to delay the nCONFIG pulse
    nConfig_delay : PROCESS (reset, PLD_Clk, count)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            SW_reboot <= '0';
            -- Synchronize with falling edge of PLD clock
        ELSIF PLD_Clk'EVENT AND (PLD_Clk = '0') THEN
            IF count > 5 THEN
                SW_reboot <= '1';
            ELSE
                SW_reboot <= '0';
            END IF;
        END IF;
    END PROCESS;

--************************** one wire cycle ***********************************
-- This process start the one wire cycle 
    one_wire_Cycle : PROCESS (reset, PLD_clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            One_Wire_Count_Enable <= '0';
            -- Synchronize with Rising edge of PLD clock
        ELSIF PLD_clk'EVENT AND (PLD_clk = '1') THEN
            IF Reg_12(3) = '1' THEN
                One_Wire_Count_Enable <= '1';
            ELSIF (one_wire_counter = 1400 AND Reg_12(2 DOWNTO 0) < "111") THEN
                One_Wire_Count_Enable <= '0';  -- stop count when command is not RESET
            ELSIF one_wire_counter = 19200 THEN
                One_Wire_Count_Enable <= '0';  -- stop count when Reset command
            END IF;
        END IF;
    END PROCESS;
--************************** one wire pulse width ***********************************
-- This process provide the one wire pulse width for different commands
    one_wire_pulse : PROCESS (reset, PLD_clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            Reg_12 (7 DOWNTO 6) <= "01";
            -- Synchronize with rising edge of PLD clock
        ELSIF PLD_clk'EVENT AND (PLD_clk = '1') THEN
            IF One_Wire_Count_Enable = '1' THEN  -- 
                
                IF one_wire_counter = 1 THEN
                    Reg_12(7) <= '1';  -- send the '0' to BASE_MISO at the start of each write command
                END IF;

                CASE Reg_12(2 DOWNTO 0) IS
                    WHEN "001" =>       -- finish write 1 puls
                        IF one_wire_counter = 120 THEN
                            Reg_12(7) <= '0';
                        END IF;
                    WHEN "010" =>       -- finish write 0 puls
                        IF one_wire_counter = 1400 THEN
                            Reg_12(7) <= '0';
                        END IF;
                    WHEN "011" =>       -- Read 1 bit puls
                        IF one_wire_counter = 120 THEN
                            Reg_12(7) <= '0';
                        END IF;
                        IF one_wire_counter = 300 THEN
                            Reg_12(6) <= BASE_MISO;  -- sampling the data line @ 15us for data
                        END IF;
                    WHEN "111" =>  -- Send out the Reset pulse & sampling the data line
                        IF one_wire_counter = 9600 THEN
                            Reg_12(7) <= '0';
                        END IF;
                        IF one_wire_counter = 11000 THEN
                            Reg_12(6) <= BASE_MISO;  -- sampling the data line @ 550us for slave
                        END IF;
                    WHEN OTHERS =>
                        Reg_12(7) <= '0';
                END CASE;

                IF one_wire_counter = 19200 THEN
                    Reg_12(7) <= '0';
                END IF;
                
            ELSE
                Reg_12(7) <= '0';
            END IF;  -- One_Wire_Count_Enable = '1'                                           
        END IF;  -- reset = RESET_ACTIVE    
    END PROCESS;
--************************** one wire counter ***********************************
-- This process provide the one wire counter for timing different pulse width
    one_wire_count : PROCESS (reset, PLD_clk)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            one_wire_counter <= "0000000000000000";
            -- Synchronize with falling edge of PLD clock
        ELSIF PLD_clk'EVENT AND (PLD_clk = '0') THEN
            IF One_Wire_Count_Enable = '1' THEN
                one_wire_counter <= one_wire_counter + 1;
            ELSE
                one_wire_counter <= "0000000000000000";
            END IF;
        END IF;
    END PROCESS;

--************************** CPLD_Power_Up_nRESET cycle ***********************************
-- This process start the CPLD_Power_Up_nRESET cycle 
    CPLD_Power_Up_nRESET_Cycle : PROCESS (reset, PLD_clk)
    BEGIN
        -- Synchronize with Rising edge of PLD clock
        IF PLD_clk'EVENT AND (PLD_clk = '1') THEN
            IF ((nPOR = '1') AND (CPLD_Power_Up_nRESET_Done = '0')) THEN
                CPLD_Power_Up_nRESET_Count_Enable <= '1';
            ELSIF (CPLD_Power_Up_nRESET_Done = '1') THEN
                CPLD_Power_Up_nRESET_Count_Enable <= '0';
            END IF;

            IF CPLD_Power_Up_nRESET_Counter = 30 THEN
                CPLD_Power_Up_nRESET_Done <= '1';
            ELSE
                CPLD_Power_Up_nRESET_Done <= '0';
            END IF;
        END IF;
    END PROCESS;
--************************** CPLD_Power_Up_nRESET counter ***********************************
-- This process provide nPOR reset pulse width from CPLD
    CPLD_Power_Up_nRESET_count : PROCESS (reset, PLD_clk)
    BEGIN
        -- Synchronize with falling edge of PLD clock
        IF PLD_clk'EVENT AND (PLD_clk = '0') THEN
            IF (CPLD_Power_Up_nRESET_Count_Enable = '1') THEN
                IF ((CPLD_Power_Up_nRESET_Done = '1') OR (CPLD_Power_Up_nRESET_Counter = 30)) THEN
                    CPLD_Power_Up_nRESET_Counter <= CPLD_Power_Up_nRESET_Counter;
                ELSE
                    CPLD_Power_Up_nRESET_Counter <= CPLD_Power_Up_nRESET_Counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

--************************** Read/Write to Register **********************************
-- This process Write to or Read from registers

    register_rw : PROCESS(EB_Clk, reset)
    BEGIN
        IF reset = RESET_ACTIVE THEN
            EBD_out            <= "00000000";
            --              Reg_4                   <= "11111111"; 
            Reg_4              <= "00000000";
            Reg_5              <= "11111111";
            Reg_6 (2 DOWNTO 0) <= "000";
            Reg_6 (7 DOWNTO 4) <= "0010";

            Reg_7 <= "00000000";

            Reg_8 <= "00000000";

            Reg_9 (7 DOWNTO 0) <= "00100000";

            Reg_10 (6 DOWNTO 0) <= "1000000";

            Reg_11 (1)         <= '0';
            Reg_11(7 DOWNTO 5) <= "000";

            Reg_12 (5 DOWNTO 0) <= "000000";  -- Temporary use for one wire command
            --      Reg_13          <= "00100000";  -- Spare

            Reg_14 <= "00000000";

            Reg_15 (1 DOWNTO 0) <= "10";
            --              Reg_15 (7 downto 4)     <= "0000" ;

            -- Synchronize with falling edge of clock
        ELSIF EB_Clk'EVENT AND (EB_Clk = '0') THEN

            -- Register 4
            IF Reg_enable = "0100" THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_4 <= EBD_in;
                ELSE
                    -- uC read
                    EBD_out(6 DOWNTO 0) <= Reg_4(6 DOWNTO 0);
                    EBD_out(7)          <= SC_nCS7;
                END IF;
            END IF;

            -- Register 5
            IF Reg_enable = "0101"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_5 <= EBD_in;
                ELSE
                    -- uC read
                    EBD_out <= Reg_5;
                END IF;
            END IF;

            -- Register 6
            IF Reg_enable = "0110"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    --         Reg_6      <=EBD_in;
                    Reg_6 (5 DOWNTO 0) <= EBD_in (5 DOWNTO 0);
                    Reg_6 (7)          <= EBD_in (7);
                ELSE
                    -- uC read
                    EBD_out (1 DOWNTO 0) <= Reg_6 (1 DOWNTO 0);
                    EBD_out (7 DOWNTO 4) <= Reg_6 (7 DOWNTO 4);
                    EBD_out(2)           <= SC_MISO;
                    EBD_out(3)           <= BASE_MISO;
                END IF;
            END IF;

            -- Register 7
            IF Reg_enable = "0111"THEN
                IF EB_nWE = '0' THEN
                    -- uC write 
                    Reg_7 <= EBD_in;
                ELSE
                    -- uC read
                    EBD_out <= Reg_7;
                END IF;
            END IF;

            -- Register 8 (Support Register 1)
            IF Reg_enable = "1000"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_8 <= EBD_in;
                ELSE
                    -- uC read
                    EBD_out <= Reg_8;
                END IF;
            END IF;

            -- Register 9 ( ) add on Feb-19-03 C.Vu
            IF Reg_enable = "1001"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
--                        Reg_8(0)     <=EBD_in(0);
                    Reg_9(7 DOWNTO 0) <= EBD_in(7 DOWNTO 0);
                ELSE
                    -- uC read
                    EBD_out <= Reg_9;
                END IF;
            END IF;


            -- Register 10 (ATWD Input Multiplexor Control)
            IF Reg_enable = "1010"THEN
                IF EB_nWE = '0' THEN
                    -- uC write                                    
                    Reg_10(6 DOWNTO 0) <= EBD_in(6 DOWNTO 0);
                ELSE
                    -- uC read
                    EBD_out <= Reg_10;
                END IF;
            END IF;

            -- Register 11 (Communication Control Register UART)
            IF Reg_enable = "1011"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_11(1)          <= EBD_in(1);
                    Reg_11(7 DOWNTO 5) <= EBD_in(7 DOWNTO 5);
                ELSE
                    -- uC read
                    EBD_out <= Reg_11;
                END IF;
            END IF;

            -- Register 12 (one wire command register)
            IF Reg_enable = "1100"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_12 (4 DOWNTO 0) <= EBD_in (4 DOWNTO 0);
                ELSE
                    Reg_12 (3) <= '0';  -- allow only momentary write into this bit
                    -- uC read
--                        EBI_data_out <= Reg_12 ;
                    EBD_out(5) <= One_Wire_Count_Enable;  -- status of 1-wire command busy bit (0=done, 1= busy)  
                    EBD_out(6) <= Reg_12 (6);
                END IF;
            END IF;

            -- Register 13 (for temporary to store data from CPU's FPGA)
            IF Reg_enable = "1101"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
--                        Reg_13      <=EBD_in; -- data from CPU's FPGA is stored in here
                ELSE
                    -- uC read
                    EBD_out <= Reg_13;
                END IF;
            END IF;

            -- Register 14 (ReBoot Control Register bit 0 write only)
            IF Reg_enable = "1110"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_14 <= EBD_in;
                ELSE
                    Reg_14  <= "00000000";
                    -- uC read
                    EBD_out <= Reg_14;
                END IF;
            END IF;

            -- Register 15 (Boot Configuration Register)
            IF Reg_enable = "1111"THEN
                IF EB_nWE = '0' THEN
                    -- uC write            
                    Reg_15(1 DOWNTO 0) <= EBD_in (1 DOWNTO 0);
--                        Reg_15(7 downto 4)      <=EBD_in (7 downto 4);                        
                ELSE
                    -- uC read
                    EBD_out(1 DOWNTO 0) <= Reg_15 (1 DOWNTO 0);

                    EBD_out(2) <= Init_Done;  -- Register 15-d2
                    EBD_out(4) <= Conf_Done;
                    EBD_out(6) <= nRESET;
                    EBD_out(7) <= nSTATUS;
                END IF;
            END IF;
            
        END IF;
    END PROCESS;

END EB_Interface_rev2_arch;
