BUILD ?= build

CROSS_COMPILE = arm-none-eabi-

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)ld
AR = $(CROSS_COMPILE)ar

SPRESENSE_SDK = spresense-exported-sdk

# Platforms are: Linux, Darwin, MSYS, CYGWIN
PLATFORM := $(firstword $(subst _, ,$(shell uname -s 2>/dev/null)))

ifeq ($(PLATFORM),Darwin)
  # macOS
  MKSPK = mkspk/mkspk
else ifeq ($(PLATFORM),Linux)
  # Linux
  MKSPK = mkspk/mkspk
else
  # Cygwin/MSYS2
  MKSPK = mkspk/mkspk.exe
endif

SERIAL ?= /dev/ttyUSB0

INC_SPR += \
	-I$(BUILD) \
	-I$(SPRESENSE_SDK)/nuttx/include \
	-I$(SPRESENSE_SDK)/nuttx/arch \
	-I$(SPRESENSE_SDK)/nuttx/arch/chip \
	-I$(SPRESENSE_SDK)/nuttx/arch/os \
	-I$(SPRESENSE_SDK)/sdk/include \

INC_APP += \
	-I$(BUILD) \

CXXFLAGS += \
	-DCONFIG_WCHAR_BUILTIN \
	-DCONFIG_HAVE_DOUBLE \
	-fmessage-length=0 \
	-fno-exceptions \
	-fno-unwind-tables \
	-ffunction-sections \
	-fdata-sections \
	-funsigned-char \
	-mcpu=cortex-m4 \
	-mabi=aapcs \
	-mthumb \
	-mfpu=fpv4-sp-d16 \
	-mfloat-abi=hard \
	-Wall \
	-Wextra \
	-Wno-shadow \
	-Wno-vla \
	-Wno-strict-aliasing \
	-Wno-type-limits \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-Wno-write-strings \
	-Wno-sign-compare \
	-Wunused-function \
	-fno-delete-null-pointer-checks \
	-fomit-frame-pointer \
	-O2 \
	-std=gnu++11 \
	-fno-rtti \
	-fno-use-cxa-atexit \
	-fno-inline-functions

LIBGCC = "${shell "$(CC)" $(CXXFLAGS) -print-libgcc-file-name}"

LDFLAGS = \
	--entry=__start \
	-nostartfiles \
	-nodefaultlibs \
	-T$(SPRESENSE_SDK)/nuttx/scripts/ramconfig.ld \
	--gc-sections \
	-Map=$(BUILD)/output.map \
	-o $(BUILD)/firmware.elf \
	--start-group \
	-u spresense_main \
	-u board_timerhook \
	$(BUILD)/libapp.a \
	$(SPRESENSE_SDK)/nuttx/libs/libapps.a \
	$(SPRESENSE_SDK)/nuttx/libs/libnuttx.a \
	$(LIBGCC) \
	--end-group \
	-L$(BUILD) \

SRC_SPR_CXX += \
	main.cpp \

# SRC_APP_CXX += \
# 	HelloWorld.cpp \

OBJ = $(addprefix $(BUILD)/spr/, $(SRC_SPR_CXX:.cpp=.o))
OBJ += $(addprefix $(BUILD)/app/, $(SRC_APP_CXX:.cpp=.o))

all: $(BUILD)/firmware.spk

$(BUILD)/%.o: %.c
	$(CC) $(CXXFLAGS) -c -o $@ $<

$(BUILD)/spr/%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INC_SPR) -c -o $@ $<

$(BUILD)/app/%.o: %.cpp
	$(CXX) $(CXXFLAGS) 	$(INC_APP) -c -o $@ $<

$(BUILD)/libapp.a: $(SPRESENSE_SDK) $(OBJ)
	$(AR) rcs $(BUILD)/libapp.a $(OBJ)

$(BUILD)/firmware.elf: $(BUILD)/libapp.a
	$(LD) $(LDFLAGS)

$(MKSPK):
	$(MAKE) -C mkspk

$(BUILD):
	mkdir $(BUILD)
	mkdir -p $(BUILD)/spr
	mkdir -p $(BUILD)/app

$(BUILD)/firmware.spk: $(BUILD) $(BUILD)/firmware.elf $(MKSPK)
	$(MKSPK) -c 2 $(BUILD)/firmware.elf nuttx $(BUILD)/firmware.spk

flash: $(BUILD)/firmware.spk
	tools/flash_writer.py -s -c $(SERIAL) -d -b 115200 -n $(BUILD)/firmware.spk

clean:
	rm -rf $(BUILD)
