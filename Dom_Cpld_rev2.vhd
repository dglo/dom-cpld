-- Project: Ice Cube                    -- Dom board rev 2 Cool Runner CPLD Programming
-- Author: C.Vu
-- Version : 1
--      Rev  : 0       Date: Feb-18-2003
--        (This is the modification of code in Ice_cube3 project on Feb-18-03)
--
--    Rev  : 1       Date: April-16-2003
--        - Add by Thorsten on ~ 4-11-03)
--           1) SC_nCS7   <=  'Z' WHEN Reg_4(7)='1' ELSE '0';   
--           2) Reg_4(7) in read register   
--               - Add by Chinh on ~ 4-16-03)
--           3) nCONFIG_pulse: process the if statement are
--              reversed order to alway clear the counter
--                - Add by Chinh on ~ 4-17-03)                                            
--           4) Add nCONFIG_delay: to delay the start of nCONFIG pulse 
--           5) change nCONFIG <=  --------------------
--    Rev   : 2          Date: June-4-2003
--             - Add by Arthur on 6-2-03
--           1) Add the one wire codes at Wisconsin
--              - Add by Chinh on 6-4-03
--           1) Change the MISO concurrent statement to be controlled by
--              both (Reg_12(7) = '1' and Reg_4 (1)='1')
--           2) Add CPLD_Power_Up_nRESET cycle to allow the CPLD to issue
--              the Reset pulse after it power up  
--      Documentations used:    
--           --Dom Schematics (V11.0)
--           --Excalibur devices Hardware Reference Manual pages (91-96)
--           -- DOM CPLD Description and API
--              (Gerald Przybylski v0.0 Nov-14-2002)
--
--      Compilation notes:
-- Compile the Cool Runner CPLD in binary coding to save FF since it does
-- not have a lot of FF 
--              
--============================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity EB_Interface_rev2 is
  port (
-- Excaliber EB
    EB_Clk  : in    std_logic;
    EB_nCS  : in    std_logic_vector (3 downto 0);
    EBA     : in    std_logic_vector (5 downto 0);
    EB_nOE  : in    std_logic;
    EBD     : inout std_logic_vector (7 downto 0);
    EB_nWE  : in    std_logic;
    PLD_Clk : in    std_logic;          -- Clock frequency = 20 MHz

-- Flasher board interface
    FL_D      : inout std_logic_vector (7 downto 0);
    FL_A      : out   std_logic_vector (5 downto 0);
    FL_nWE    : out   std_logic;
    FL_nOE    : out   std_logic;
    FL_ON_OFF : out   std_logic;
    FL_JTAGEN : out   std_logic;


-- Excalibur special pins
    Boot_Flash : out   std_logic;       -- Register 15-d1
    Init_Done  : in    std_logic;       -- Register 15-d2
    nConfig    : inout std_logic;       -- Register 15-d3       
    Conf_Done  : in    std_logic;       -- from CPU     to R15-d4       
    nRESET     : in    std_logic;       -- from CPU     to R15-d6
    nSTATUS    : inout std_logic;       -- from CPU to R15-d7
    nPOR       : inout std_logic;       --reg_14 power on reset switch
    soft_reset : in    std_logic;       -- normal High, push to Low, OR with Reg_14(0) to force nCONFIG down 

    FPGA_LOADED : in std_logic;         -- pin 75, from CPU, is the fpga loaded? (active low)
    COMM_RESET  : in std_logic;         -- pin 81, from CPU, is there a comm reset? (active low)

-- Barometer
    Barometer_Enable : out std_logic;   -- Register 9-d2

-- Input select Mux for ATWD
    Mux_En0 : out std_logic;            -- Register 10-d0  
    Mux_En1 : out std_logic;            -- Register 10-d1  
    Sel_A0  : out std_logic;            -- Register 10-d2 
    Sel_A1  : out std_logic;            -- Register 10-d3 



-- Flash Memory signals
    Flash_nWP  : out std_logic;           -- active low
--      Flash_Reset     : out STD_LOGIC;  -- active low 
    Flash_nWE  : out std_logic;           -- EBnWE
    Flash_nOE  : out std_logic;           -- EB_nOE
    Flash_nCS0 : out std_logic;           -- Register 15-d0
    Flash_nCS1 : out std_logic;           -- Register 15-d0


-- SPI/I2C/1-Wire Signals
    SC_nCS0 : out std_logic;            -- Register 4-d0
    SC_nCS1 : out std_logic;            -- Register 4-d1
    SC_nCS2 : out std_logic;            -- Register 4-d2
    SC_nCS3 : out std_logic;            -- Register 4-d3
    SC_nCS4 : out std_logic;            -- Register 4-d4
    SC_SClk : out std_logic;            -- Register 6-d1
    SC_CL   : out std_logic;            -- Register 6-d5        
    SC_MOSI : out std_logic;

-- ADC Signals ( ADC_Sclk = DAC_Sclk; ADC_Din = DAC_Din)
    SC_nCS5 : inout std_logic;
    SC_nCS6 : inout std_logic;
    SC_MISO : in    std_logic;          -- changed from OUT to IN on 1/30/03 C.Vu

-- BASE (High Voltage) Signals
    BASE_nCS0   : out   std_logic;      -- Register 5-d0
    BASE_nCS1   : out   std_logic;      -- Register 5-d1
    BASE_On_Off : out   std_logic;      -- Register 9-d0 (HV_PS-Enable)
    BASE_Sclk   : out   std_logic;      -- the same as sc_sclk
    BASE_MISO   : inout std_logic;
    BASE_MOSI   : out   std_logic;
-- Temperature Sensor
    SC_nCS7     : inout std_logic;      -- Register 8-d1 



-- UARTs Signals
    serial_power : in  std_logic;       -- IN from the pulldown, with jumper in = High
    RxD_Local    : in  std_logic;       -- IN from RS232 Tranceiver
    DSR_Local    : in  std_logic;       -- IN from RS232 Tranceiver 
    CTS_Local    : in  std_logic;       -- IN from RS232 Tranceiver
    TxD_Local    : out std_logic;       -- OUT to RS232 Tranceiver
    RTS_Local    : out std_logic;       -- OUT to RS232 Tranceiver
    DTR_Local    : out std_logic;       -- OUT to RS232 Tranceiver


    EX_TxD : in  std_logic;             -- Serial_Transmitter_Data      Register 11-d3  IN from Excalibur UART_TXD pin G21
    Ex_RTS : in  std_logic;             -- IN from Excalibur UART_TXD pin H21
    EX_DTR : in  std_logic;             -- IN from Excalibur UART_TXD pin J20                 
    EX_RxD : out std_logic;             -- Serial_Receiver_Data Register 11-d2 OUT to Excalibur UART_RXD pin F21
    EX_DSR : out std_logic;             -- OUT to Excalibur UART_RXD pin H22 
    EX_CTS : out std_logic;             -- OUT to Excalibur UART_RXD pin G22




-- Excalibur'FPGA & DOM's CPLD Signals
    Int_Ext_pin_n : out   std_logic;  -- ???  -- 1/30/03
    FPGA_PLD_nWE  : inout std_logic;
    FPGA_PLD_nOE  : inout std_logic;
    FPGA_PLD_BUSY : inout std_logic;
    FPGA_PLD_D    : inout std_logic_vector (7 downto 0);

-- Other Signals

    EB_nPOR : out std_logic;

    AUX_CLT : inout std_logic;          -- Register 10-d6       ( this is only one direction and depend on what ext device)     

    --PLD_Mode                : in STD_LOGIC;  -- normal High, jumper to Low,
    -- OR with Reg_15(1) to force reboot from flash memory
    Single_LED_ENABLE : out std_logic;
    BASE_HV_DISABLE   : out std_logic;
    PLD_TP            : in  std_logic   -- Last port of the Entity

-- Reset : in STD_LOGIC
    );
