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

fn randomColor() !rl.Color {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var random = std.Random.DefaultPrng.init(seed);
    const r = random.random().uintAtMost(u8, 255);
    const g = random.random().uintAtMost(u8, 255);
    const b = random.random().uintAtMost(u8, 255);
    const a = random.random().uintAtMost(u8, 255);

    return rl.Color.init(r, g, b, a);
}

pub fn createBall(seed: u64) Ball {
    // var rand = std.rand.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
    var rand = std.rand.DefaultPrng.init(seed);
    const randU8 = rand.random();

    const x: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 80, 700));
    const y: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 80, 500));
    const size: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 20, 40));
    const speed: f32 = @floatFromInt(randU8.intRangeLessThan(i16, 2, 8));

    const color = randomColor() catch return Ball.init(x, y, size, speed, rl.Color.init(222, 222, 222, 222));
    return Ball.init(x, y, size, speed, color);
}

const Ball = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,

    pub fn init(x: f32, y: f32, size: f32, speed: f32, color: rl.Color) Ball {
        return Ball{ .pos = rl.Vector2.init(x, y), .size = rl.Vector2.init(size, size), .speed = rl.Vector2.init(speed, speed), .color = color };
    }

    pub fn update(self: *Ball) void {
        self.pos = rl.Vector2.add(self.pos, self.speed);
        if (self.pos.x < 0 or self.pos.x + self.size.x > K.screen.width) {
            self.speed.x *= -1;
        }
        if (self.pos.y < 0 or self.pos.y + self.size.y > K.screen.height) {
            self.speed.y *= -1;
        }
    }

    pub fn draw(self: Ball) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }
};

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

    const seed = @as(u64, undefined);

    var prng = std.rand.DefaultPrng.init(seed);
    const rand = prng.random();

    // balls
    const R = randx.Randx.init();
    // for (0..12) |_| {
    //     std.debug.print("Randx {}\n", .{R.someRand()});
    // }
    std.debug.print("What is R? {}", .{R});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var balls = std.ArrayList(Ball).init(allocator);
    defer balls.deinit();

    var i: u64 = 0;
    while (i < 20) : (i += 1) {
        // const ball = createBall();
        try balls.append(createBall(i));
    }

    var pad = els.Pad.init(10, 10, 20, 60);

    var randomShot = rand.intRangeLessThan(i32, 0, 100);
    var key: rl.KeyboardKey = undefined;
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (@rem(frameCounter, 60) == 0) {
            randomShot = rand.intRangeLessThan(i32, 0, 100);
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

        for (balls.items) |*ball| {
            ball.draw();
            ball.update();
        }

        key = rl.getKeyPressed();

        if (key == rl.KeyboardKey.key_a) {
            try balls.append(createBall(200));
        } else if (key == rl.KeyboardKey.key_d) {
            _ = balls.swapRemove(0);
        } else if (key == rl.KeyboardKey.key_w) {
            _ = pad.up();
        } else if (key == rl.KeyboardKey.key_s) {
            _ = pad.down();
        }
    }
}
