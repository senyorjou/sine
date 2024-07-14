// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const rl = @import("raylib");
const K = @import("constants.zig");
const els = @import("elements.zig");
const randx = @import("randx.zig");

const Allocator = std.mem.Allocator;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.initWindow(K.screen.width, K.screen.height, "Some boxes");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var frameCounter: i32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // balls
    var balls = std.ArrayList(els.Ball).init(allocator);
    defer balls.deinit();

    var i: u8 = 0;
    while (i < 40) : (i += 1) {
        try balls.append(try els.createBall());
    }
    var dead_ball: i16 = -1;

    // pad
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

        // catch key pressed
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
