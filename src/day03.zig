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

fn day1() !void {
    var reading_length = indexOf(u8, data, '\n').?;
    var reading_count = data.len / (reading_length + 1);
    var ones_count_table = try gpa.alloc(u32, @as(usize, reading_length));
    defer gpa.free(ones_count_table);
    for (ones_count_table) |*t|
        t.* = 0;

    var pos: usize = 0;
    while (pos < data.len) : (pos += reading_length + 1) {
        // exit on erroneous last line
        if (pos + reading_length + 1 > data.len) {
            break;
        }

        for (data[pos .. pos + reading_length]) |c, i| {
            ones_count_table[i] += c - '0';
        }
    }

    var gamma: u12 = 0;
    for (ones_count_table) |count| {
        gamma <<= 1;
        gamma += @boolToInt((count << 1) >= reading_count);
    }

    print("power consumption: {d}\n", .{@as(u32, gamma) * @as(u32, ~gamma)});
}

fn day2() !void {
    var readings = data;
    var reading_length = indexOf(u8, readings, '\n').?;
    // explain
    var bit_count_tree = try gpa.alloc(u32, std.math.pow(usize, 2, reading_length + 1));
    defer gpa.free(bit_count_tree);
    for (bit_count_tree) |*t|
        t.* = 0;

    var readings_pos: usize = 0;
    while (readings_pos < readings.len) : (readings_pos += reading_length + 1) {
        // exit on erroneous last line
        if (readings_pos + reading_length + 1 > readings.len) {
            break;
        }

        // The table represents a binary tree containing the count of `0`s and `1`s for a given prior sequence of `0`s and `1`s.
        // The root of the tree is at index 1, and the left and right children of a node at index `i` are at indices `i * 2 + 1`
        // and `(i + 1) * 2 + 1` respectively. The count of `0`s is stored at index `i - 1` and the count of `1`s is stored
        // at index `i`.
        //
        // ie. starting at a node index of 1 (root), the count of `0`s is located at index 0, and the count of `1`s is located
        // at index 1. If the value is a `0` we move to the left child index at `(i + char - '0') * 2 + 1 = 3`. If the value is a
        // `1` we move to the right child index at `(i + char - '0') * 2 + 1 = 5`.
        var node_i: u32 = 1;
        for (readings[readings_pos .. readings_pos + reading_length]) |char| {
            bit_count_tree[node_i + char - '0' - 1] += 1;
            node_i += char - '0';
            node_i *= 2;
            node_i += 1;
        }
    }

    const c_rating = calculateChemical(.co2, reading_length, bit_count_tree);
    const o_rating = calculateChemical(.oxygen, reading_length, bit_count_tree);

    print("life support rating: {d}\n", .{@as(u32, c_rating) * @as(u32, o_rating)});
}

const Chemical = enum {
    oxygen,
    co2,
};

fn calculateChemical(comptime chemical: Chemical, reading_length: usize, bit_count_tree: []u32) u32 {
    var i: usize = 0;
    var node_i: usize = 1;
    var result: u32 = 0;

    while (i < reading_length) : (i += 1) {
        var zeros_count = bit_count_tree[node_i - 1];
        var ones_count = bit_count_tree[node_i];
        var res: u32 = switch (chemical) {
            // rule: keep entries with the most common bit, or 1 if equal
            .oxygen => block: {
                // If there is only one total count, we already know the result. We can walk the rest of the tree to
                // the leaf by following the branch with the count of 1.
                if (zeros_count + ones_count == 1) {
                    break :block 1 - zeros_count;
                    // the above is equivalent to:
                    // :block if (ones_count > zeros_count) @as(u32, 1) else @as(u32, 0);
                }
                break :block @boolToInt(zeros_count <= ones_count);
            },
            // rule: keep entries with the least common bit, or 0 if equal
            .co2 => block: {
                if (zeros_count + ones_count == 1) {
                    break :block 1 - zeros_count;
                }
                break :block @boolToInt(zeros_count > ones_count);
            },
        };

        result <<= 1;
        result += res;
        node_i += res;
        node_i *= 2;
        node_i += 1;
    }

    return result;
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
