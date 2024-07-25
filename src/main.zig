const std = @import("std");

// Responsible for exporting relevant _start and vector table symbols
comptime {
    @import("startup.zig").exportStartSymbol();
    @import("vector_table.zig").exportVectorTable();
}

const RCC_BASE: u32 = 0x40023800;
const RCC_AHB1ENR: *volatile u32 = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));
const GPIOA_BASE: u32 = 0x40020000;
const GPIOA_MODER: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00));
const GPIOA_OTYPER: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x04));
const GPIOA_OSPEEDR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x08));
const GPIOA_PUPDR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x0C));
const GPIOA_ODR: *volatile u32 = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x14));

export fn main() callconv(.C) noreturn {

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
        var i: u32 = 0;
        while (i < 10_000_000) {
            // Critical so that the compiler doesn't optimize out this loop
            asm volatile ("nop");
            i += 1;
        }
    }
}
