const std = @import("std");
const rl = @import("raylib");
const K = @import("constants.zig");

fn randomColor(min: u8) !rl.Color {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var random = std.Random.DefaultPrng.init(seed);
    const r = random.random().intRangeLessThan(u8, min, 255);
    const g = random.random().intRangeLessThan(u8, min, 255);
    const b = random.random().intRangeLessThan(u8, min, 255);
    const a = random.random().uintAtMost(u8, 255);

    return rl.Color.init(r, g, b, a);
}

pub fn createBall() !Ball {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var random = std.Random.DefaultPrng.init(seed);

    const x: f32 = @floatFromInt(random.random().intRangeLessThan(i16, 80, 700));
    const y: f32 = @floatFromInt(random.random().intRangeLessThan(i16, 80, 500));
    const size: f32 = @floatFromInt(random.random().intRangeLessThan(i16, 20, 40));
    const speedX: f32 = @floatFromInt(random.random().intRangeLessThan(i16, -10, 8));
    const speedY: f32 = @floatFromInt(random.random().intRangeLessThan(i16, -10, 8));

    const color = randomColor(128) catch return Ball.init(x, y, size, speedX, speedY, rl.Color.init(222, 222, 222, 222));
    return Ball.init(x, y, size, speedX, speedY, color);
}

pub const Ball = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,

    pub fn init(x: f32, y: f32, size: f32, speedX: f32, speedY: f32, color: rl.Color) Ball {
        return Ball{ .pos = rl.Vector2.init(x, y), .size = rl.Vector2.init(size, size), .speed = rl.Vector2.init(speedX, speedY), .color = color };
    }

    pub fn update(self: *Ball, pad: Pad) void {
        // move to new position
        self.pos = rl.Vector2.add(self.pos, self.speed);

        // check pad is not here
        if (self.pos.x >= pad.pos.x and
            self.pos.x <= (pad.pos.x + pad.size.x) and
            self.pos.y >= pad.pos.y and
            self.pos.y <= (pad.pos.y + pad.size.y))
        {
            self.speed.x *= -2;
        }

        if (self.pos.x + self.size.x > K.screen.width) {
            self.speed.x *= -1;
        }
        if (self.pos.y < 0 or self.pos.y + self.size.y > K.screen.height) {
            self.speed.y *= -1;
        }
    }

    pub fn draw(self: Ball) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }

    pub fn isDead(self: Ball) bool {
        return self.pos.x + self.size.x < 0;
    }
};

pub const Pad = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color = rl.Color.white,

    pub fn init(x: f32, y: f32, w: f32, h: f32) Pad {
        return .{ .pos = rl.Vector2.init(x, y), .size = rl.Vector2.init(w, h) };
    }

    pub fn up(self: *Pad) void {
        if (self.pos.y > 10) {
            self.pos.y -= 5;
        }
    }

    pub fn down(self: *Pad) void {
        if (self.pos.y < 500) {
            self.pos.y += 5;
        }
    }

    pub fn draw(self: Pad) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }
};
