  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
.global  g_pfnVectors
.global  Default_Handler

/* start address for the initialization values of the .data section.
defined in linker script */
.word _sidata
/* start address for the .data section. defined in linker script */
.word _sdata
/* end address for the .data section. defined in linker script */
.word _edata
/* start address for the .bss section. defined in linker script */
.word _sbss
/* end address for the .bss section. defined in linker script */
.word _ebss

.section  .text.Reset_Handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:
    movs r0, #0
    movs r1, #0
    movs r2, #0
    movs r3, #0
    movs r4, #0
    movs r5, #0
    movs r6, #0
    movs r7, #0

    LDR R0, =g_pfnVectors
    LDR R1, =0xE000ED08
    STR R0,[R1]
  ldr   sp, =_estack     /* set stack pointer */

/* Copy the data segment initializers from flash to SRAM */
  movs  r1, #0
  b  LoopCopyDataInit

CopyDataInit:
  ldr  r3, =_sidata
  ldr  r3, [r3, r1]
  str  r3, [r0, r1]
  adds  r1, r1, #4

LoopCopyDataInit:
  ldr  r0, =_sdata
  ldr  r3, =_edata
  adds  r2, r0, r1
  cmp  r2, r3
  bcc  CopyDataInit
  ldr  r2, =_sbss
  b  LoopFillZerobss
/* Zero fill the bss segment. */
FillZerobss:
  movs  r3, #0
  str  r3, [r2], #4

LoopFillZerobss:
  ldr  r3, = _ebss
  cmp  r2, r3
  bcc  FillZerobss

/* Call the clock system intitialization function.*/
  bl  SystemInit
/* Call static constructors */
  bl __libc_init_array /*目前看来这个没什么用，如果代码量有超可以去掉*/
/* Call the application's entry point.*/
  bl  main
  bx  lr
.size  Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that gets called when the processor receives an 
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 * @param  None     
 * @retval None       
*/
    .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler
/******************************************************************************
*
* The minimal vector table for a Cortex M4. Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
* 
*******************************************************************************/
   .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
                .word     _estack                            /* Top of Stack */
                .word     Reset_Handler		/* Reset Handler */
                .word     NMI_Handler		/* NMI Handler */
                .word     HardFault_Handler		/* Hard Fault Handler */
                .word     MemManage_Handler		/* MPU Fault Handler */
                .word     BusFault_Handler		/* Bus Fault Handler */
                .word     UsageFault_Handler		/* Usage Fault Handler */
                .word     0		/* Reserved */
                .word     0		/* Reserved */
                .word     0		/* Reserved */
                .word     0		/* Reserved */
                .word     SVC_Handler		/* SVCall Handler */
                .word     DebugMon_Handler		/* Debug Monitor Handler */
                .word     0		/* Reserved */
                .word     PendSV_Handler		/* PendSV Handler */
                .word     SysTick_Handler		/* SysTick Handler */
                .word     DMA0_IRQHandler
                .word     USB_IRQHandler
                .word     USBDMA_IRQHandler
                .word     LCD_IRQHandler
                .word     SCI0_IRQHandler
                .word     UART0_IRQHandler
                .word     UART1_IRQHandler
                .word     SPI0_IRQHandler
                .word     CRYPT0_IRQHandler
                .word     TIM0_0_IRQHandler
                .word     TIM0_1_IRQHandler
                .word     TIM0_2_IRQHandler
                .word     TIM0_3_IRQHandler
                .word     EXTI0_IRQHandler
                .word     EXTI1_IRQHandler
                .word     EXTI2_IRQHandler
                .word     RTC_IRQHandler
                .word     SENSOR_IRQHandler
                .word     TRNG_IRQHandler
                .word     ADC0_IRQHandler
                .word     SSC_IRQHandler
                .word     TIM0_4_IRQHandler
                .word     TIM0_5_IRQHandler
                .word     KEYBOARD_IRQHandler
                .word     MSR_IRQHandler
                .word     EXTI3_IRQHandler
                .word     SPI1_IRQHandler
                .word     SPI2_IRQHandler
                .word     0
                .word     SCI2_IRQHandler
                .word     0
                .word     0
                .word     UART2_IRQHandler
                .word     UART3_IRQHandler
                .word     0
                .word     QSPI_IRQHandler
                .word     I2C0_IRQHandler
                .word     EXTI4_IRQHandler
                .word     EXTI5_IRQHandler
                .word     TIM0_6_IRQHandler
                .word     TIM0_7_IRQHandler
                .word     0
                .word     DCMI_IRQHandler
                .word     0
                .word     0
                .word     0
                .word     QR_IRQHandler
                .word     GPU_IRQHandler
                .word     0
                .word     AWD_IRQHandler
                .word     DAC_IRQHandler
                .word     SPI5_IRQHandler

/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler. 
* As they are weak aliases, any function with the same name will override 
* this definition.
*
*******************************************************************************/
.weak NMI_Handler
.thumb_set NMI_Handler,Default_Handler

