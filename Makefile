PROJ_NAME=main

SRCS = src/main.c \
       src/system_stm32f4xx.c \
       src/startup_stm32f4xx.s

TOOLCHAIN_ROOT = /home/alsk/toolchains/

PROJECT_ROOT = /home/alsk/embedded-cortexm/stm32fdisco

CROSS_COMPILE = $(TOOLCHAIN_ROOT)gcc-arm-none-eabi-5_4-2016q3/bin/
CC      = $(CROSS_COMPILE)arm-none-eabi-gcc
CPP     = $(CROSS_COMPILE)arm-none-eabi-cpp
LD      = $(CROSS_COMPILE)arm-none-eabi-gcc
AR      = $(CROSS_COMPILE)arm-none-eabi-ar
OBJCOPY = $(CROSS_COMPILE)arm-none-eabi-objcopy
OBJDUMP = $(CROSS_COMPILE)arm-none-eabi-objdump
NM      = $(CROSS_COMPILE)arm-none-eabi-nm

#CC=arm-none-eabi-gcc
#OBJCOPY=arm-none-eabi-objcopy

OBJDIR = build

CFLAGS  = -g -Wall -Wno-missing-braces -std=c99
CFLAGS += -mthumb -mcpu=cortex-m4
#CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
#CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -mfloat-abi=soft
# TODO: hard float was causing an exception; see what's up.
LDFLAGS = -Wl,-Map,$(OBJDIR)/$(PROJ_NAME).map -g -Tstm32f4_flash.ld

CFLAGS += -Isrc -I. -IExternal_libs/STM32F4-Discovery_FW_V1.1.0/Libraries/STM32F4xx_StdPeriph_Driver/inc \
	-IExternal_libs/STM32F4-Discovery_FW_V1.1.0/Libraries/CMSIS/ST/STM32F4xx/Include \
	-IExternal_libs/STM32F4-Discovery_FW_V1.1.0/Libraries/Include \
	-IExternal_libs/cmsis


OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))


all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).bin

$(OBJDIR)/%.elf: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.hex: %.elf
	$(OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

$(OBJDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) -o $@ $^

$(OBJDIR)/%.o: %.s
	$(CC) -c $(CFLAGS) -o $@ $^

$(OBJDIR):
	mkdir -p $@

clean:
	rm -f $(OBJDIR)/$(PROJ_NAME).elf
	rm -f $(OBJDIR)/$(PROJ_NAME).hex
	rm -f $(OBJDIR)/$(PROJ_NAME).bin
	rm -f $(OBJDIR)/$(PROJ_NAME).map
	find $(OBJDIR) -type f -name '*.o' -print0 | xargs -0 -r rm


program: $(OBJDIR)/$(PROJ_NAME).elf
	openocd-0.6.1 -f program.cfg


# Dependdencies
$(OBJDIR)/$(PROJ_NAME).elf: $(OBJS) | $(OBJDIR)
