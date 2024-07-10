const rl = @import("raylib");
const K = @import("constants.zig");

pub const Pad = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color = rl.Color.white,

    pub fn init(x: f32, y: f32, w: f32, h: f32) Pad {
        return .{ .pos = rl.Vector2.init(x, y), .size = rl.Vector2.init(w, h) };
    }

    pub fn up(self: *Pad) void {
        if (self.pos.y > 10) {
            self.pos.y -= 10;
        }
    }

    pub fn down(self: *Pad) void {
        if (self.pos.y < 500) {
            self.pos.y += 10;
        }
    }

    pub fn draw(self: Pad) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }
};
