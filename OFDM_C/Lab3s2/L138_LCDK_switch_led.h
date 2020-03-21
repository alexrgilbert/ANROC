#include "gpio.h"
#include "psc.h"
#include "hw_types.h"
#include "lcdkOMAPL138.h"
#include "soc_OMAPL138.h"
#include "hw_syscfg0_OMAPL138.h"


/* Switch Configuration */

/* Titus : GP0[1] to GP0[4] is mapped to SW1[3:4] on OMAPL138/C6748 LCDK boards */

/* Pin Multiplexing bit mask to select GP0[1] to GP0[4] pin. */

#define PINMUX1_GPIO0_1_ENABLE    (SYSCFG_PINMUX1_PINMUX1_27_24_GPIO0_1  << \
                                    SYSCFG_PINMUX1_PINMUX1_27_24_SHIFT)

#define PINMUX1_GPIO0_2_ENABLE    (SYSCFG_PINMUX1_PINMUX1_23_20_GPIO0_2  << \
                                    SYSCFG_PINMUX1_PINMUX1_23_20_SHIFT)

#define PINMUX1_GPIO0_3_ENABLE    (SYSCFG_PINMUX1_PINMUX1_19_16_GPIO0_3  << \
                                    SYSCFG_PINMUX1_PINMUX1_19_16_SHIFT)

#define PINMUX1_GPIO0_4_ENABLE    (SYSCFG_PINMUX1_PINMUX1_15_12_GPIO0_4  << \
                                    SYSCFG_PINMUX1_PINMUX1_15_12_SHIFT)


/* LED Configuration */

/* Titus : GP6[12], GP6[13], GP2[12] and GP0[9] is mapped to D4, D5, D6, D7 LEDs on OMAPL138/C6748 LCDK boards */

/* Pin Multiplexing bit mask to select GP6[12] pin. */
#define PINMUX13_GPIO6_12_ENABLE    (SYSCFG_PINMUX13_PINMUX13_15_12_GPIO6_12  << \
                                    SYSCFG_PINMUX13_PINMUX13_15_12_SHIFT)

/* Pin Multiplexing bit mask to select GP6[13] pin. */
#define PINMUX13_GPIO6_13_ENABLE    (SYSCFG_PINMUX13_PINMUX13_11_8_GPIO6_13  << \
                                    SYSCFG_PINMUX13_PINMUX13_11_8_SHIFT)

/* Pin Multiplexing bit mask to select GP2[12] pin. */
#define PINMUX5_GPIO2_12_ENABLE    (SYSCFG_PINMUX5_PINMUX5_15_12_GPIO2_12  << \
                                    SYSCFG_PINMUX5_PINMUX5_15_12_SHIFT)

/* Pin Multiplexing bit mask to select GP0[9] pin. */
#define PINMUX0_GPIO0_9_ENABLE    (SYSCFG_PINMUX0_PINMUX0_27_24_GPIO0_9  << \
                                    SYSCFG_PINMUX0_PINMUX0_27_24_SHIFT)


void PinMuxSetup_leds(void);
void PinMuxSetup_switches(void);
void LCDK_GPIO_init(void);
void LCDK_LED_init(void);
void LCDK_SWITCH_init(void);
void LCDK_LED_on(int);
void LCDK_LED_off(int);
int LCDK_SWITCH_state(int);
