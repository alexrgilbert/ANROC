/* linker_dsp.cmd */

-stack           0x00000800
-heap            0x00010000

MEMORY
{
   dsp_l2_ram:      ORIGIN = 0x11800000  LENGTH = 0x00040000
   shared_ram:      ORIGIN = 0x80000000  LENGTH = 0x00020000
   external_ram:    ORIGIN = 0xC0000000  LENGTH = 0x08000000
}

SECTIONS
{
   .text       > dsp_l2_ram
   .const      > dsp_l2_ram
   .bss        > dsp_l2_ram
   .far        > dsp_l2_ram
   .switch     > dsp_l2_ram
   .stack      > dsp_l2_ram
   .data       > dsp_l2_ram
   .cinit      > dsp_l2_ram
   .sysmem     > dsp_l2_ram
   .cio        > dsp_l2_ram
   .vecs       > dsp_l2_ram
   .EXT_RAM    > external_ram
}
