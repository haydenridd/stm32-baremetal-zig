const std = @import("std");

var tick_counter: u32 = 0;

pub fn tickHandler() callconv(.C) void {
    // Fancy addition that allows this tick counter to overflow + wrap back around to 0
    tick_counter +%= 1;
}

/// Note that this does NOT guarantee atomic access, we're sort of lazily
/// relying on single word accesses being inherently atomic on this chip.
pub fn getTicks() u32 {

    // Volatile access to ensure this variable access can NOT
    // get optimized away given the ISR can change it at any point
    return @as(*volatile u32, @ptrCast(&tick_counter)).*;
}
