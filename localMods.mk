ifeq ("epxa10","$(strip $(PLATFORM))")
  BUILT_FILES += $(BUILD_DIR)/$(PUB_ROOT)/$(PROJECT)/pld-version.h
endif