end EB_Interface_rev2;

architecture EB_Interface_rev2_arch of EB_Interface_rev2 is

  -- CPLD version number
  component version
    port (
      vsn : out std_logic_vector (31 downto 0));
  end component;

--**************************** Constants ***************************************
-- Set the active reset level
  constant RESET_ACTIVE : std_logic := '0';  -- default is active low reset

--**************************** Signal Definitions ***************************************

-- uc data bus signals
  signal uc_data_out : std_logic_vector(7 downto 0);  -- data to be output to 8051 
  signal Reg_4_en    : std_logic;
  signal Reg_5_en    : std_logic;

  signal Reg_enable : std_logic_vector(3 downto 0);

  signal Reg_4  : std_logic_vector(7 downto 0);  -- Chip select 0 Register 
  signal Reg_5  : std_logic_vector(7 downto 0);  -- Chip select 1 Register 
  signal Reg_6  : std_logic_vector(7 downto 0);
  signal Reg_7  : std_logic_vector(7 downto 0);
-- signal ADC0_Data :std_logic;         -- for Future use
-- signal       ADC1_Data               :std_logic;  -- for Future use
  signal Reg_8  : std_logic_vector(7 downto 0);
  signal Reg_9  : std_logic_vector(7 downto 0);
  signal Reg_10 : std_logic_vector(7 downto 0);
  signal Reg_11 : std_logic_vector(7 downto 0);
  signal Reg_12 : std_logic_vector(7 downto 0);  -- temporary use for one wire commands
  signal Reg_13 : std_logic_vector(7 downto 0);
  signal Reg_14 : std_logic_vector(7 downto 0);  -- Reboot control register 
  signal Reg_15 : std_logic_vector(7 downto 0);  -- Boot configuration register

  signal EBD_in                : std_logic_vector(7 downto 0);
  signal EBD_out               : std_logic_vector(7 downto 0);
  signal Reset                 : std_logic;
  signal CPU_Reboot_Pulse      : std_logic;
  signal count                 : unsigned(3 downto 0);
  signal one_wire_counter      : unsigned(15 downto 0);
  signal One_Wire_Count_Enable : std_logic;
  signal SW_reboot             : std_logic;  -- to delay the nConfig signal 

  signal vsn : std_logic_vector (31 downto 0);

  signal nPOR_flag, nCONFIG_flag, nRESET_flag, reg15enable, nCOMM_RESET_flag : std_logic;

  -- when we start rebooting
  signal rebooting_flag : std_logic;
  
  -- signal for nCONFIG delay after nPOR
  signal nCONFIG_nPOR_delay : std_logic;
  signal nSTATUS_nPOR_delay : std_logic;