.weak HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler

.weak MemManage_Handler
.thumb_set MemManage_Handler,Default_Handler

.weak BusFault_Handler
.thumb_set BusFault_Handler,Default_Handler

.weak UsageFault_Handler
.thumb_set UsageFault_Handler,Default_Handler

.weak SVC_Handler
.thumb_set SVC_Handler,Default_Handler

.weak DebugMon_Handler
.thumb_set DebugMon_Handler,Default_Handler

.weak PendSV_Handler
.thumb_set PendSV_Handler,Default_Handler

.weak SysTick_Handler
.thumb_set SysTick_Handler,Default_Handler

.weak DMA0_IRQHandler
.thumb_set DMA0_IRQHandler,Default_Handler

.weak USB_IRQHandler
.thumb_set USB_IRQHandler,Default_Handler

.weak USBDMA_IRQHandler
.thumb_set USBDMA_IRQHandler,Default_Handler

.weak LCD_IRQHandler
.thumb_set LCD_IRQHandler,Default_Handler

.weak SCI0_IRQHandler
.thumb_set SCI0_IRQHandler,Default_Handler

.weak UART0_IRQHandler
.thumb_set UART0_IRQHandler,Default_Handler

.weak UART1_IRQHandler
.thumb_set UART1_IRQHandler,Default_Handler

.weak SPI0_IRQHandler
.thumb_set SPI0_IRQHandler,Default_Handler

.weak CRYPT0_IRQHandler
.thumb_set CRYPT0_IRQHandler,Default_Handler

.weak TIM0_0_IRQHandler
.thumb_set TIM0_0_IRQHandler,Default_Handler

.weak TIM0_1_IRQHandler
.thumb_set TIM0_1_IRQHandler,Default_Handler

.weak TIM0_2_IRQHandler
.thumb_set TIM0_2_IRQHandler,Default_Handler

.weak TIM0_3_IRQHandler
.thumb_set TIM0_3_IRQHandler,Default_Handler

.weak EXTI0_IRQHandler
.thumb_set EXTI0_IRQHandler,Default_Handler

.weak EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler,Default_Handler

.weak EXTI2_IRQHandler
.thumb_set EXTI2_IRQHandler,Default_Handler

.weak RTC_IRQHandler
.thumb_set RTC_IRQHandler,Default_Handler

.weak SENSOR_IRQHandler
.thumb_set SENSOR_IRQHandler,Default_Handler

.weak TRNG_IRQHandler
.thumb_set TRNG_IRQHandler,Default_Handler

.weak ADC0_IRQHandler
.thumb_set ADC0_IRQHandler,Default_Handler

.weak SSC_IRQHandler
.thumb_set SSC_IRQHandler,Default_Handler

.weak TIM0_4_IRQHandler
.thumb_set TIM0_4_IRQHandler,Default_Handler

.weak TIM0_5_IRQHandler
.thumb_set TIM0_5_IRQHandler,Default_Handler

.weak KEYBOARD_IRQHandler
.thumb_set KEYBOARD_IRQHandler,Default_Handler

.weak MSR_IRQHandler
.thumb_set MSR_IRQHandler,Default_Handler

.weak EXTI3_IRQHandler
.thumb_set EXTI3_IRQHandler,Default_Handler

.weak SPI1_IRQHandler
.thumb_set SPI1_IRQHandler,Default_Handler

.weak SPI2_IRQHandler
.thumb_set SPI2_IRQHandler,Default_Handler

.weak SCI2_IRQHandler
.thumb_set SCI2_IRQHandler,Default_Handler

.weak UART2_IRQHandler
.thumb_set UART2_IRQHandler,Default_Handler

.weak UART3_IRQHandler
.thumb_set UART3_IRQHandler,Default_Handler

.weak QSPI_IRQHandler
.thumb_set QSPI_IRQHandler,Default_Handler

.weak I2C0_IRQHandler
.thumb_set I2C0_IRQHandler,Default_Handler

.weak EXTI4_IRQHandler
.thumb_set EXTI4_IRQHandler,Default_Handler

.weak EXTI5_IRQHandler
.thumb_set EXTI5_IRQHandler,Default_Handler

.weak TIM0_6_IRQHandler
.thumb_set TIM0_6_IRQHandler,Default_Handler

.weak TIM0_7_IRQHandler
.thumb_set TIM0_7_IRQHandler,Default_Handler

.weak DCMI_IRQHandler
.thumb_set DCMI_IRQHandler,Default_Handler

.weak QR_IRQHandler
.thumb_set QR_IRQHandler,Default_Handler

.weak GPU_IRQHandler
.thumb_set GPU_IRQHandler,Default_Handler

.weak AWD_IRQHandler
.thumb_set AWD_IRQHandler,Default_Handler

.weak DAC_IRQHandler
.thumb_set DAC_IRQHandler,Default_Handler

.weak SPI5_IRQHandler
.thumb_set SPI5_IRQHandler,Default_Handler

