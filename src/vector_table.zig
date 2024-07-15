const std = @import("std");

pub fn exportVectorTable() void {
    @export(vector_table, .{
        .name = "vector_table",
        .section = ".isr_vector",
        .linkage = .strong,
    });
}

fn defaultHandler() callconv(.C) noreturn {
    while (true) {}
}

const resetHandler = @import("startup.zig").resetHandler;

// This is hard coded the same way it is in the linker script,
// because it appears there's no way to access the address of a
// linker defined symbol at comptime. So the symbol __stack exists,
// and &__stack will yield this same address, however that operation
// isn't permitted at comptime.
const ram_start_offset: u32 = 0x20000000;
const ram_length: u32 = 320 * 1024;

/// The actual instance of our vector table we will export into the section
/// ".isr_vector", ensuring it is placed at the beginning of flash memory.
/// Actual interrupt handlers (rather than the defaultHandler) could be added
/// by assigning them in struct instantiation.
const vector_table: VectorTable = .{
    .initial_stack_pointer = ram_start_offset + ram_length,
};

/// Note that any interrupt function is specified to use the "C" calling convention.
/// This is because Zig's calling convention could differ from C. C being the defacto
/// "standard" for function calling conventions, it's what the processor expects when
/// it branches to one of these functions. Normal functions in application code, however
/// can use normal Zig function definitions. These functions are "special" in the sense
/// that they are being called by "hardware" directly.
const IsrFunction = *const fn () callconv(.C) void;

