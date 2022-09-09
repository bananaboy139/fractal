const ray = @cImport({
    @cInclude("C:/raylib/raylib/src/raylib.h");
});
const std = @import("std");
const math = std.math;

const screenWidth = 1200;
const screenHeight = 850;
var shader: ray.Shader = ray.LoadShader(0, ray.TextFormat("./shader/fractal.fs", 330));
fn draw(x_offset: i32, y_offset: i32, intensity: u16) void {
    const max_x = screenWidth;
    const max_y = screenHeight;
    const acc_err = 0.1;
    const max_trial = 1_000;
    var x: i32 = 0 + x_offset;
    while (x < (max_x + x_offset)) {
        var y: i32 = 0 + y_offset;
        while (y < (max_y + y_offset)) {
            //call shader
            const color = ray.GetColor(@intCast(c_uint, trial * intensity) + 20_000);
            ray.DrawPixel(@intCast(c_int, (x-x_offset)), @intCast(c_int, (y-y_offset)), color);
            y += 1;
        }
        x += 1;
    }
}
// const print = std.debug.print;
const Keys = enum(u16) {
    right = 262,
    left = 263,
    up = 265,
    down = 264,
    space = 32,
    shift = 340,
    w = 87,
    s = 83,
};
const step = 200;
pub fn main() void {    
    ray.InitWindow(screenWidth, screenHeight, "fractal");
    defer ray.CloseWindow();
    
    ray.SetTargetFPS(60);
    var x_offset: i32 = -screenWidth/2;
    var y_offset: i32 = -screenHeight/2;
    var color: u16 = 1;
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        defer ray.UnloadShader(shader);
        ray.ClearBackground(ray.RAYWHITE);
        color = (color + 1);
        draw(x_offset, y_offset, color);

        switch (@intCast(i32, ray.GetKeyPressed())) {
            @enumToInt(Keys.right) => {
                x_offset += step;
            },
            @enumToInt(Keys.left) => {
                x_offset -= step;
            },
            @enumToInt(Keys.up) => {
                y_offset -= step;
            },
            @enumToInt(Keys.down) => {
                y_offset += step;
            },
            else => {}

            // @enumToInt(Keys.space)
            // @enumToInt(Keys.shift)
            // @enumToInt(Keys.w)
            // @enumToInt(Keys.s)
        }


        // const k = @intCast(i32, ray.GetKeyPressed());
        // if (k != 0) {
        //     print("Key:{} ", .{k});
        // }
        
    }
}
//"C:\raylib\zig\zig.exe" build

