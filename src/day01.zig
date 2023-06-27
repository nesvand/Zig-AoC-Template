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

pub fn part1() anyerror!void {
    var lines = split(u8, data, "\n");
    var prev: u32 = try parseInt(u32, lines.first(), 10);
    var counter: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var next: u32 = try parseInt(u32, line, 10);
        if (prev < next) {
            counter += 1;
        }
        prev = next;
    }
    print("{d}\n", .{counter});
}

pub fn part2() anyerror!void {
    var lines = split(u8, data, "\n");
    var nums = List(u32).init(gpa);
    defer nums.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var val: u32 = try parseInt(u32, line, 10);
        try nums.append(val);
    }
    var windows = window(u32, nums.items, 3, 1);
    const peek = windows.first();
    var prev: u32 = peek[0] + peek[1] + peek[2];
    var counter: u32 = 0;
    while (windows.next()) |w| {
        const curr = w[0] + w[1] + w[2];
        if (curr > prev) {
            counter += 1;
        }
        prev = curr;
    }
    print("{d}\n", .{counter});
}

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
