BUILD ?= build

CROSS_COMPILE = arm-none-eabi-

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)ld
AR = $(CROSS_COMPILE)ar

SPRESENSE_SDK = spresense-exported-sdk

# Platforms are: Linux, Darwin, MSYS, CYGWIN
PLATFORM := $(firstword $(subst _, ,$(shell uname -s 2>/dev/null)))

# TODO if SERIAL is defined as an environment variable, use that instead
ifeq ($(PLATFORM),Darwin)
  # macOS
  MKSPK = mkspk/mkspk
else ifeq ($(PLATFORM),Linux)
  # Linux
  MKSPK = mkspk/mkspk
  BAUDRATE ?= 921600
else
  # Cygwin/MSYS2
  MKSPK = mkspk/mkspk.exe
  BAUDRATE ?= 921600
endif

BAUDRATE ?= 115200

INC_SPR += \
	-I$(BUILD) \
	-I$(SPRESENSE_SDK)/nuttx/include \
	-I$(SPRESENSE_SDK)/nuttx/arch \
	-I$(SPRESENSE_SDK)/nuttx/arch/chip \
	-I$(SPRESENSE_SDK)/nuttx/arch/os \
	-I$(SPRESENSE_SDK)/sdk/include \
	-I$(SPRESENSE_SDK)/sdk/modules/include \

INC_APP += \
	-I$(BUILD) \
	-I stdlib \
	-I edge_impulse \
	-I edge_impulse/edge-impulse-sdk \
	-I edge_impulse/edge-impulse-sdk/classifier \
	-I edge_impulse/edge-impulse-sdk/porting \
	-I edge_impulse/edge-impulse-sdk/dsp \
	-I edge_impulse/edge-impulse-sdk/dsp/kissfft \
	-I edge_impulse/edge-impulse-sdk/dsp/dct \
	-I edge_impulse/edge-impulse-sdk/third_party/flatbuffers/include/flatbuffers \
	-I edge_impulse/edge-impulse-sdk/third_party/gemmlowp \
	-I edge_impulse/edge-impulse-sdk/third_party/ruy \
	-I edge_impulse/edge-impulse-sdk/CMSIS/DSP/Include/ \
	-I edge_impulse/edge-impulse-sdk/CMSIS/Core/Include/ \
	-I edge_impulse/edge-impulse-sdk/tensorflow/ \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite/micro \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/kernels \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite/scheme \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite/c \
	-I edge_impulse/edge-impulse-sdk/tensorflow/lite/core/api/ \
	-I edge_impulse/model-parameters \
	-I edge_impulse/tflite-model \

CFLAGS += \
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

CXXFLAGS += $(CFLAGS) \
	-std=gnu++11 \
	-fno-rtti \
	-fno-use-cxa-atexit \
	-fno-inline-functions

LIBGCC = "${shell "$(CC)" $(CXXFLAGS) -print-libgcc-file-name}"
LIBM = "${shell "$(CC)" $(CFLAGS) -print-file-name=libm.a}"
LIBSTDC = "${shell "$(CC)" $(CFLAGS) -print-file-name=libstdc++.a}"

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
	$(LIBM) \
	$(LIBSTDC) \
	--end-group \
	-L$(BUILD) \
	--print-memory-usage \

# Application flags
APPFLAGS += \
	-DEI_SENSOR_AQ_STREAM=FILE \
	-DEI_PORTING_SONY_SPRESENSE=1 \
	-DEIDSP_USE_CMSIS_DSP \
	-DEIDSP_QUANTIZE_FILTERBANK=0 \
	-DNDEBUG \
	-DEI_CLASSIFIER_TFLITE_ENABLE_CMSIS_NN \
	-DARM_MATH_LOOPUNROLL \
	-DEIDSP_LOAD_CMSIS_DSP_SOURCES=1 \

SRC_SPR_CXX += \
	main.cpp \

