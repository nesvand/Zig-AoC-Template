const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const required_zig_version = std.SemanticVersion.parse("0.10.0") catch unreachable;
const padded_int_fix = std.SemanticVersion.parse("0.11.0-dev.3859+88284c124") catch unreachable;

/// set this to true to link libc
const should_link_libc = false;

fn linkObject(b: *Builder, obj: *LibExeObjStep) void {
    if (should_link_libc) obj.linkLibC();
    _ = b;

    // Padded integers are buggy in 0.10.0, fixed in 0.11.0-dev.331+304e82808
    // This is especially bad for AoC because std.StaticBitSet is commonly used.
    // If your version is older than that, we use stage1 to avoid this bug.
    // Issue: https://github.com/ziglang/zig/issues/13480
    // Fix: https://github.com/ziglang/zig/pull/13637
    if (comptime @import("builtin").zig_version.order(padded_int_fix) == .lt) {
        obj.use_stage1 = true;
    }

    // Add linking for packages or third party libraries here
}

pub fn build(b: *Builder) anyerror!void {
    if (comptime @import("builtin").zig_version.order(required_zig_version) == .lt) {
        std.debug.print(
            \\Error: Your version of Zig is missing features that are needed for this template.
            \\You will need to download a newer build.
            \\
            \\    https://ziglang.org/download/
            \\
            \\
        , .{});
        std.os.exit(1);
    }

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target_options = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // const mode = b.standardReleaseOptions();
    const optimize_options = b.standardOptimizeOption(.{});

    // Steps
    const install_all = b.step("install_all", "Install all days");
    const install_all_tests = b.step("install_tests_all", "Install tests for all days");
    const run_all = b.step("run_all", "Run all days");

    // [[ Template Generation ]] `zig build generate`
    {
        const generate_step = b.step("generate", "Generate stub files from template/template.zig");

        const compile_generate = b.addExecutable(.{
            .name = "generate",
            .root_source_file = .{ .path = "template/generate.zig" },
            .optimize = optimize_options,
            .target = target_options,
        });
        const compile_run = b.addRunArtifact(compile_generate);
        generate_step.dependOn(&compile_run.step);
    }

    var srcDir = try std.fs.cwd().openIterableDir("src", .{});
    defer srcDir.close();
    var walker = try srcDir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind == .file and std.mem.eql(u8, std.fs.path.extension(entry.path), ".zig") and std.mem.eql(u8, std.fs.path.basename(entry.path)[0..3], "day")) {
            const name = try std.mem.replaceOwned(u8, b.allocator, entry.path[0 .. entry.path.len - 4], std.fs.path.sep_str, "-");
            defer b.allocator.free(name);

            const program_path = b.pathJoin(&.{ "src", entry.path });
            const exe = b.addExecutable(.{
                .name = name,
                .root_source_file = .{ .path = program_path },
                .optimize = optimize_options,
                .target = target_options,
            });
            linkObject(b, exe);
            // b.installArtifact(exe); // Not needed because we include an install artifact

            const exe_install_artifact = b.addInstallArtifact(exe);

            // install_<dayxx> steps
            {
                const step_key = b.fmt("install_{s}", .{name});
                const step_desc = b.fmt("Install {s}.exe", .{name});
                const install_step = b.step(step_key, step_desc);
                install_step.dependOn(&exe_install_artifact.step);
                install_all.dependOn(&exe_install_artifact.step);
            }

            // <dayxx> steps - runs <dayxx>.exe after installing
            {
                const run_cmd = b.addRunArtifact(exe);
                run_cmd.step.dependOn(&exe_install_artifact.step);
                if (b.args) |args| {
                    run_cmd.addArgs(args);
                }

                const run_desc = b.fmt("Install and run {s}.exe", .{name});
                const run_step = b.step(name, run_desc);
                run_step.dependOn(&run_cmd.step);
                run_all.dependOn(&run_cmd.step);
            }

            // test_<dayxx> - runs test(s) for <dayxx>
            {
                const run_test = b.addTest(.{
                    .name = b.fmt("test_{s}", .{name}),
                    .root_source_file = .{ .path = program_path },
                    .optimize = optimize_options,
                    .target = target_options,
                });
                linkObject(b, run_test);

                const step_key = b.fmt("test_{s}", .{name});
                const step_desc = b.fmt("Run tests in {s}", .{program_path});
                const step = b.step(step_key, step_desc);
                step.dependOn(&run_test.step);
            }

            // install_tests_<dayxx> - installs test(s) for <dayxx>
            {
                const build_test = b.addTest(.{
                    .name = b.fmt("test_{s}", .{name}),
                    .root_source_file = .{ .path = program_path },
                    .optimize = optimize_options,
                    .target = target_options,
                });
                linkObject(b, build_test);
                const build_test_install_artifact = b.addInstallArtifact(build_test);

                const step_key = b.fmt("install_tests_{s}", .{name});
                const step_desc = b.fmt("Install test_{s}.exe", .{program_path});
                const step = b.step(step_key, step_desc);
                step.dependOn(&build_test_install_artifact.step);
                install_all_tests.dependOn(&build_test_install_artifact.step);
            }
        }
    }

    // Set up tests for util.zig
    {
        const test_util = b.step("test_util", "Run tests in util.zig");
        const test_cmd = b.addTest(.{
            .name = "test_util",
            .root_source_file = .{ .path = "src/util.zig" },
            .optimize = optimize_options,
            .target = target_options,
        });
        linkObject(b, test_cmd);
        test_util.dependOn(&test_cmd.step);
    }

    // Set up test executable for util.zig
    {
        const test_util = b.step("install_tests_util", "Run tests in util.zig");
        const test_exe = b.addExecutable(.{
            .name = "test_util",
            .root_source_file = .{ .path = "src/util.zig" },
            .optimize = optimize_options,
            .target = target_options,
        });
        linkObject(b, test_exe);
        const install = b.addInstallArtifact(test_exe);
        test_util.dependOn(&install.step);
    }

    // Set up a step to run all tests
    {
        const test_step = b.step("test", "Run all tests");
        const test_cmd = b.addTest(.{
            .name = "test_all",
            .root_source_file = .{ .path = "src/test_all.zig" },
            .optimize = optimize_options,
            .target = target_options,
        });
        linkObject(b, test_cmd);
        test_step.dependOn(&test_cmd.step);
    }

    // Set up a step to build tests (but not run them)
    {
        const test_build = b.step("install_tests", "Install test_all.exe");
        const test_exe = b.addExecutable(.{
            .name = "test_all",
            .root_source_file = .{ .path = "src/test_all.zig" },
            .optimize = optimize_options,
            .target = target_options,
        });
        linkObject(b, test_exe);
        const test_exe_install = b.addInstallArtifact(test_exe);
        test_build.dependOn(&test_exe_install.step);
    }
}
