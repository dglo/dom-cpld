#!/bin/bash

#
# set part here...
#
#part=xc2c256-7-TQ144
part=xc2c384-10-TQ144

if [[ ! -d __projnav ]]; then
	mkdir __projnav
fi

if ! xst -quiet -ifn eb_interface_rev2.xst -ofn eb_interface_rev2.syr; then
    echo "unable to xst"
    exit 1
fi

if ! ngdbuild -dd _ngo -uc Dom_Cpld_rev2_Test_02.ucf -p xbr eb_interface_rev2.ngc eb_interface_rev2.ngd; 
    then
    echo "unable to ngdbuild"
    exit 1
fi

if ! cpldfit -p ${part} -ofmt vhdl -optimize density -keepio -loc on -slew slow -init low -inputs 32 -inreg on -blkfanin 38 -pterms 28 -unused keeper -terminate keeper -iostd LVCMOS33 eb_interface_rev2.ngd; then
    echo "unable to cpldfit"
    exit 1
fi

if ! taengine -f eb_interface_rev2 -l eb_interface_rev2.tim  -e __projnav\taengine.err; then
    echo "unable to taengine"
    exit 1
fi

if ! hprep6 -s IEEE1149 -i eb_interface_rev2; then
    echo "unable to hprep6"
    exit 1
fi

