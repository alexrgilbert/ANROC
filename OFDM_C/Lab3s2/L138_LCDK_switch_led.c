#include "L138_LCDK_switch_led.h"



void PinMuxSetup_leds(void)
{
     unsigned int savePinmux = 0;


     /*
     ** Clearing the bit in context and retaining the other bit values
     ** in PINMUX13 register.
     */
     savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(13)) &
                  ~(SYSCFG_PINMUX13_PINMUX13_15_12));

     /* Setting the pins corresponding to GP6[12] in PINMUX13 register.*/
     HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(13)) =
          (PINMUX13_GPIO6_12_ENABLE | savePinmux);


     /*
     ** Clearing the bit in context and retaining the other bit values
     ** in PINMUX13 register.
     */
     savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(13)) &
                  ~(SYSCFG_PINMUX13_PINMUX13_11_8));

     /* Setting the pins corresponding to GP6[13] in PINMUX13 register.*/
     HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(13)) =
          (PINMUX13_GPIO6_13_ENABLE | savePinmux);


     /*
     ** Clearing the bit in context and retaining the other bit values
     ** in PINMUX5 register.
     */
     savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(5)) &
                  ~(SYSCFG_PINMUX5_PINMUX5_15_12));

     /* Setting the pins corresponding to GP2[12] in PINMUX5 register.*/
     HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(5)) =
          (PINMUX5_GPIO2_12_ENABLE | savePinmux);


     /*
     ** Clearing the bit in context and retaining the other bit values
     ** in PINMUX0 register.
     */
     savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(0)) &
                  ~(SYSCFG_PINMUX0_PINMUX0_27_24));

     /* Setting the pins corresponding to GP0[9] in PINMUX0 register.*/
     HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(0)) =
          (PINMUX0_GPIO0_9_ENABLE | savePinmux);

}



void PinMuxSetup_switches(void)
{
     unsigned int savePinmux = 0;

     /* Setting the pins corresponding to GP0[1] in PINMUX1 register.*/

     /*
     ** Clearing the bit in context and retaining the other bit values
     ** in PINMUX1 register.
     */
     savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) &
                  ~(SYSCFG_PINMUX1_PINMUX1_27_24));


     HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) =
          (PINMUX1_GPIO0_1_ENABLE | savePinmux);



     /* Setting the pins corresponding to GP0[2] in PINMUX1 register.*/

          /*
          ** Clearing the bit in context and retaining the other bit values
          ** in PINMUX1 register.
          */
          savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) &
                       ~(SYSCFG_PINMUX1_PINMUX1_23_20));


          HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) =
               (PINMUX1_GPIO0_2_ENABLE | savePinmux);




          /* Setting the pins corresponding to GP0[3] in PINMUX1 register.*/

               /*
               ** Clearing the bit in context and retaining the other bit values
               ** in PINMUX1 register.
               */
               savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) &
                            ~(SYSCFG_PINMUX1_PINMUX1_19_16));


               HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) =
                    (PINMUX1_GPIO0_3_ENABLE | savePinmux);



               /* Setting the pins corresponding to GP0[4] in PINMUX1 register.*/

                    /*
                    ** Clearing the bit in context and retaining the other bit values
                    ** in PINMUX1 register.
                    */
                    savePinmux = (HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) &
                                 ~(SYSCFG_PINMUX1_PINMUX1_15_12));


                    HWREG(SOC_SYSCFG_0_REGS + SYSCFG0_PINMUX(1)) =
                         (PINMUX1_GPIO0_4_ENABLE | savePinmux);


}


void LCDK_GPIO_init()
{
	  /* The Local PSC number for GPIO is 3. GPIO belongs to PSC1 module.*/
	  PSCModuleControl(SOC_PSC_1_REGS, HW_PSC_GPIO, PSC_POWERDOMAIN_ALWAYS_ON, PSC_MDCTL_NEXT_ENABLE);
}

void LCDK_SWITCH_init()
{

	 /* Pin Multiplexing of pins GP0[1] to GP0[4] of GPIO Bank 2 for DIP SWITCHEs in OMAPL138 LCDK board */
	  PinMuxSetup_switches();
	    /* Titus : 2,3,4,5 is the GPIO no for GP0[1] to GP0[4]; Refer page no 901 in OMAPL138/C6748 TRM */
	  /* SWITCHEs SETUP */

	      /* Sets the pin 2 (GP0[1]) as input.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 2, GPIO_DIR_INPUT);

	      /* Sets the pin 3 (GP0[2]) as input.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 3, GPIO_DIR_INPUT);

	      /* Sets the pin 4 (GP0[3]) as input.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 4, GPIO_DIR_INPUT);

	      /* Sets the pin 5 (GP0[4]) as input.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 5, GPIO_DIR_INPUT);

}


void LCDK_LED_init()
{

	  /* Pin Multiplexing of pins GP6[12], GP6[13], GP2[12], GP0[9], for LEDs in OMAPL138 LCDK board */
	  PinMuxSetup_leds();

	  /* LEDs SETUP */

	      /* Sets the pin 109 (GP6[12]) as output.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 109, GPIO_DIR_OUTPUT);

	      /* Sets the pin 110 (GP6[13]) as output.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 110, GPIO_DIR_OUTPUT);

	      /* Sets the pin 45 (GP2[12]) as output.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 45, GPIO_DIR_OUTPUT);

	      /* Sets the pin 10 (GP0[9]) as output.*/
	      GPIODirModeSet(SOC_GPIO_0_REGS, 10, GPIO_DIR_OUTPUT);

}


int LCDK_SWITCH_state(int n)
{

	return !( GPIOPinRead(SOC_GPIO_0_REGS, n-3));
}


void LCDK_LED_on(int n)
{
	switch(n)
	{
		case 4:
			GPIOPinWrite(SOC_GPIO_0_REGS, 110, GPIO_PIN_HIGH);
			break;
		case 5:
			GPIOPinWrite(SOC_GPIO_0_REGS, 109, GPIO_PIN_HIGH);
			break;
		case 6:
			GPIOPinWrite(SOC_GPIO_0_REGS, 45, GPIO_PIN_HIGH);
			break;
		case 7:
			GPIOPinWrite(SOC_GPIO_0_REGS, 10, GPIO_PIN_HIGH);
			break;
		default:
			break;
	}
}



void LCDK_LED_off(int n)
{
	switch(n)
	{
		case 4:
			GPIOPinWrite(SOC_GPIO_0_REGS, 110, GPIO_PIN_LOW);
			break;
		case 5:
			GPIOPinWrite(SOC_GPIO_0_REGS, 109, GPIO_PIN_LOW);
			break;
		case 6:
			GPIOPinWrite(SOC_GPIO_0_REGS, 45, GPIO_PIN_LOW);
			break;
		case 7:
			GPIOPinWrite(SOC_GPIO_0_REGS, 10, GPIO_PIN_LOW);
			break;
		default:
			break;
	}
}


