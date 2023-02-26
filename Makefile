######################################
# target
######################################
TARGET = mh1903s

#__HC32L110C__ or __HC32L110B__ 
TARGET_DEFS = 

# for x4, use driver/ld/hc32l110x4.ld
TARGET_LD_SCRIPT = Libraries/mhscpu.ld

USER_SOURCES = User/main.c User/delay.c User/sysc.c
USER_INCLUDES = -IUser

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization for size
OPT = -Os


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
# C sources
C_SOURCES = \
Libraries/CMSIS/Device/MegaHunt/mhscpu/Source/system_mhscpu.c \
Libraries/MHSCPU_Driver/src/mhscpu_uart.c \
Libraries/MHSCPU_Driver/src/mhscpu_i2c.c \
Libraries/MHSCPU_Driver/src/mhscpu_dac.c \
Libraries/MHSCPU_Driver/src/mhscpu_crc.c \
Libraries/MHSCPU_Driver/src/mhscpu_adc.c \
Libraries/MHSCPU_Driver/src/mhscpu_trng.c \
Libraries/MHSCPU_Driver/src/mhscpu_qspi.c \
Libraries/MHSCPU_Driver/src/mhscpu_rtc.c \
Libraries/MHSCPU_Driver/src/mhscpu_dma.c \
Libraries/MHSCPU_Driver/src/mhscpu_spi.c \
Libraries/MHSCPU_Driver/src/mhscpu_wdt.c \
Libraries/MHSCPU_Driver/src/mhscpu_cache.c \
Libraries/MHSCPU_Driver/src/mhscpu_gpio.c \
Libraries/MHSCPU_Driver/src/mhscpu_dcmi.c \
Libraries/MHSCPU_Driver/src/mhscpu_timer.c \
Libraries/MHSCPU_Driver/src/mhscpu_hspim.c \
Libraries/MHSCPU_Driver/src/mhscpu_lcdi.c \
Libraries/MHSCPU_Driver/src/mhscpu_kcu.c \
Libraries/MHSCPU_Driver/src/mhscpu_sysctrl.c \
Libraries/MHSCPU_Driver/src/mhscpu_otp.c \
Libraries/MHSCPU_Driver/src/mhscpu_exti.c \
Libraries/MHSCPU_Driver/src/misc.c \
$(USER_SOURCES)

# ASM sources
ASM_SOURCES = Libraries/CMSIS/Device/MegaHunt/mhscpu/Source/GCC/startup_mhscpu.S


#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-

CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
# NONE for Cortex-M0/M0+/M3

# float-abi

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

AS_DEFS =

# C defines
C_DEFS = $(TARGET_DEFS) 

# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-ILibraries/CMSIS/Device/MegaHunt/mhscpu/Include \
-ILibraries/CMSIS/Include \
-ILibraries/MHSCPU_Driver/inc \
$(USER_INCLUDES) 

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = $(TARGET_LD_SCRIPT)

# libraries
LIBS = -lc -lm -lnosys
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,--no-warn-rwx-segments -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@
#$(LUAOBJECTS) $(OBJECTS)
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# program
#######################################
program_pyocd:
	pyocd erase -c -t hc32l110 --config pyocd.yaml
	pyocd load build/$(TARGET).hex -t hc32l110 --config pyocd.yaml

program_openocd:
	openocd -f /usr/share/openocd/scripts/interface/cmsis-dap.cfg -f /usr/share/openocd/scripts/target/hc32l110.cfg -c "program build/$(TARGET).hex verify reset exit" 

#######################################
# debug
#######################################
debug_pyocd:
	pyocd-gdbserver -t hc32l110 --config pyocd.yaml

debug_openocd:
	openocd -f /usr/share/openocd/scripts/interface/cmsis-dap.cfg -f /usr/share/openocd/scripts/target/hc32l110.cfg 


#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
