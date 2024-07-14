const std = @import("std");

pub const Randx = struct {
    prng: std.Random.DefaultPrng,
    random: std.rand.Random,

    pub fn init() Randx {
        const time: u64 = @intCast(std.time.timestamp());
        var prng = std.rand.DefaultPrng.init(time);
        const random = prng.random();

        return .{ .prng = prng, .random = random };
    }

    pub fn someRand(self: *Randx) u8 {
        for (0..10) |_| {
            std.debug.print("Random: {}", .{self.random.intRangeLessThan(u8, 0, 25)});
        }
        return self.random.intRangeLessThan(u8, 0, 25);
    }
};
