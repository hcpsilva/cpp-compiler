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
SRC_DIR := src

BIN := etapa2
MAIN := stage-2.cc

.DEFAULT_GOAL = all

################################################################################
#	Rules:

all: compile

setup:
	rm -rf $(BUILD_DIR)
	-test -f main.c && mv main.c $(SRC_DIR)/$(MAIN)
	$(SCRIPT_DIR)/evil-code-injection.sh $(SRC_DIR)/$(MAIN)
	meson setup $(BUILD_DIR)

compile: setup
	meson compile -C $(BUILD_DIR)
	ln -fs $(shell readlink -f $(BUILD_DIR)/$(basename $(MAIN))) $(BIN)

release: ; $(SCRIPT_DIR)/release.sh
