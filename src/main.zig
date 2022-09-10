const ray = @cImport({
    @cInclude("C:/raylib/raylib/src/raylib.h");
});
const std = @import("std");

const screenWidth = 1800;
const screenHeight = 1250;

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

    var target: ray.RenderTexture2D = ray.LoadRenderTexture(ray.GetScreenWidth(), ray.GetScreenHeight());
    var shader: ray.Shader = ray.LoadShader(0, "../src/shader/fractal.fs");
    defer ray.UnloadShader(shader);

    var _screendims: c_int = ray.GetShaderLocation(shader, "screenDims");
    var _acceptable_err: c_int = ray.GetShaderLocation(shader, "acceptable_err");
    var _max_trial: c_int = ray.GetShaderLocation(shader, "max_trial");
    var _offset: c_int = ray.GetShaderLocation(shader, "offset");
    var _zoom: c_int = ray.GetShaderLocation(shader, "zoom");
    
    var screendims = [2]f32{@intToFloat(f32, ray.GetScreenWidth()), @intToFloat(f32, ray.GetScreenHeight())};
    var acceptable_err: f32 = 0.0001;
    var max_trial: c_int = 100_000;
    var offset = [2]f32{@intToFloat(f32, -ray.GetScreenWidth())/2.0, @intToFloat(f32, -ray.GetScreenHeight())/2.0};
    var zoom: f32 = 1.0; 

    ray.SetShaderValue(shader, _screendims, &screendims, ray.SHADER_UNIFORM_VEC2);
    ray.SetShaderValue(shader, _acceptable_err, &acceptable_err, ray.SHADER_UNIFORM_FLOAT);
    ray.SetShaderValue(shader, _max_trial, &max_trial, ray.SHADER_UNIFORM_INT);
    ray.SetShaderValue(shader, _offset, &offset, ray.SHADER_UNIFORM_VEC2);
    ray.SetShaderValue(shader, _zoom, &zoom, ray.SHADER_UNIFORM_FLOAT);
    
    while (!ray.WindowShouldClose()) {
        //DRAW
        ray.BeginTextureMode(target);
            ray.DrawRectangle(0, 0, ray.GetScreenWidth(),ray.GetScreenHeight(), ray.BLACK);
        ray.EndTextureMode();

        ray.BeginDrawing();
        defer ray.EndDrawing();
        
        ray.ClearBackground(ray.RAYWHITE);

        ray.BeginShaderMode(shader);
            ray.DrawTextureEx(target.texture, ray.Vector2 {.x = 0.0, .y = 0.0} , @as(f32, 0.0), @as(f32, 1.0), ray.WHITE);
        ray.EndShaderMode();

        ray.SetShaderValue(shader, _offset, &offset, ray.SHADER_UNIFORM_VEC2);
        ray.SetShaderValue(shader, _zoom, &zoom, ray.SHADER_UNIFORM_FLOAT);

        switch (@intCast(i32, ray.GetKeyPressed())) {
            @enumToInt(Keys.right) => {
                offset[0] += step;
            },
            @enumToInt(Keys.left) => {
                offset[0] -= step;
            },
            @enumToInt(Keys.up) => {
                offset[1] -= step;
            },
            @enumToInt(Keys.down) => {
                offset[1] += step;
            },
            @enumToInt(Keys.w) => {
                zoom += 10;
            },
            @enumToInt(Keys.s) => {
                zoom -= 1;
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