/// An "extern" struct here is used here to create a
/// struct that has the same memory layout as a C struct.
/// Note that this is NOT the same as "packed", so care must be taken
/// to match the memory layout the CPU is expecting. In this case
/// all fields are ultimately a u32, so silently added padding bytes
/// aren't a concern.
const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset_Handler: IsrFunction = resetHandler,
    NMI_Handler: IsrFunction = defaultHandler,
    HardFault_Handler: IsrFunction = defaultHandler,
    MemManage_Handler: IsrFunction = defaultHandler,
    BusFault_Handler: IsrFunction = defaultHandler,
    UsageFault_Handler: IsrFunction = defaultHandler,
    reserved1: [4]u32 = undefined,
    SVC_Handler: IsrFunction = defaultHandler,
    DebugMon_Handler: IsrFunction = defaultHandler,
    reserved2: u32 = undefined,
    PendSV_Handler: IsrFunction = defaultHandler,
    SysTick_Handler: IsrFunction = defaultHandler,
    WWDG_IRQHandler: IsrFunction = defaultHandler,
    PVD_IRQHandler: IsrFunction = defaultHandler,
    TAMP_STAMP_IRQHandler: IsrFunction = defaultHandler,
    RTC_WKUP_IRQHandler: IsrFunction = defaultHandler,
    FLASH_IRQHandler: IsrFunction = defaultHandler,
    RCC_IRQHandler: IsrFunction = defaultHandler,
    EXTI0_IRQHandler: IsrFunction = defaultHandler,
    EXTI1_IRQHandler: IsrFunction = defaultHandler,
    EXTI2_IRQHandler: IsrFunction = defaultHandler,
    EXTI3_IRQHandler: IsrFunction = defaultHandler,
    EXTI4_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream0_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream1_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream2_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream3_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream4_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream5_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream6_IRQHandler: IsrFunction = defaultHandler,
    ADC_IRQHandler: IsrFunction = defaultHandler,
    CAN1_TX_IRQHandler: IsrFunction = defaultHandler,
    CAN1_RX0_IRQHandler: IsrFunction = defaultHandler,
    CAN1_RX1_IRQHandler: IsrFunction = defaultHandler,
    CAN1_SCE_IRQHandler: IsrFunction = defaultHandler,
    EXTI9_5_IRQHandler: IsrFunction = defaultHandler,
    TIM1_BRK_TIM9_IRQHandler: IsrFunction = defaultHandler,
    TIM1_UP_TIM10_IRQHandler: IsrFunction = defaultHandler,
    TIM1_TRG_COM_TIM11_IRQHandler: IsrFunction = defaultHandler,
    TIM1_CC_IRQHandler: IsrFunction = defaultHandler,
    TIM2_IRQHandler: IsrFunction = defaultHandler,
    TIM3_IRQHandler: IsrFunction = defaultHandler,
    TIM4_IRQHandler: IsrFunction = defaultHandler,
    I2C1_EV_IRQHandler: IsrFunction = defaultHandler,
    I2C1_ER_IRQHandler: IsrFunction = defaultHandler,
    I2C2_EV_IRQHandler: IsrFunction = defaultHandler,
    I2C2_ER_IRQHandler: IsrFunction = defaultHandler,
    SPI1_IRQHandler: IsrFunction = defaultHandler,
    SPI2_IRQHandler: IsrFunction = defaultHandler,
    USART1_IRQHandler: IsrFunction = defaultHandler,
    USART2_IRQHandler: IsrFunction = defaultHandler,
    USART3_IRQHandler: IsrFunction = defaultHandler,
    EXTI15_10_IRQHandler: IsrFunction = defaultHandler,
    RTC_Alarm_IRQHandler: IsrFunction = defaultHandler,
    OTG_FS_WKUP_IRQHandler: IsrFunction = defaultHandler,
    TIM8_BRK_TIM12_IRQHandler: IsrFunction = defaultHandler,
    TIM8_UP_TIM13_IRQHandler: IsrFunction = defaultHandler,
    TIM8_TRG_COM_TIM14_IRQHandler: IsrFunction = defaultHandler,
    TIM8_CC_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Stream7_IRQHandler: IsrFunction = defaultHandler,
    FMC_IRQHandler: IsrFunction = defaultHandler,
    SDMMC1_IRQHandler: IsrFunction = defaultHandler,
    TIM5_IRQHandler: IsrFunction = defaultHandler,
    SPI3_IRQHandler: IsrFunction = defaultHandler,
    UART4_IRQHandler: IsrFunction = defaultHandler,
    UART5_IRQHandler: IsrFunction = defaultHandler,
    TIM6_DAC_IRQHandler: IsrFunction = defaultHandler,
    TIM7_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream0_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream1_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream2_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream3_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream4_IRQHandler: IsrFunction = defaultHandler,
    ETH_IRQHandler: IsrFunction = defaultHandler,
    ETH_WKUP_IRQHandler: IsrFunction = defaultHandler,
    CAN2_TX_IRQHandler: IsrFunction = defaultHandler,
    CAN2_RX0_IRQHandler: IsrFunction = defaultHandler,
    CAN2_RX1_IRQHandler: IsrFunction = defaultHandler,
    CAN2_SCE_IRQHandler: IsrFunction = defaultHandler,
    OTG_FS_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream5_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream6_IRQHandler: IsrFunction = defaultHandler,
    DMA2_Stream7_IRQHandler: IsrFunction = defaultHandler,
    USART6_IRQHandler: IsrFunction = defaultHandler,
    I2C3_EV_IRQHandler: IsrFunction = defaultHandler,
    I2C3_ER_IRQHandler: IsrFunction = defaultHandler,
    OTG_HS_EP1_OUT_IRQHandler: IsrFunction = defaultHandler,
    OTG_HS_EP1_IN_IRQHandler: IsrFunction = defaultHandler,
    OTG_HS_WKUP_IRQHandler: IsrFunction = defaultHandler,
    OTG_HS_IRQHandler: IsrFunction = defaultHandler,
    DCMI_IRQHandler: IsrFunction = defaultHandler,
    CRYP_IRQHandler: IsrFunction = defaultHandler,
    HASH_RNG_IRQHandler: IsrFunction = defaultHandler,
    FPU_IRQHandler: IsrFunction = defaultHandler,
    UART7_IRQHandler: IsrFunction = defaultHandler,
    UART8_IRQHandler: IsrFunction = defaultHandler,
    SPI4_IRQHandler: IsrFunction = defaultHandler,
    SPI5_IRQHandler: IsrFunction = defaultHandler,
    SPI6_IRQHandler: IsrFunction = defaultHandler,
    SAI1_IRQHandler: IsrFunction = defaultHandler,
    LTDC_IRQHandler: IsrFunction = defaultHandler,
    LTDC_ER_IRQHandler: IsrFunction = defaultHandler,
    DMA2D_IRQHandler: IsrFunction = defaultHandler,
    SAI2_IRQHandler: IsrFunction = defaultHandler,
    QUADSPI_IRQHandler: IsrFunction = defaultHandler,
    LPTIM1_IRQHandler: IsrFunction = defaultHandler,
    CEC_IRQHandler: IsrFunction = defaultHandler,
    I2C4_EV_IRQHandler: IsrFunction = defaultHandler,
    I2C4_ER_IRQHandler: IsrFunction = defaultHandler,
    SPDIF_RX_IRQHandler: IsrFunction = defaultHandler,
};
