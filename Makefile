# Linux makefile for device simulation layer
# https://github.com/LunarG/VulkanTools.git
# mikew@lunarg.com

RELEASE_DIR  = build
DEBUG_DIR    = dbuild
SUBMOD_TIMESTAMP = submodules/TIMESTAMP

PROJ_NAME = device_simulation
RELEASE_TARGET = $(RELEASE_DIR)/layersvt/libVkLayer_$(PROJ_NAME).so
DEBUG_TARGET   = $(DEBUG_DIR)/layersvt/libVkLayer_$(PROJ_NAME).so

CMAKE = cmake
# -DCMAKE_SKIP_RPATH:BOOL=ON
# -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
# -DCMAKE_RULE_MESSAGES:BOOL=OFF


.DELETE_ON_ERROR: $(RELEASE_TARGET) $(DEBUG_TARGET)


.PHONY: all
all: $(RELEASE_TARGET) $(DEBUG_TARGET)

$(RELEASE_DIR): $(SUBMOD_TIMESTAMP)
	$(CMAKE) -H. -B$@ -DCMAKE_BUILD_TYPE=Release

$(DEBUG_DIR): $(SUBMOD_TIMESTAMP)
	$(CMAKE) -H. -B$@ -DCMAKE_BUILD_TYPE=Debug

$(RELEASE_TARGET): $(RELEASE_DIR) layersvt/$(PROJ_NAME).cpp
	$(MAKE) -C $(RELEASE_DIR)

$(DEBUG_TARGET): $(DEBUG_DIR) layersvt/$(PROJ_NAME).cpp
	$(MAKE) -C $(DEBUG_DIR)


.PHONY: extern
extern $(SUBMOD_TIMESTAMP):
	rm -f $(SUBMOD_TIMESTAMP)
	./update_external_sources.sh
	touch $(SUBMOD_TIMESTAMP)

.PHONY: test_release
test_release: $(RELEASE_TARGET)
	$(RELEASE_DIR)/tests/devsim_layer_test.sh

.PHONY: test_debug
test_debug: $(DEBUG_TARGET)
	$(DEBUG_DIR)/tests/devsim_layer_test.sh

.PHONY: t test
t test: test_release test_debug

.PHONY: clean
clean:
	-rm -f $(RELEASE_TARGET)
	-rm -f $(DEBUG_TARGET)
	-rm -f $(RELEASE_DIR)/layersvt/CMakeFiles/VkLayer_$(PROJ_NAME).dir/*.o
	-rm -f $(DEBUG_DIR)/layersvt/CMakeFiles/VkLayer_$(PROJ_NAME).dir/*.o

.PHONY: clobber
clobber: clean
	-rm -rf $(RELEASE_DIR)
	-rm -rf $(DEBUG_DIR)

.PHONY: nuke
nuke: clobber
	-rm -rf submodules

# vim: set sw=4 ts=8 noet ic ai:
