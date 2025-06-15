
`timescale 1 ps / 1 ps

// final_boss Module
// Manages final boss behavior including movement, health management, collision detection, and rendering.
module final_boss (
    input logic clk,                     // Clock signal
    input logic reset,                   // Reset signal
    input logic [9:0] x,                 // Current VGA pixel X-coordinate
    input logic [8:0] y,                 // Current VGA pixel Y-coordinate
    input logic boss_active,             // Activates the boss when true
    input logic bullet_hit,              // Indicates a bullet hit on the boss

    output logic boss_pix,               // Pixel belongs to boss sprite
    output logic [7:0] boss_r,           // Boss red color output
    output logic [7:0] boss_g,           // Boss green color output
    output logic [7:0] boss_b,           // Boss blue color output
    output logic [9:0] boss_x,           // Boss current X-coordinate
    output logic [8:0] boss_y,           // Boss current Y-coordinate
    output logic boss_dead               // Indicates boss defeat
);

    localparam BOSS_WIDTH = 32;          // Boss sprite width
    localparam BOSS_HEIGHT = 32;         // Boss sprite height

    logic [1:0] hp;                      // Boss health points
    logic [8:0] dir;                     // Boss movement direction

    logic prev_hit;

    // Edge detection for bullet hit
    always_ff @(posedge clk or posedge reset) begin
        if (reset) prev_hit <= 0;
        else prev_hit <= bullet_hit;
    end

    logic hit_edge;
    assign hit_edge = bullet_hit && !prev_hit;

    // Boss movement and health management
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            boss_x <= 150;
            boss_y <= 100;
            dir <= 0;
            hp <= 3;
            boss_dead <= 0;
        end else if (boss_active && !boss_dead) begin
            // Vertical movement logic
            if (dir == 0) begin
                if (boss_y < 150)
                    boss_y <= boss_y + 1;
                else
                    dir <= 1;
            end else begin
                if (boss_y > 50)
                    boss_y <= boss_y - 1;
                else
                    dir <= 0;
            end

            // Reduce boss health upon bullet hit
            if (hit_edge && hp > 0)
                hp <= hp - 1;

            if (hp == 1 && hit_edge)
                boss_dead <= 1;
        end
    end

    logic [9:0] sprite_addr;

    assign sprite_addr = (y - boss_y) * BOSS_WIDTH + (x - boss_x);

    // Determine if current pixel belongs to boss sprite
    assign boss_pix = boss_active && !boss_dead &&
                      x >= boss_x && x < boss_x + BOSS_WIDTH &&
                      y >= boss_y && y < boss_y + BOSS_HEIGHT &&
                      sprite_pixel != 24'hFFFFFF;

    logic [23:0] sprite_pixel;

    // ROM storing boss sprite data
    boss_sprite sprite1 (
        .clock(clk),
        .address(sprite_addr),
        .q(sprite_pixel)
    );

    // Assign sprite colors, transparency handling
    assign {boss_r, boss_g, boss_b} = sprite_pixel != 24'hFFFFFF ? sprite_pixel : 24'h000000;

endmodule // final_boss

