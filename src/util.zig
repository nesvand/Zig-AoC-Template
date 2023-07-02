const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

// Add utility functions here

pub fn WindowIterator(comptime T: type) type {
    return struct {
        buffer: []const T,
        index: ?usize,
        size: usize,
        advance: usize,

        const Self = @This();

        /// Returns a slice of the first window. This never fails.
        /// Call this only to get the first window and then use `next` to get
        /// all subsequent windows.
        pub fn first(self: *Self) []const T {
            assert(self.index.? == 0);
            return self.next().?;
        }

        /// Returns a slice of the next window, or null if window is at end.
        pub fn next(self: *Self) ?[]const T {
            const start = self.index orelse return null;
            const next_index = start + self.advance;
            const end = if (start + self.size < self.buffer.len and next_index < self.buffer.len) blk: {
                self.index = next_index;
                break :blk start + self.size;
            } else blk: {
                self.index = null;
                break :blk self.buffer.len;
            };

            return self.buffer[start..end];
        }

        /// Resets the iterator to the initial window.
        pub fn reset(self: *Self) void {
            self.index = 0;
        }
    };
}

pub fn window(comptime T: type, buffer: []const T, size: usize, advance: usize) WindowIterator(T) {
    assert(size != 0);
    assert(advance != 0);
    return .{
        .index = 0,
        .buffer = buffer,
        .size = size,
        .advance = advance,
    };
}

// from https://github.com/jchevertonwynne/advent-of-code-2021/blob/main/src/util.zig
pub fn Result(comptime T: type) type {
    return struct {
        result: T,
        size: usize,
    };
}

// from https://github.com/jchevertonwynne/advent-of-code-2021/blob/main/src/util.zig
pub fn toUnsignedInt(comptime T: type, contents: []const u8) Result(T) {
    if (@typeInfo(T).Int.signedness == .signed)
        @compileError("must supply a signed integer");

    var result: T = 0;
    var characters: usize = 0;

    for (contents) |char, i| {
        if ('0' <= char and char <= '9') {
            result *= 10;
            result += @as(T, char - '0');
            characters = i;
        } else break;
    }

    return .{ .result = result, .size = characters + 1 };
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
