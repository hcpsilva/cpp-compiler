##	-- ccompiler --
#
#	ccompiler's project Makefile.
#
#	Utilization example:
#		make <TARGET> ["DEBUG=true"] ["VERBOSE=true"]
#
#	\param TARGET
#		Can be any of the following:
#		all - builds the project (DEFAULT TARGET)
#		clean - cleans up all binaries generated during compilation
#		redo - cleans up and then builds
#		help - shows the utilization example
#		test - builds and run tests
#		tool - generates compile_commands.json
#		release - cleans and compresses the work directory for release
#
#	\param "DEBUG=true"
#		When present, the build will happen in debug mode.
#
#	\param "VERBOSE=true"
#		When present, the final executable will be more verbose.
#
#	\author @hcpsilva - Henrique Silva
#
#	Make's default action is "all" when no parameters are provided.


################################################################################
#	Definitions:

#	- Release build:
#	Don't touch this variable, let the release script handle it. That
#	is, it's only here for documentation purposes.
RELEASE ?=

#	- Project's directories:
INC_DIR := include
OBJ_DIR := bin
OUT_DIR := build
SRC_DIR := src
LIB_DIR := lib
TST_DIR := test
DOC_DIR := doc

#	- Compilation flags:
#	Compiler and language version
CC := clang++ -std=c++17
LEX := flex
#	CFLAGS contains some basic sanity warning flags besides the eventual
#	preprocessor definition or debug flag.
CFLAGS :=\
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wshadow \
	-Wunreachable-code \
	-Wno-deprecated
#	If DEBUG is defined, we'll turn on the debug flag and attach address
#	sanitizer on the executables.
CFLAGS += $(if $(DEBUG),-g -fsanitize=address -DDEBUG)
CFLAGS += $(if $(VERBOSE),-DVERBOSE)
#	Feature flags for the lex program
LFLAGS := --nomain
LFLAGS += $(if $(DEBUG),-d)
#	Optimize if we aren't debugging
OPT := $(if $(DEBUG),-O0,-O3 -march=native)
#	Lookup directories
LIB := -L$(LIB_DIR)
INC := -I$(INC_DIR)

#	- Release version:
VERSION := etapa1

################################################################################
#	Files:

#	- Main source files:
#	I used to presume that all "main" source files are in the root of SRC_DIR,
#	but it's better to be safe about this
MAIN := main.c

#	- Path to all final binaries:

TARGET := $(MAIN:%.c=$(OUT_DIR)/%)

#	- Lex files:
LSRC := $(shell find $(SRC_DIR) -name '*.l')
LSRC := $(LSRC:.l=.yy.cpp)

#	- Other source files:
CSRC := $(shell find $(SRC_DIR) -name '*.cpp')
CSRC := $(filter-out $(MAIN) $(LSRC),$(CSRC)) $(LSRC)

#	- Objects to be created:
OBJ := $(CSRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

#	- Include directories to be used in the release main.c
INCMAIN := $(shell find $(INC_DIR) -mindepth 1 -type d)
INCMAIN := $(INCMAIN:%=-I%)

################################################################################
#	Rules:

#	- Executables:
$(TARGET): $(OUT_DIR)/%: %.c $(OBJ)
	$(CC) -o $@ $^ $(INC) $(INCMAIN) $(CFLAGS) $(OPT) $(LIB)

#	- Generated lexer source:
$(LSRC): %.yy.cpp: %.l
	$(LEX) $(LFLAGS) -o $@ $<

#	- Objects:
$(OBJ): $(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CC) -c -o $@ $< $(INC) $(CFLAGS) $(OPT)

################################################################################
#	Targets:

.DEFAULT_GOAL = all

#	Create a symlink in the expected executable location
all: gen $(TARGET) $(PDF)
	ln -sf $(shell readlink -f $(TARGET)) $(VERSION)

#	Prerequisites are the wanted files
gen: $(LSRC)

clean:
	rm -rf $(OBJ_DIR)/* $(OUT_DIR)/* $(VERSION){,.tgz}
	rm -f $(LSRC)

redo: clean all

#	There should be a script with the version name in the test dir
test: redo
	$(TST_DIR)/$(VERSION).sh

#	To help language servers as we're using additional include paths
tool: clean
	bear -- make

#	The script takes care of any necessary cleaning
release: ; scripts/release.sh

help:
	@echo "ccompiler's project Makefile."
	@echo
	@echo "Utilization example:"
	@echo " make <TARGET> ['DEBUG=true'] ['VERBOSE=true']"
	@echo
	@echo "@param TARGET"
	@echo " Can be any of the following:"
	@echo " all - builds the project (DEFAULT TARGET)"
	@echo " clean - cleans up all binaries generated during compilation"
	@echo " redo - cleans up and then builds"
	@echo " help - shows the utilization example"
	@echo " test - builds and run tests"
	@echo " tool - generates compile_commands.json"
	@echo " release - cleans and compresses the work directory for release"
	@echo
	@echo "@param 'DEBUG=true'"
	@echo " When present, the build will happen in debug mode."
	@echo
	@echo "@param 'VERBOSE=true'"
	@echo " When present, the final executable will be more verbose."

################################################################################
#	Debugging and etc.:

#	Debug of the Make variables
print-%:
	@echo $* = $($*)

.PHONY: all clean redo help tool test release gen