--**************************** Start ***************************************
begin

  EB_nPOR <= nPOR;

  inst_version : version
    port map (
      vsn => vsn);


--************************** Bi-directional EB Data Bus *******************

  EBD <= EBD_out     when (EB_nOE = '0' and EB_nCS(2) = '0')
           else FL_D when (EB_nOE = '0' and EB_nCS(3) = '0' and Reg_9(1) = '1')
           else (others => 'Z');

  EBD_in <= EBD when (EB_nWE = '0' and EB_nCS(2) = '0') else "00000000";

  FL_D <= EBD when (EB_nWE = '0' and EB_nCS(3) = '0') else "ZZZZZZZZ";

  FL_A <= EBA            when (Reg_9(1) = '1' and EB_nCS(3) = '0')
           else "000000" when (Reg_9(1) = '1' and EB_nCS(3) = '1')
           else "ZZZZZZ";

  FL_nOE <= EB_nOE    when (Reg_9(1) = '1' and EB_nCS(3) = '0')
             else '1' when (Reg_9(1) = '1' and EB_nCS(3) = '1')
             else 'Z';

  FL_nWE <= EB_nWE    when (Reg_9(1) = '1' and EB_nCS(3) = '0')
             else '1' when (Reg_9(1) = '1' and EB_nCS(3) = '1')
             else 'Z';

  FL_ON_OFF <= Reg_9(1);
  FL_JTAGEN <= Reg_9(4);

