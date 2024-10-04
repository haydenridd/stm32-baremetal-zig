const std = @import("std");

const getTicks = @import("system_tick.zig").getTicks;

// Responsible for exporting relevant _start and vector table symbols
comptime {
    @import("startup.zig").exportStartSymbol();
    @import("vector_table.zig").exportVectorTable();
}

// Manual register definitions for MMIO we will need access to

// Clock Control
const RCC_BASE: u32 = 0x40023800;
const RCC_AHB1ENR: *volatile u32 = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));

// GPIOA
const GPIOA_BASE: u32 = 0x40020000;
const GPIOA_MODER: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00));
const GPIOA_OTYPER: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x04));
const GPIOA_OSPEEDR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x08));
const GPIOA_PUPDR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x0C));
const GPIOA_ODR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x14));

// Core System Registers (SCB/SYSTICK)
const SCS_BASE: u32 = 0xE000E000;
const SCB_BASE: u32 = SCS_BASE + 0x0D00;
const SCB_SHP3: *volatile u32 = @as(*volatile u32, @ptrFromInt(SCB_BASE + 0x020));
const SYSTICK_BASE: u32 = SCS_BASE + 0x0010;
const SYSTICK_CTRL: *volatile u32 = @as(*volatile u32, @ptrFromInt(SYSTICK_BASE + 0x00));
const SYSTICK_LOAD: *volatile u32 = @as(*volatile u32, @ptrFromInt(SYSTICK_BASE + 0x04));
const SYSTICK_VAL: *volatile u32 = @as(*volatile u32, @ptrFromInt(SYSTICK_BASE + 0x08));

/// Uses the tick counter which is configured to increment every
/// 1 ms to wait.
fn busyWait(milliseconds: u32) void {
    const start_ticks = getTicks();
    // Important to use wrapping subtraction here for when the tick counter might be on the edge of overflowing
    while ((getTicks() -% start_ticks) < milliseconds) {}
}

export fn main() callconv(.C) noreturn {

    // Internal HSI clock is 16 MHz, and is the default used on this chip after boot
    const system_clock_freq = 16_000_000;

    // Configure + enable SysTick Interrupt
    const desired_ticks: u32 = system_clock_freq / 1000; // For 1ms tick interrupts
    SYSTICK_LOAD.* = desired_ticks - 1; // How many clock cycles the interrupt should fire after
    SCB_SHP3.* |= (0b11 << 6) << 24; // Configure Systick to have a priority of 3, this chip only uses the top 2 bits of the priority register
    SYSTICK_VAL.* = 0; // Set counter back to 0
    SYSTICK_CTRL.* = 0b111; // CLKSOURCE = 1 (processor clock), TICKINT = 1 (enable interrupt), ENABLE = 1 (enable systick)

    // Enable GPIOA clock
    RCC_AHB1ENR.* |= 0b1;

    // Not setting GPIOA_OSPEEDR as it defaults to desired value of "slow"
    // Not setting GPIOA_PUPDR as it defaults to desired value of "no pull-up/down"
    // Not setting GPIOA_OTYPER as it defaults to desired value of "output push-pull"

    // Set GPIOA - Pin15 as output, and preserve other pin states
    GPIOA_MODER.* &= 0x3FFFFFFF;
    GPIOA_MODER.* |= 0x60000000;

    while (true) {
        // Toggle pin 15 bit
        GPIOA_ODR.* ^= 0x8000;
        busyWait(1000);

        // A less fancy way to busy wait:
        // var i: u32 = 0;
        // while (i < 1_000_000) {
        //     // Critical so that the compiler doesn't optimize out this loop
        //     asm volatile ("nop");
        //     i += 1;
        // }
    }
}
