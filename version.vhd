-------------------------------------------------------------------------------
-- Title      : IceCube DOMMB CPLD
-- Project    : IceCube
-------------------------------------------------------------------------------
-- File       : version.vhd
-- Author     :   thorsten
-- Company    : 
-- Created    : 2003-10-27
-- Last update: 2003-10-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Version number for the CPLD
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-10-27  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY version IS
    PORT (
        vsn : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)  -- version number
        );
END version;

ARCHITECTURE arch_version OF version IS

BEGIN  -- arch_version

    --- this line is automatically updated, don't edit it...
    vsn <= conv_std_logic_vector (196628 , 32);

END arch_version;
