##	\file Makefile
#	ccompiler's project Makefile.
#
#	Utilization example:
#		make <TARGET>
#
#	\param TARGET
#		Can be any of the following:
#		all - builds the project (DEFAULT TARGET)
#		clean - cleans up all binaries generated during compilation
#		release - cleans and compresses the work directory for release
#
#	\author @hcpsilva - Henrique Silva
#
#	Make's default action is "all" when no parameters are provided.

BUILD_DIR := build
SCRIPT_DIR := script

BIN := etapa1

.DEFAULT_GOAL = all

################################################################################
#	Rules:

all: compile

setup:
	rm -rf $(BUILD_DIR)
	-test -f main.c && mv main.c main.cpp
	meson setup $(BUILD_DIR)

compile: setup
	ninja -C $(BUILD_DIR)
	@ln -fs $(shell readlink -f $(BUILD_DIR)/$(BIN)) $(BIN)

release: ; $(SCRIPT_DIR)/release.sh