SRC_APP_CXX += \
	ei_main.cpp \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/porting/sony/*.cpp)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/dsp/dct/*.cpp)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/dsp/kissfft/*.cpp)) \
	$(notdir $(wildcard edge_impulse/tflite-model/*.cpp)) \

SRC_APP_CC += \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/kernels/*.cc)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/kernels/internal/*.cc)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/*.cc)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/kernels/*.cc)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/memory_planner/*.cc)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/core/api/*.cc)) \

SRC_APP_C += \
	$(notdir $(wildcard stdlib/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/TransformFunctions/*fft*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/CommonTables/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/TransformFunctions/*bit*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ActivationFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/BasicMathFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ConcatenationFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ConvolutionFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/FullyConnectedFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/NNSupportFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/PoolingFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ReshapeFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/SoftmaxFunctions/*.c)) \
	$(notdir $(wildcard edge_impulse/mbedtls_hmac_sha256_sw/mbedtls/src/*.c)) \
	$(notdir $(wildcard edge_impulse/edge-impulse-sdk/tensorflow/lite/c/*.c)) \

VPATH += stdlib \
	edge_impulse/edge-impulse-sdk/porting/sony \
	edge_impulse/edge-impulse-sdk/dsp/dct \
	edge_impulse/edge-impulse-sdk/dsp/kissfft \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/kernels \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/kernels/internal \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/micro \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/kernels \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/micro/memory_planner \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/c/ \
	edge_impulse/edge-impulse-sdk/tensorflow/lite/core/api/ \
	edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/TransformFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/CommonTables \
	edge_impulse/edge-impulse-sdk/CMSIS/DSP/Source/TransformFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ActivationFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/BasicMathFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ConcatenationFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ConvolutionFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/FullyConnectedFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/NNSupportFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/PoolingFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/ReshapeFunctions \
	edge_impulse/edge-impulse-sdk/CMSIS/NN/Source/SoftmaxFunctions \
	edge_impulse/tflite-model \

OBJ = $(addprefix $(BUILD)/spr/, $(SRC_SPR_CXX:.cpp=.o))
OBJ += $(addprefix $(BUILD)/app/, $(SRC_APP_CXX:.cpp=.o))
OBJ += $(addprefix $(BUILD)/app/, $(SRC_APP_CC:.cc=.o))
OBJ += $(addprefix $(BUILD)/app/, $(SRC_APP_C:.c=.o))

CFLAGS += $(APPFLAGS)
CXXFLAGS += $(APPFLAGS)

all: $(BUILD)/firmware.spk

$(BUILD)/%.o: %.c
	@$(CC) $(CXXFLAGS) -c -o $@ $<
	@echo $<

$(BUILD)/spr/%.o: %.cpp
	@$(CXX) $(CXXFLAGS) $(INC_SPR) -c -o $@ $<
	@echo $<

$(BUILD)/app/%.o: %.cpp
	@$(CXX) $(CXXFLAGS) 	$(INC_APP) -c -o $@ $<
	@echo $<

$(BUILD)/app/%.o: %.cc
	@$(CXX) $(CXXFLAGS) 	$(INC_APP) -c -o $@ $<
	@echo $<

$(BUILD)/app/%.o: %.c
	@$(CC) $(CFLAGS) 	$(INC_APP) -c -o $@ $<
	@echo $<

$(BUILD)/libapp.a: $(SPRESENSE_SDK) $(OBJ)
	$(AR) rcs $(BUILD)/libapp.a $(OBJ)

$(BUILD)/firmware.elf: $(BUILD)/libapp.a
	$(LD) $(LDFLAGS)

$(MKSPK):
	$(MAKE) -C mkspk

$(BUILD):
	mkdir -p $(BUILD)
	mkdir -p $(BUILD)/spr
	mkdir -p $(BUILD)/app

$(BUILD)/firmware.spk: $(BUILD) $(BUILD)/firmware.elf $(MKSPK)
	$(MKSPK) -c 2 $(BUILD)/firmware.elf nuttx $(BUILD)/firmware.spk

flash: $(BUILD)/firmware.spk
	tools/flash_writer.py -s -d -b $(BAUDRATE) -n $(BUILD)/firmware.spk

clean:
	@rm -rf $(BUILD)