-- FPGA & CPLD bus temporary logic for compiling purpose only Feb-19-03
--=============================================================================
-- FPGA_PLD_D <= EBD when (EB_nCS(2)= '0')
-- else "ZZZZZZZZ";
  FPGA_PLD_nOE  <= EB_nOE when (EB_nCS(2) = '0')
                   else 'Z';
  FPGA_PLD_nWE  <= EB_nWE when (EB_nCS(2) = '0')
                   else 'Z';
  FPGA_PLD_BUSY <= EB_nWE when (EB_nCS(2) = '0')
                   else 'Z';


  Reg_13 <= FPGA_PLD_D;
--==============================================================================


  BASE_MISO <= '0' when (Reg_12(7) = '1' and Reg_5 (1) = '1') else 'Z';  -- changed by C.Vu 6-4-03



------
-- SC_nCS7 <= Reg_8(1) when (Reg_8(2) = '1') else 'Z';
-- Reg_8(1) <= SC_nCS7 when (Reg_8(2) = '0') else '0';
  SC_nCS7   <= 'Z'       when Reg_4(7) = '1'    else '0';  -- add by Thorsten on ~ 4-11-03
------
  AUX_CLT   <= Reg_10(7) when (Reg_10(6) = '1') else 'Z';  -- Write
  Reg_10(7) <= AUX_CLT   when (Reg_10(6) = '0') else '0';  -- Read as default

  Reg_11(4) <= Reg_11(1) or DSR_Local;

--************************** Concurrent Statements **********************************

  SC_nCS0 <= Reg_4 (0);
  SC_nCS1 <= Reg_4 (1);
  SC_nCS2 <= Reg_4 (2);
  SC_nCS3 <= Reg_4 (3);
  SC_nCS4 <= Reg_4 (4);

  -- adc "chip selects" are open drain to support i2c...
  SC_nCS5 <= 'Z' when Reg_4(5) = '1' else '0';
  SC_nCS6 <= 'Z' when Reg_4(6) = '1' else '0';

  BASE_nCS0       <= Reg_5 (0);
  BASE_nCS1       <= Reg_5 (1);
  BASE_HV_DISABLE <= Reg_7 (1);

  BASE_SClk <= Reg_6 (1);
  SC_SClk   <= Reg_6 (1);
  SC_MOSI   <= Reg_6 (2);
  BASE_MOSI <= Reg_6 (3);
  SC_CL     <= Reg_6 (5);


  BASE_On_Off       <= Reg_9 (0);
  Barometer_Enable  <= Reg_9 (2);
  Single_LED_ENABLE <= Reg_9 (3);

-- Base Signals

  Mux_En0 <= not Reg_10 (0);
  Mux_En1 <= not Reg_10 (1);
  Sel_A0  <= Reg_10 (2);
  Sel_A1  <= Reg_10 (3);

  Reg_11 (0) <= Serial_Power;
  --      RxD                     <= '1' when ((Serial_Power = '0') or (Reg_11 (1) = '0'))
  --      else    RXD_Local;              
--      RxD                     <= RXD_Local when ((Serial_Power = '1') and (Reg_11 (1) = '1'))  
--   This line is temporary put in to by-pass Reg_11(1) 2/5/03 by Thorsten

