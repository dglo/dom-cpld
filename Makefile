#
# setup versioning...
#
all: version.vhd

build.num: Dom_Cpld_rev2.vhd
	touch build.num

version.vhd: api.num build.num
	./mkvsn.sh `cat api.num` `./getbld.sh`

