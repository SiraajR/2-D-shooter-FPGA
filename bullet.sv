`timescale 1 ps / 1 ps

// bullet Module
// Manages bullet firing mechanics, including bullet movement, rendering, and state management for player bullets.
module bullet (
    input logic clk,                   // Clock signal
    input logic reset,                 // Reset signal
    input logic fire,                  // Trigger to fire bullet
    input logic [9:0] char_x,          // Player character X-coordinate
    input logic [8:0] char_y,          // Player character Y-coordinate
    input logic [9:0] x,               // Current VGA pixel X-coordinate
    input logic [8:0] y,               // Current VGA pixel Y-coordinate
    output logic bullet_fired,         // Indicates bullet pixel active at current VGA coordinates
    output logic [7:0] bullet_r,       // Bullet red color output
    output logic [7:0] bullet_g,       // Bullet green color output
    output logic [7:0] bullet_b,       // Bullet blue color output
    output logic active,               // Bullet active state
    output logic [9:0] bull_x,         // Current bullet X-coordinate
    output logic [8:0] bull_y          // Current bullet Y-coordinate
);

    parameter BULLET_SPEED = 4;        // Bullet speed
    parameter BULLET_SIZE = 4;         // Bullet size (width and height)

    // Internal signals for bullet position
    logic [9:0] bullet_x;
    logic [8:0] bullet_y;

    // Bullet movement logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            bullet_x <= 0;
            bullet_y <= 0;
            active <= 0;
        end else if (fire) begin
            bullet_x <= char_x + 8;  // Start bullet from center of player
            bullet_y <= char_y + 8;
            active <= 1;
        end else if (active) begin
            if (bullet_x > 639) begin
                active <= 0;  // Deactivate bullet if it leaves screen
            end else begin
                bullet_x <= bullet_x + BULLET_SPEED;
            end
        end
        bull_x <= bullet_x;
        bull_y <= bullet_y;
    end

    // Rendering logic for bullet pixels
    always_comb begin
        bullet_fired = 0;
        bullet_r = 8'hFF;  // Yellow color
        bullet_g = 8'hFF;
        bullet_b = 8'h00;

        if (active && (x >= bullet_x && x < bullet_x + BULLET_SIZE) &&
            (y >= bullet_y && y < bullet_y + BULLET_SIZE)) begin
            bullet_fired = 1;
        end
    end

endmodule // bullet