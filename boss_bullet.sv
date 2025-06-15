`timescale 1 ps / 1 ps

// boss_bullet Module
// Handles bullet firing mechanics for the final boss, including bullet movement, rendering, and collision detection with the player.
module boss_bullet (
    input logic clk,                          // Clock signal
    input logic reset,                        // Reset signal
    input logic fire,                         // Trigger signal to fire the bullet
    input logic [9:0] start_x,                // Bullet initial X-coordinate (typically boss_x)
    input logic [8:0] start_y,                // Bullet initial Y-coordinate (typically boss_y + offset)
    input logic [9:0] x,                      // VGA pixel scan X-coordinate
    input logic [8:0] y,                      // VGA pixel scan Y-coordinate
    input logic [9:0] char_x,                 // Player character X-coordinate
    input logic [8:0] char_y,                 // Player character Y-coordinate

    output logic bullet_pix,                  // Indicates if current pixel overlaps bullet
    output logic [7:0] bullet_r,              // Bullet red color output
    output logic [7:0] bullet_g,              // Bullet green color output
    output logic [7:0] bullet_b,              // Bullet blue color output
    output logic bullet_hit                   // Signal indicating collision with player
);

    // Constants defining bullet dimensions and screen limits
    localparam BULLET_WIDTH = 5;
    localparam BULLET_HEIGHT = 5;
    localparam SCREEN_WIDTH = 200;
    localparam SCREEN_HEIGHT = 300;

    // Internal state signals for bullet management
    logic active;                             // Bullet active state
    logic [9:0] bullet_x;                     // Current bullet X-coordinate
    logic [8:0] bullet_y;                     // Current bullet Y-coordinate

    // Bullet movement logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            active <= 0;
            bullet_x <= start_x;
            bullet_y <= start_y;
        end else if (fire && !active) begin
            active <= 1;
            bullet_x <= start_x;
            bullet_y <= start_y;
        end else if (active) begin
            if (bullet_x - BULLET_WIDTH == 0) begin
                active <= 0;
            end else begin
                bullet_x <= bullet_x - 2;  // Adjust bullet speed as necessary
            end
        end
    end

    // Rendering logic to determine if current pixel is within bullet region
    assign bullet_pix = active &&
                        (x >= bullet_x) && (x < bullet_x + BULLET_WIDTH) &&
                        (y >= bullet_y) && (y < bullet_y + BULLET_HEIGHT);

    // Bullet color assignment (currently set to black)
    assign bullet_r = 8'h00;
    assign bullet_g = 8'h00;
    assign bullet_b = 8'h00;

    // Collision detection logic with player character
    assign bullet_hit = active &&
                        (bullet_x + BULLET_WIDTH >= char_x) &&
                        (bullet_x <= char_x + 10) && // Player character assumed width ~10
                        (bullet_y + BULLET_HEIGHT >= char_y) &&
                        (bullet_y <= char_y + 10);   // Player character assumed height ~10

endmodule // boss_bullet