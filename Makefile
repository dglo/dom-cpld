#
# setup versioning...
#
all: pld-version.h version.vhd

build.num: Dom_Cpld_rev2.vhd
	./getbld.sh

version.vhd: api.num build.num
	./mkvsn.sh `cat api.num` `cat build.num`

pld-version.h: api.num build.num
	./mkhdr.sh `cat api.num` `cat build.num` > pld-version.h

