const std = @import("std");
const builtin = @import("builtin");
const raylib_path = "C:/raylib/raylib";

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    const all = b.getInstallStep();
    const mode = b.standardReleaseOptions();
    // zig's mingw headers do not include pthread.h
    //if (std.mem.eql(u8, "core_loading_thread", name) and target.getOsTag() == .windows) continue;

    const exe = b.addExecutable("fractal", "src/main.zig");
    // exe.addCSourceFile(path, switch (target.getOsTag()) {
    //     .windows => &[_][]const u8{},
    //     .linux => &[_][]const u8{},
    //     .macos => &[_][]const u8{"-DPLATFORM_DESKTOP"},
    //     else => @panic("Unsupported OS"),
    // });
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC();
    exe.addObjectFile(switch (target.getOsTag()) {
        .windows => raylib_path ++ "/src/raylib.lib",
        .linux => raylib_path ++ "/src/libraylib.a",
        .macos => raylib_path ++ "/src/libraylib.a",
        else => @panic("Unsupported OS"),
    });

    exe.addIncludeDir(raylib_path ++ "/src");
    exe.addIncludeDir(raylib_path ++ "/src/external");
    exe.addIncludeDir(raylib_path ++ "/src/external/glfw/include");

    switch (exe.target.toTarget().os.tag) {
        .windows => {
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("opengl32");
            exe.addIncludeDir("external/glfw/deps/mingw");
        },
        .linux => {
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("rt");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
            exe.linkSystemLibrary("X11");
        },
        .macos => {
            exe.linkFramework("Foundation");
            exe.linkFramework("Cocoa");
            exe.linkFramework("OpenGL");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("IOKit");
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    exe.setOutputDir("./out");

    // var run = exe.run();
    // run.step.dependOn(&b.addInstallArtifact(exe).step);
    // run.cwd = module;
    //b.step(name, name).dependOn(&run.step);
    all.dependOn(&exe.step);
}
