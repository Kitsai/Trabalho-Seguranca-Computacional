COMPILER = g++

RMDIR = rm -rdf
RM = rm -f

DEP_FLAGS = -M -MT $@ -MT $(BIN_PATH)/$(*F).o -MP -MF $@
LIBS =  -lm

INC_PATHS = -I$(INC_PATH)

FLAGS = -std=c++17 -Wall -pedantic -Wextra -Wno-unused-parameter -Werror=init-self

DFLAGS = -ggdb -O0 -DDEBUG

RFLAGS = -O3 -mtune=native

INC_PATH = include
SRC_PATH = src
SRC_SUBDIRS = $(wildcard $(SRC_PATH)/*/)
BIN_PATH = bin
DEP_PATH = dep

CPP_FILES = $(wildcard $(SRC_PATH)/*.cpp)
INC_FILES = $(wildcard $(SRC_PATH)/*.hpp)
FILE_NAMES = $(sort $(notdir $(CPP_FILES:.cpp=)) $(notdir $(INC_FILES:.h=)))
DEP_FILES = $(addprefix $(DEP_PATH)/,$(addsuffix .d,$(FILE_NAMES)))
OBJ_FILES = $(addprefix $(BIN_PATH)/,$(notdir $(CPP_FILES:.cpp=.o)))

EXEC = sdes

# SE FOR WINDOWS
ifeq ($(OS),Windows_NT)
RMDIR = rd /s /q
RM = del /q


FLAGS += -mwindows
DFLAGS += -mconsole
LIBS := -lmingw32 $(LIBS)

EXEC := $(EXEC).exe

else

UNAME_S := $(shell uname -s)

# SE FOR MAC
ifeq ($(UNAME_S), Darwin)

LIBS = -lm
endif
endif

.PRECIOUS: $(DEP_FILES)
.PHONY: release debug clean folders help

all: $(EXEC)

$(EXEC): $(OBJ_FILES)
	$(COMPILER) -o $@ $^ $(LINK_PATH) $(LIBS) $(FLAGS)

$(BIN_PATH)/%.o: $(DEP_PATH)/%.d | folders
	$(COMPILER) $(INC_PATHS) $(addprefix $(SRC_PATH)/,$(notdir $(<:.d=.cpp))) -c $(FLAGS) -o $@

$(DEP_PATH)/%.d: $(SRC_PATH)/%.cpp | folders
	$(COMPILER) $(INC_PATHS) $< $(DEP_FLAGS) $(FLAGS)
clean:
	$(RMDIR) $(DEP_PATH)
	$(RMDIR) $(BIN_PATH)
	$(RM) $(EXEC)

release: FLAGS += $(RFLAGS)
release: $(EXEC)

debug: FLAGS += $(DFLAGS)
debug: $(EXEC)

folders:
ifeq ($(OS), Windows_NT)
	@if NOT exist $(DEP_PATH) (mkdir $(DEP_PATH))
	@if NOT exist $(BIN_PATH) (mkdir $(BIN_PATH))
	@if NOT exist $(INC_PATH) (mkdir $(INC_PATH))
	@if NOT exist $(SRC_PATH) (mkdir $(SRC_PATH))
else
	@mkdir -p $(DEP_PATH) $(BIN_PATH) $(INC_PATH) $(SRC_PATH)
endif

print-% : ; echo $* = $($*)

help:
ifeq ($(OS), Windows_NT)
	echo.
endif
	@echo Available targets:
	@echo - release: Builds the release version
	@echo - debug: Builds the debug version
	@echo - clean: Cleans generated files
	@echo - folders: Generates project directories
	@echo - help: Show help
ifeq ($(OS), Windows_NT)
	echo.
endif

.SECONDEXPANSION:
-include $$(DEP_FILES)