-- When Ser_power is low, DOM communication through twisted pair with DOM Hub or Serrogate
-- When Ser_power is High, DOM communication through on board serial interface
  EX_RxD <= RXD_Local               when ((Serial_Power = '1')) else '1';
  EX_DSR <= DSR_Local and Reg_11(1) when ((Serial_Power = '1')) else '1';
  EX_CTS <= CTS_Local               when ((Serial_Power = '1')) else '1';

  TxD_Local <= EX_TXD when ((Serial_Power = '1')) else 'Z';
  RTS_Local <= EX_RTS when ((Serial_Power = '1')) else 'Z';
  DTR_Local <= EX_DTR when ((Serial_Power = '1')) else 'Z';

-- Flash memory signals
  Flash_nWP  <= '1';                    -- Write Protection active low
  Flash_nOE  <= EB_nOE;
  Flash_nWE  <= EB_nWE;
  Flash_nCS0 <= '0' when ((not EB_nCS(0) and EB_nCS(1) and not Reg_15(0) ) = '1') or ((EB_nCS(0) and not EB_nCS(1) and Reg_15(0) ) = '1')
                     else '1';
  Flash_nCS1 <= '0' when ((not EB_nCS(0) and EB_nCS(1) and Reg_15(0) ) = '1') or ((EB_nCS(0) and not EB_nCS(1) and not Reg_15(0) ) = '1')
                     else '1';

  Boot_Flash <= Reg_15(1) or (not PLD_TP);  -- Register 15-d1     
  nConfig    <= '0' when ( SW_reboot = '1' or nCONFIG_nPOR_delay = '1') else 'Z';
  nSTATUS    <= '0' when nSTATUS_nPOR_delay = '1' else 'Z';
  Reset      <= nPOR;

  Int_Ext_pin_n <= '1';

--************************** nCONFIG/nSTATUS delay ******************************
  process (reset, PLD_CLK)
    variable nCONFIG_delay_cnt : integer range 0 to 255;
  begin  -- process
    if reset = RESET_ACTIVE then
      nCONFIG_nPOR_delay   <= '1';
      nSTATUS_nPOR_delay   <= '1';
      nCONFIG_delay_cnt   := 0;
    elsif PLD_CLK'event and PLD_CLK = '1' then
      if nCONFIG_delay_cnt < 200 then
        nCONFIG_nPOR_delay <= '1';
      else
        nCONFIG_nPOR_delay <= '0';          
      end if;
      if nCONFIG_delay_cnt < 250 then
        nSTATUS_nPOR_delay <= '1';
      else
        nSTATUS_nPOR_delay <= '0';          
      end if;
      if nCONFIG_delay_cnt < 255 then
        nCONFIG_delay_cnt := nCONFIG_delay_cnt + 1;
      end if;
    end if;
  end process;


--************************** EB Address Decode **************************
-- This process decodes the address and sets enables for the registers
  address_decode : process (reset, EB_Clk)
  begin
    if reset = RESET_ACTIVE then
      Reg_enable   <= "0000";
      -- Synchronize with falling edge of EBI clock
    elsif EB_Clk'event and (EB_Clk = '0') then
      if EB_nCS(3 downto 2) = "10" then
        Reg_enable <= EBA(3 downto 0);
      else
        Reg_enable <= "0000";
      end if;
    end if;
  end process;

--************************** nCONFIG pulse width ************************
-- This process to setup the nCONFIG pulse
  nCONFIG_pulse : process (reset, PLD_Clk)
  begin
    if reset = RESET_ACTIVE then
      rebooting_flag <= '0';
      Reg_15(3)   <= '1';
      -- Synchronize with rising edge of PLD clock
    elsif PLD_Clk'event and (PLD_Clk = '1') then
      if count = 15 then
        Reg_15(3) <= '1';
        rebooting_flag <= '0';
      elsif (Reg_14(0) or not soft_reset) = '1' or COMM_RESET = '0' then
        Reg_15(3) <= '0';
        rebooting_flag <= '1';
      end if;
    end if;
  end process;

