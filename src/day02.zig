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

pub fn day1() anyerror!void {
    var lines = split(u8, data, "\n");

    var depth: u32 = 0;
    var horiz: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var parts = split(u8, line, " ");
        var directions = List([]const u8).init(gpa);
        while (parts.next()) |part| {
            if (part.len == 0) {
                continue;
            }
            try directions.append(part);
        }
        const direction = directions.items[0];
        var range = try parseInt(u32, directions.items[1], 10);
        if (std.mem.eql(u8, direction, "up")) {
            depth -= range;
        } else if (std.mem.eql(u8, direction, "down")) {
            depth += range;
        } else if (std.mem.eql(u8, direction, "forward")) {
            horiz += range;
        } else {
            unreachable;
        }
    }
    print("{}\n", .{depth * horiz});
}

pub fn day2() anyerror!void {
    var lines = split(u8, data, "\n");

    var depth: u32 = 0;
    var horiz: u32 = 0;
    var aim: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var parts = split(u8, line, " ");
        var directions = List([]const u8).init(gpa);
        while (parts.next()) |part| {
            if (part.len == 0) {
                continue;
            }
            try directions.append(part);
        }
        const direction = directions.items[0];
        var range = try parseInt(u32, directions.items[1], 10);
        if (std.mem.eql(u8, direction, "up")) {
            aim -= range;
        } else if (std.mem.eql(u8, direction, "down")) {
            aim += range;
        } else if (std.mem.eql(u8, direction, "forward")) {
            horiz += range;
            depth += aim * range;
        } else {
            unreachable;
        }
    }
    print("{}\n", .{depth * horiz});
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
