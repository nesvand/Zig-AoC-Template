const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() anyerror!void {
    try day1();
    try day2();
}

const Bits = struct {
    zero: u32,
    one: u32,
};

const bit_position_len = 12;

pub fn day1() anyerror!void {
    var bit_positions = List(Bits).init(gpa);
    defer bit_positions.deinit();
    var ii: u4 = 0;
    while (ii < bit_position_len) : (ii += 1) {
        try bit_positions.append(Bits{ .zero = 0, .one = 0 });
    }

    var lines = split(u8, data, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const val = try std.fmt.parseInt(u12, line, 2);

        var i: u4 = 0;
        while (i < bit_position_len) : (i += 1) {
            var bit_position = bit_positions.items[i];

            const bit = (val >> bit_position_len - i - 1) & 1;
            if (bit == 0) {
                bit_position.zero += 1;
            } else {
                bit_position.one += 1;
            }
            bit_positions.items[i] = bit_position;
        }
    }

    var gamma_rate: u12 = 0;
    var epsilon_rate: u12 = 0;
    var i: u4 = 0;
    while (i < bit_position_len) : (i += 1) {
        const bitPosition = bit_positions.items[i];
        const zero = bitPosition.zero;
        const one = bitPosition.one;
        gamma_rate |= if (zero > one) 0 else @as(u12, 1) << bit_position_len - i - 1;
        epsilon_rate |= if (one > zero) 0 else @as(u12, 1) << bit_position_len - i - 1;
    }

    print("power consumption: {d}\n", .{@as(u64, gamma_rate) * @as(u64, epsilon_rate)});
}

fn counts(readings: []u12) anyerror!List(Bits) {
    var bit_positions = List(Bits).init(gpa);
    var ii: u4 = 0;
    while (ii < bit_position_len) : (ii += 1) {
        try bit_positions.append(Bits{ .zero = 0, .one = 0 });
    }

    for (readings) |val| {
        var i: u4 = 0;
        while (i < bit_position_len) : (i += 1) {
            var bit_position = bit_positions.items[i];

            const bit = (val >> bit_position_len - i - 1) & 1;
            if (bit == 0) {
                bit_position.zero += 1;
            } else {
                bit_position.one += 1;
            }
            bit_positions.items[i] = bit_position;
        }
    }

    return bit_positions;
}

fn oxygenGeneratorRating(readings: List(u12)) anyerror!u12 {
    var remaining_readings = readings;

    var pos: u4 = 0;
    while (remaining_readings.items.len != 1) {
        var new_readings = List(u12).init(gpa);
        var c = try counts(remaining_readings.items);
        defer c.deinit();

        for (remaining_readings.items) |reading| {
            var bit_position_count = c.items[pos];
            if (bit_position_count.zero > bit_position_count.one) {
                const bit = (reading >> bit_position_len - pos - 1) & 1;
                if (bit == 0) {
                    try new_readings.append(reading);
                }
            } else {
                const bit = (reading >> bit_position_len - pos - 1) & 1;
                if (bit == 1) {
                    try new_readings.append(reading);
                }
            }
        }

        remaining_readings.deinit();
        remaining_readings = new_readings;

        pos += 1;
    }
    defer remaining_readings.deinit();
    return remaining_readings.items[0];
}

fn c02ScrubberRating(readings: List(u12)) anyerror!u12 {
    var remaining_readings = readings;

    var pos: u4 = 0;
    while (remaining_readings.items.len != 1) {
        var new_readings = List(u12).init(gpa);
        var c = try counts(remaining_readings.items);
        defer c.deinit();

        for (remaining_readings.items) |reading| {
            var bit_position_count = c.items[pos];
            if (bit_position_count.zero > bit_position_count.one) {
                const bit = (reading >> bit_position_len - pos - 1) & 1;
                if (bit == 1) {
                    try new_readings.append(reading);
                }
            } else {
                const bit = (reading >> bit_position_len - pos - 1) & 1;
                if (bit == 0) {
                    try new_readings.append(reading);
                }
            }
        }

        remaining_readings.deinit();
        remaining_readings = new_readings;

        pos += 1;
    }
    defer remaining_readings.deinit();
    return remaining_readings.items[0];
}

pub fn day2() anyerror!void {
    var bit_numbers = List(u12).init(gpa);
    defer bit_numbers.deinit();

    var lines = split(u8, data, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        try bit_numbers.append(try std.fmt.parseInt(u12, line, 2));
    }
    const c_rating = try c02ScrubberRating(try bit_numbers.clone());
    const o_rating = try oxygenGeneratorRating(try bit_numbers.clone());
    print("life support rating: {d}\n", .{@as(u32, c_rating) * @as(u32, o_rating)});
}

// Useful util functions
const window = util.window;

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