--************************** nCONFIG count ***********************************
-- This process extend the nCONFIG pulse
  nCONFIG_count : process (reset, PLD_Clk)
  begin
    if reset = RESET_ACTIVE then
      count   <= "0000";
      -- Synchronize with falling edge of PLD clock
    elsif PLD_Clk'event and (PLD_Clk = '0') then
      if Reg_15(3) = '0' then
        count <= count + 1;
      else
        count <= "0000";
      end if;
    end if;
  end process;

--************************** nCONFIG delay ***********************************
-- This process to delay the nCONFIG pulse
  nConfig_delay : process (reset, PLD_Clk, count)
  begin
    if reset = RESET_ACTIVE then
      SW_reboot   <= '0';
      -- Synchronize with falling edge of PLD clock
    elsif PLD_Clk'event and (PLD_Clk = '0') then
      if count > 5 then
        SW_reboot <= '1';
      else
        SW_reboot <= '0';
      end if;
    end if;
  end process;

--************************** one wire cycle ***********************************
-- This process start the one wire cycle
  one_wire_Cycle : process (reset, PLD_clk)
  begin
    if reset = RESET_ACTIVE then
      One_Wire_Count_Enable   <= '0';
      -- Synchronize with Rising edge of PLD clock
    elsif PLD_clk'event and (PLD_clk = '1') then
      if Reg_12(3) = '1' then
        One_Wire_Count_Enable <= '1';
      elsif (one_wire_counter = 1400 and Reg_12(2 downto 0) < "111" ) then
        One_Wire_Count_Enable <= '0';   -- stop count when command is not RESET
      elsif one_wire_counter = 19200 then
        One_Wire_Count_Enable <= '0';   -- stop count when Reset command
      end if;
    end if;
  end process;
--************************** one wire pulse width ***********************************
-- This process provide the one wire pulse width for different commands
  one_wire_pulse : process (reset, PLD_clk)
  begin
    if reset = RESET_ACTIVE then
      Reg_12 (7 downto 6)     <= "01";
      -- Synchronize with rising edge of PLD clock
    elsif PLD_clk'event and (PLD_clk = '1') then
      if One_Wire_Count_Enable = '1' then  -- 

        if one_wire_counter = 1 then
          Reg_12(7) <= '1';             -- send the '0' to BASE_MISO at the start of each write command
        end if;

        case Reg_12(2 downto 0) is
          when "001"  =>                -- finish write 1 puls
            if one_wire_counter = 120 then
              Reg_12(7) <= '0';
            end if;
          when "010"  =>                -- finish write 0 puls
            if one_wire_counter = 1400 then
              Reg_12(7) <= '0';
            end if;
          when "011"  =>                -- Read 1 bit puls
            if one_wire_counter = 120 then
              Reg_12(7) <= '0';
            end if;
            if one_wire_counter = 300 then
              Reg_12(6) <= BASE_MISO;   -- sampling the data line @ 15us for data
            end if;
          when "111"  =>                -- Send out the Reset pulse & sampling the data line
            if one_wire_counter = 9600 then
              Reg_12(7) <= '0';
            end if;
            if one_wire_counter = 11000 then
              Reg_12(6) <= BASE_MISO;   -- sampling the data line @ 550us for slave
            end if;
          when others =>
            Reg_12(7)   <= '0';
        end case;

        if one_wire_counter = 19200 then
          Reg_12(7) <= '0';
        end if;

      else
        Reg_12(7)        <= '0';
      end if;  -- One_Wire_Count_Enable = '1'                                           
    end if;  -- reset = RESET_ACTIVE    
  end process;
--************************** one wire counter ***********************************
-- This process provide the one wire counter for timing different pulse width
  one_wire_count : process (reset, PLD_clk)
  begin
    if reset = RESET_ACTIVE then
      one_wire_counter   <= "0000000000000000";
      -- Synchronize with falling edge of PLD clock
    elsif PLD_clk'event and (PLD_clk = '0') then
      if One_Wire_Count_Enable = '1' then
        one_wire_counter <= one_wire_counter + 1;
      else
        one_wire_counter <= "0000000000000000";
      end if;
    end if;
  end process;

