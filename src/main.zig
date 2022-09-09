const ray = @cImport({
    @cInclude("C:/raylib/raylib/src/raylib.h");
});
const std = @import("std");
const math = std.math;
const cmath = math.complex;
const Complex = cmath.Complex;

const screenWidth = 800;
const screenHeight = 450;

//don't use outside of check
fn check_error(guess: Complex(f64), ans: Complex(f64)) f64 {
    return cmath.abs(ans.sub(guess).div(ans)); //don't know how div works 
}
const Check = struct {
    err: f64,
    ans: Complex(f64)
};
///check error 
//(err, ans)
fn check(value: Complex(f64)) Check {
    const a1 = Complex(f64).init(1, 0);
    const e1 = check_error(value, a1);

    const a2 = euler(1, (2.0*math.pi)/3.0);
    const e2 = check_error(value, a2);

    const a3 = euler(1, (4.0*math.pi)/3.0);
    const e3 = check_error(value, a3);
    //really cool sorting 
    var a: Complex(f64) = undefined;
    var e: f64 = undefined;
    if (e1 < e2) {
        if (e1 < e3) {
            e = e1;
            a = a1;
        } else {
            e = e3;
            a = a3;
        }
    } else if (e2 < e3) {
        e = e2;
        a = a2;
    } else {
        e = e3;
        a = a3;
    }
    return Check {
        .err = e,
        .ans = a
    };
}
///translate euler form to cartisien 
fn euler(radius: f32, magnitude: f32) Complex(f64) {
    var r: f32 = math.cos(magnitude) * radius;
    var i: f32 = math.sin(magnitude) * radius;
    return Complex(f64).init(r, i);
}
fn com(n: u8) Complex(f64) {
    return Complex(f64).init(@intToFloat(f64, n), 0.0);
}
///newton optimized root finding function
fn optimized(n: Complex(f64)) Complex(f64) {
    var n_2 = n.mul(n);
    var n_3 = n_2.mul(n);
    return (com(2).mul((n_3)).add(com(1))).div((com(3).mul(n_2)));
}
const Pixel = struct {
    x: f64,
    y: f64,
    trial: f64
};
fn draw() void {
    const max_x = screenWidth;
    const max_y = screenHeight;
    //var list = std.ArrayList(Pixel).init(std.mem.Allocator);
    const scale = 1;
    const acc_err = 0.1;
    const max_trial = 1_000;
    var x: u32 = 1;
    while (x < max_x/scale) {
        var y: u32 = 1;
        while (y < max_y/scale) {
            var trial: u16 = 0;
            var z = Complex(f64).init(@intToFloat(f64, x), @intToFloat(f64, y));
            while (check(z).err > acc_err and trial < max_trial) {
                z = optimized(z);
                trial += 1;
            }
            const color = ray.GetColor(@intCast(c_uint, trial));
            ray.DrawPixel(@intCast(c_int, x*scale), @intCast(c_int, y*scale), color);
            // const pix = Pixel {
            //     .x = x*scale,
            //     .y = y*scale,
            //     .trial = trial
            // };
            // list.append(pix);
            y += 1/scale;
        }
        x += 1/scale;
    }
}

pub fn main() void {    
    ray.InitWindow(screenWidth, screenHeight, "fractal");
    defer ray.CloseWindow();

    ray.SetTargetFPS(1);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        draw();
        
        //ray.DrawText("Hello, World!", 190, 200, 20, ray.LIGHTGRAY);
    }
}