const std = @import("std");

var tick_counter: u32 = 0;

pub fn tickHandler() callconv(.C) void {
    // Fancy addition that allows this tick counter to overflow + wrap back around to 0
    tick_counter +%= 1;
}

/// Note that the volatile access does NOT guarantee atomic access. We are just relying
/// on the fact that single word accesses are atomic on this CPU. If instead of
/// just reading a value we had to do a read-modify-write sequence, we would need to disable/re-enable
/// interrupts like so to prevent data races
///
/// disableInterrupts()
/// tick_counter = tick_counter * 5;
/// enableInterrupts()
pub fn getTicks() u32 {

    // Volatile access to ensure this variable access can NOT
    // get optimized away given the ISR can change it at any point
    return @as(*volatile u32, @ptrCast(&tick_counter)).*;
}
