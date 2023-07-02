const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() anyerror!void {
    try part1();
    try part2();
}

pub fn part1() !void {
    var result: u32 = 0;
    // 4 slot ringbuffer, initialized with max value - convenient to index through
    // with a `u2` counter
    //
    // for `**` syntax - see: https://ziglearn.org/chapter-1/#comptime
    var parsed: [4]u32 = [_]u32{std.math.maxInt(u32)} ** 4;
    var n: u2 = 0;
    var pos: usize = 0;

    while (pos < data.len) : (n +%= 1) {
        // `toUnsignedInt` returns a tuple of the parsed value and the number of bytes.
        // This is non-destructive and parses up to the first non-digit character ie. `'\n'`.
        var val = toUnsignedInt(u32, data[pos..]);
        parsed[n] = val.result;
        result += @boolToInt(parsed[n] > parsed[n -% 1]);
        // We need to add 1 to the number of bytes to skip the newline.
        pos += val.size + 1;
    }

    print("part 1: {d}\n", .{result});
}

pub fn part2() anyerror!void {
    var result: u32 = 0;
    var parsed: [4]u32 = [_]u32{std.math.maxInt(u32)} ** 4;
    var n: u2 = 0;
    var pos: usize = 0;

    while (pos < data.len) : (n +%= 1) {
        var val = toUnsignedInt(u32, data[pos..]);
        parsed[n] = val.result;
        // We're interested in the difference of two windows consisting of 3 numbers.
        // The middle elements are shared, so they can be ignored, meaning the comparison
        // is only between the first number of the first window and last number of the
        // second window.
        result += @boolToInt(parsed[n] > parsed[n -% 3]);
        pos += val.size + 1;
    }

    print("part 2: {d}\n", .{result});
}

// Useful util functions
const window = util.window;
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
