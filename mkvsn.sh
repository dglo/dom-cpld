#!/bin/sh -f

vsn=`expr $1 * 65535 + $2`
sed "/conv_std_logic_vector/ s/[0-9]* ,/${vsn} ,/1" version.vhd > t.vhd
mv t.vhd version.vhd

