#!/bin/bash

if [[ ! -d __projnav ]]; then
	mkdir __projnav
fi

xst -quiet -ifn eb_interface_rev2.xst -ofn eb_interface_rev2.syr
ngdbuild -dd _ngo -uc Dom_Cpld_rev2_Test_02.ucf -p xbr eb_interface_rev2.ngc eb_interface_rev2.ngd
cpldfit -p xc2c256-7-TQ144 -ofmt vhdl -optimize density -keepio -loc on -slew slow -init low -inputs 32 -inreg on -blkfanin 38 -pterms 28 -unused keeper -terminate keeper -iostd LVCMOS33 eb_interface_rev2.ngd
taengine -f eb_interface_rev2 -l eb_interface_rev2.tim  -e __projnav\taengine.err
hprep6 -s IEEE1149 -i eb_interface_rev2
