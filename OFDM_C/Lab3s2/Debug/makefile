################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

CG_TOOL_ROOT := C:/ti/ccsv5/tools/compiler/c6000_7.4.4

ORDERED_OBJS += \
$(GEN_CMDS__FLAG) \
"./vectors_intr.obj" \
"./psc.obj" \
"./jc113dFianl.obj" \
"./gpio.obj" \
"./Lab3s2.obj" \
"./L138_LCDK_switch_led.obj" \
"./L138_LCDK_aic3106_init.obj" \
"../linker_dsp.cmd" \
-l"C:\ti\dsplib_c674x_3_4_0_0\packages\ti\dsplib\lib\dsplib.lib" \
-l"C:\ti\OMAP-L138_GEL_BSL_Files\bsl\lib\evmomapl138_bsl.lib" \
-l"C:\ti\OMAPL138_StarterWare_1_10_04_01\binary\c674x\cgt_ccs\omapl138\drivers\Debug\drivers.lib" \
-l"rts6740.lib" \

-include ../makefile.init

RM := DEL /F
RMDIR := RMDIR /S/Q

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir_vars.mk
-include subdir_rules.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(S62_DEPS)),)
-include $(S62_DEPS)
endif
ifneq ($(strip $(C64_DEPS)),)
-include $(C64_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(S55_DEPS)),)
-include $(S55_DEPS)
endif
ifneq ($(strip $(C67_DEPS)),)
-include $(C67_DEPS)
endif
ifneq ($(strip $(C??_DEPS)),)
-include $(C??_DEPS)
endif
ifneq ($(strip $(CLA_DEPS)),)
-include $(CLA_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(S??_DEPS)),)
-include $(S??_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(C62_DEPS)),)
-include $(C62_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(K_DEPS)),)
-include $(K_DEPS)
endif
ifneq ($(strip $(C43_DEPS)),)
-include $(C43_DEPS)
endif
ifneq ($(strip $(S67_DEPS)),)
-include $(S67_DEPS)
endif
ifneq ($(strip $(SA_DEPS)),)
-include $(SA_DEPS)
endif
ifneq ($(strip $(S43_DEPS)),)
-include $(S43_DEPS)
endif
ifneq ($(strip $(OPT_DEPS)),)
-include $(OPT_DEPS)
endif
ifneq ($(strip $(S64_DEPS)),)
-include $(S64_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(C55_DEPS)),)
-include $(C55_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: Lab3s2.out

# Tool invocations
Lab3s2.out: $(OBJS) $(CMD_SRCS) $(GEN_CMDS)
	@echo 'Building target: $@'
	@echo 'Invoking: C6000 Linker'
	"C:/ti/ccsv5/tools/compiler/c6000_7.4.4/bin/cl6x" -mv6740 --abi=coffabi -g --define=omapl138 --display_error_number --diag_warning=225 --diag_wrap=off -z --stack_size=0x800 -m"Lab3s2.map" --heap_size=0x800 -i"C:/ti/ccsv5/tools/compiler/c6000_7.4.4/lib" -i"C:/ti/ccsv5/tools/compiler/c6000_7.4.4/include" --reread_libs --define=DSP_CORE=1 --warn_sections --display_error_number --diag_wrap=off --xml_link_info="Lab3s2_linkInfo.xml" --rom_model -o "Lab3s2.out" $(ORDERED_OBJS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(C6000_EXECUTABLE_OUTPUTS__QUOTED) "Lab3s2.out"
	-$(RM) "L138_LCDK_aic3106_init.pp" "L138_LCDK_switch_led.pp" "Lab3s2.pp" "gpio.pp" "jc113dFianl.pp" "psc.pp" 
	-$(RM) "L138_LCDK_aic3106_init.obj" "L138_LCDK_switch_led.obj" "Lab3s2.obj" "gpio.obj" "jc113dFianl.obj" "psc.obj" "vectors_intr.obj" 
	-$(RM) "vectors_intr.pp" 
	-@echo 'Finished clean'
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

