$(BUILD_DIR)/$(PUB_ROOT)/$(PROJECT)/pld-version.h : api.num build.num
	@test -d $(@D) || mkdir -p $(@D)
	./mkhdr.sh `cat api.num` `cat build.num` > $(@D)/$(*F).h
