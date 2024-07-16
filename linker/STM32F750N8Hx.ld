/*
This just good convention and isn't actually neccessary.
Cortex-M chips start executing code at a fixed address designated 
by a vector table stored in flash. However, some debug tooling
may rely on this to determine where the program starts executing,
so it's good practice to match this with your vector table's RESET
function.
*/
ENTRY(resetHandler) 

MEMORY
{
  RAM   (xrw)    : ORIGIN = 0x20000000, LENGTH = 320K
  FLASH (rx)     : ORIGIN = 0x8000000,  LENGTH = 64K
}

/* Set stack start to the end of RAM (stack grows from high memory addresses -> low) */
PROVIDE(__stack = ORIGIN(RAM) + LENGTH(RAM));

SECTIONS
{
  /* Ensuring our vector table is placed at the beginning of FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  /* Program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.glue_7)         /* glue arm to thumb code, TODO: Likely not required if not mixing thumb/arm ISAs */
    *(.glue_7t)        /* glue thumb to arm code, TODO: Likely not required if not mixing thumb/arm ISAs */
    . = ALIGN(4);
  } >FLASH

  /* Constant data */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  /* Special ARM debug info */
  /* TODO: Not sure precisely what this does */
  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH


  /* Loads the FLASH (LOAD) address that holds initalization data */
  _sidata = LOADADDR(.data);

  /* Specifies that initialization data is stored in FLASH (LMA), but has an associated location in RAM (VMA) */
  /* Startup code will copy initalization data from FLASH to RAM */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)                   
    *(.data*)          

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> FLASH

  
  /* Uninitialized data section, startup code will set this to all 0 */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
  } >RAM

  /* TODO: Not sure precisely what this does */
  .ARM.attributes 0 : { *(.ARM.attributes) }
}


