#
# setup versioning...
#
all: version.vhd pld-version.h

build.num: Dom_Cpld_rev2.vhd
	touch build.num

version.vhd: api.num build.num
	./mkvsn.sh `cat api.num` `./getbld.sh`

pld-version.h: api.num build.num
	./mkhdr.sh `cat api.num` `cat build.num` > pld-version.h

