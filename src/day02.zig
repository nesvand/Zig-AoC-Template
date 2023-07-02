const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() anyerror!void {
    try day1();
    try day2();
}

pub fn day1() !void {
    var horizontal: u32 = 0;
    var depth: u32 = 0;
    var pos: usize = 0;

    while (pos < data.len) {
        switch (data[pos]) {
            'u' => {
                // `"up "` = 3 bytes
                var distance = toUnsignedInt(u32, data[pos + 3 ..]);
                depth -= distance.result;
                pos += 3 + distance.size + 1;
            },
            'd' => {
                // `"down "` = 5 bytes
                var distance = toUnsignedInt(u32, data[pos + 5 ..]);
                depth += distance.result;
                pos += 5 + distance.size + 1;
            },
            'f' => {
                // `"forward "` = 8 bytes
                var distance = toUnsignedInt(u32, data[pos + 8 ..]);
                horizontal += distance.result;
                pos += 8 + distance.size + 1;
            },
            else => break,
        }
    }

    print("Part 1: {d}\n", .{depth * horizontal});
}

pub fn day2() anyerror!void {
    var horizontal: u32 = 0;
    var aim: u32 = 0;
    var depth: u32 = 0;
    var pos: usize = 0;

    while (pos < data.len) {
        switch (data[pos]) {
            'u' => {
                var distance = toUnsignedInt(u32, data[pos + 3 ..]);
                aim -= distance.result;

                pos += 3 + distance.size + 1;
            },
            'd' => {
                var distance = toUnsignedInt(u32, data[pos + 5 ..]);
                aim += distance.result;

                pos += 5 + distance.size + 1;
            },
            'f' => {
                var distance = toUnsignedInt(u32, data[pos + 8 ..]);
                horizontal += distance.result;
                depth += aim * distance.result;

                pos += 8 + distance.size + 1;
            },
            else => break,
        }
    }

    print("Part 2: {d}\n", .{depth * horizontal});
}

const toUnsignedInt = util.toUnsignedInt;

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
const window = std.mem.window;

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
