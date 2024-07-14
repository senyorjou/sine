// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const rl = @import("raylib");
const K = @import("constants.zig");
const els = @import("elements.zig");
const randx = @import("randx.zig");

const Allocator = std.mem.Allocator;

// pub fn initRandom() std.Random {
//     const prng = std.rand.DefaultPrng.init(blk: {
//         var seed: u64 = undefined;
//         try std.posix.getrandom(std.mem.asBytes(&seed));
//         break :blk seed;
//     });
//     return prng;
// }
//
//

pub fn printRandom() void {
    const T: u64 = @intCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(T); // seed chosen by dice roll
    const random = prng.random();
    var i: u8 = 0;
    while (i < 10) {
        std.debug.print("\nDice roll: {} - {}", .{ random.intRangeLessThan(u8, 0, 100), random.float(f32) });
        i += 1;
    }
}

// fn randomColor() !rl.Color {
//     var seed: u64 = undefined;
//     try std.posix.getrandom(std.mem.asBytes(&seed));
//     var random = std.Random.DefaultPrng.init(seed);
//     const r = random.random().uintAtMost(u8, 255);
//     const g = random.random().uintAtMost(u8, 255);
//     const b = random.random().uintAtMost(u8, 255);
//     const a = random.random().uintAtMost(u8, 255);
//
//     return rl.Color.init(r, g, b, a);
// }

// pub fn createBall(seed: u64) Ball {
//     // var rand = std.rand.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
//     var rand = std.rand.DefaultPrng.init(seed);
//     const randU8 = rand.random();
//
//     const x: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 80, 700));
//     const y: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 80, 500));
//     const size: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 20, 40));
//     const speed: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 2, 8));
//
//     const color = randomColor() catch return Ball.init(x, y, size, speed, rl.Color.init(222, 222, 222, 222));
//     return Ball.init(x, y, size, speed, color);
// }
//

// pub fn initRandom() std.Random {
//     const seed = @as(u64, undefined);
//
//     var prng = std.rand.DefaultPrng.init(seed);
//     return prng.random();
// }

pub fn printRand(rand: std.Random) u32 {
    std.debug.print("Hey {!}", .{rand});

    return rand.intRangeLessThan(u32, 0, 800);
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.initWindow(K.screen.width, K.screen.height, "Some boxes");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var frameCounter: i32 = 0;

    // balls

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var balls = std.ArrayList(els.Ball).init(allocator);
    defer balls.deinit();

    var i: u8 = 0;
    while (i < 40) : (i += 1) {
        try balls.append(try els.createBall());
    }
    var dead_ball: i16 = -1;
    var pad = els.Pad.init(10, 200, 20, 60);

    var key: rl.KeyboardKey = undefined;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (@rem(frameCounter, 60) == 0) {
            try balls.append(try els.createBall());
        }
        frameCounter += 1;

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        // rl.drawText("Every 2 seconds a new random value is generated:", 10, 10, 20, rl.Color.purple);
        // rl.drawText(rl.textFormat("%d", .{randomShot}), 430, 30, 30, rl.Color.light_gray);

        pad.draw();

        // move balls
        for (0.., balls.items) |index, *ball| {
            ball.draw();
            ball.update(pad);
            if (ball.isDead()) {
                dead_ball = @as(i16, @intCast(index));
            }
        }

        // catch dead balls
        if (dead_ball > -1) {
            _ = balls.swapRemove(@as(usize, @intCast(dead_ball)));
            dead_ball = -1;
        }

        key = rl.getKeyPressed();

        if (key == rl.KeyboardKey.key_a) {
            try balls.append(try els.createBall());
        } else if (key == rl.KeyboardKey.key_d) {
            _ = balls.swapRemove(0);
        }

        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            _ = pad.down();
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            _ = pad.up();
        }
    }
}