--************************** Read/Write to Register **********************************
-- This process Write to or Read from registers

  register_rw : process(EB_Clk, reset, nPOR, nCONFIG, nRESET, COMM_RESET)
  begin
    if reset = RESET_ACTIVE then
      EBD_out            <= "00000000";
      --              Reg_4                   <= "11111111"; 
      Reg_4              <= "00000000";
      Reg_5              <= "11111111";
      Reg_6 (2 downto 0) <= "000";
      Reg_6 (7 downto 4) <= "0010";

      Reg_7 <= "00000000";

      Reg_8 <= "00000000";

      Reg_9 (7 downto 0) <= "00100000";

      Reg_10 (6 downto 0) <= "1000000";

      Reg_11 (1)         <= '0';
      Reg_11(7 downto 5) <= "000";

      Reg_12 (5 downto 0) <= "000000";  -- Temporary use for one wire command
      --      Reg_13          <= "00100000";  -- Spare

      Reg_14 <= "00000000";

      Reg_15 (1 downto 0) <= "00";      -- changed to boot from config as default                   
      --              Reg_15 (7 downto 4)     <= "0000" ;

      -- Synchronize with falling edge of clock
    elsif EB_Clk'event and (EB_Clk = '0') then

      -- Register 0
      if Reg_enable = "0000" then
        if EB_nWE = '1' then
          -- uC read
          EBD_out <= vsn(7 downto 0);
        end if;
      end if;

      -- Register 1
      if Reg_enable = "0001" then
        if EB_nWE = '1' then
          -- uC read
          EBD_out <= vsn(15 downto 8);
        end if;
      end if;

      -- Register 2
      if Reg_enable = "0010" then
        if EB_nWE = '1' then
          -- uC read
          EBD_out <= vsn(23 downto 16);
        end if;
      end if;

      -- Register 3 (this register is optional 8 bits of
      -- api number is fine, we'll lv it here for now)
      if Reg_enable = "0011" then
        if EB_nWE = '1' then
          -- uC read
          EBD_out <= vsn(31 downto 24);
        end if;
      end if;

      -- Register 4
      if Reg_enable = "0100" then
        if EB_nWE = '0' then
          -- uC write            
          Reg_4               <= EBD_in;
        else
          -- uC read
          EBD_out(4 downto 0) <= Reg_4(4 downto 0);
          EBD_out(5)          <= SC_nCS5;
          EBD_out(6)          <= SC_nCS6;
          EBD_out(7)          <= SC_nCS7;
        end if;
      end if;

      -- Register 5
      if Reg_enable = "0101"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_5   <= EBD_in;
        else
          -- uC read
          EBD_out <= Reg_5;
        end if;
      end if;

      -- Register 6
      if Reg_enable = "0110"then
        if EB_nWE = '0' then
          -- uC write            
          --         Reg_6      <=EBD_in;
          Reg_6 (5 downto 0)   <= EBD_in (5 downto 0);
          Reg_6 (7)            <= EBD_in (7);
        else
          -- uC read
          EBD_out (1 downto 0) <= Reg_6 (1 downto 0);
          EBD_out (7 downto 4) <= Reg_6 (7 downto 4);
          EBD_out(2)           <= SC_MISO;
          EBD_out(3)           <= BASE_MISO;
        end if;
      end if;

      -- Register 7
      if Reg_enable = "0111"then
        if EB_nWE = '0' then
          -- uC write 
          Reg_7 (7 downto 1)   <= EBD_in (7 downto 1);
        else
          -- uC read
          EBD_out (7 downto 1) <= Reg_7 (7 downto 1);
          EBD_out(0)           <= FPGA_LOADED;
        end if;
      end if;

      -- Register 8 (Support Register 1)
      if Reg_enable = "1000"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_8   <= EBD_in;
        else
          -- uC read
          EBD_out <= Reg_8;
        end if;
      end if;

      -- Register 9 ( ) add on Feb-19-03 C.Vu
      if Reg_enable = "1001"then
        if EB_nWE = '0' then
          -- uC write            
--                        Reg_8(0)     <=EBD_in(0);
          Reg_9(7 downto 0) <= EBD_in(7 downto 0);
        else
          -- uC read
          EBD_out           <= Reg_9;
        end if;
      end if;


      -- Register 10 (ATWD Input Multiplexor Control)
      if Reg_enable = "1010"then
        if EB_nWE = '0' then
          -- uC write                                    
          Reg_10(6 downto 0) <= EBD_in(6 downto 0);
        else
          -- uC read
          EBD_out            <= Reg_10;
        end if;
      end if;

      -- Register 11 (Communication Control Register UART)
      if Reg_enable = "1011"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_11(1)          <= EBD_in(1);
          Reg_11(7 downto 5) <= EBD_in(7 downto 5);
        else
          -- uC read
          EBD_out            <= Reg_11;
        end if;
      end if;

      -- Register 12 (one wire command register)
      if Reg_enable = "1100"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_12 (4 downto 0) <= EBD_in (4 downto 0);
        else
          Reg_12 (3)          <= '0';   -- allow only momentary write into this bit
          -- uC read
--                        EBI_data_out <= Reg_12 ;
          EBD_out(5)          <= One_Wire_Count_Enable;  -- status of 1-wire command busy bit (0=done, 1= busy)  
          EBD_out(6)          <= Reg_12 (6);
        end if;
      end if;

      -- Register 13 (for temporary to store data from CPU's FPGA)
      if Reg_enable = "1101"then
        if EB_nWE = '0' then
          -- uC write            
--                        Reg_13      <=EBD_in;  -- data from CPU's FPGA is stored in here
        else
          -- uC read
          EBD_out <= Reg_13;
        end if;
      end if;

      -- Register 14 (ReBoot Control Register bit 0 write only)
      if Reg_enable = "1110"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_14  <= EBD_in;
        else
          Reg_14  <= "00000000";
          -- uC read
          EBD_out <= Reg_14;
        end if;
      end if;

      -- Register 15 (Boot Configuration Register)
      if Reg_enable = "1111"then
        if EB_nWE = '0' then
          -- uC write            
          Reg_15(1 downto 0)  <= EBD_in (1 downto 0);
-- Reg_15(7 downto 4) <=EBD_in (7 downto 4);
        else
          -- uC read
          EBD_out(1 downto 0) <= Reg_15 (1 downto 0);

          EBD_out(2) <= Init_Done;         -- Register 15-d2
          EBD_out(3) <= nCONFIG_flag;
          EBD_out(4) <= Conf_Done;
          EBD_out(5) <= nPOR_flag;
          EBD_out(6) <= nRESET_flag;
          EBD_out(7) <= nCOMM_RESET_flag;  -- nSTATUS     
        end if;

      end if;

      if reg15enable = '1' and reg_enable/="1111" and EB_nWE = '1' then
        nRESET_flag      <= '0';
        nPOR_flag        <= '0';
        nCONFIG_flag     <= '0';
        nCOMM_RESET_flag <= '0';
      end if;
      if reg_enable = "1111" then
        reg15enable      <= '1';
      else
        reg15enable      <= '0';
      end if;

    end if;

    if nPOR = '0' then
      nPOR_flag        <= '1';
    end if;
    if nRESET = '0' then
      nRESET_flag      <= '1';
    end if;
    if nCONFIG = '0' then
      nCONFIG_flag     <= '1';
    end if;
    if COMM_RESET = '0' then
      nCOMM_RESET_flag <= '1';
    end if;

    if rebooting_flag = '1' then
      reg_9(1) <= '0';                  -- when rebooting turn off flasher
    end if;
    
  end process;

end EB_Interface_rev2_arch;

