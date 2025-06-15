`timescale 1 ps / 1 ps

// ghoul Module
// Manages enemy (ghoul) behavior including initialization, movement, health management, bullet collision detection, and rendering.
module ghoul #(
    parameter NUM_GHOULS = 3,           // Number of ghouls
    parameter GHOUL_WIDTH = 16,         // Width of each ghoul
    parameter GHOUL_HEIGHT = 16         // Height of each ghoul
)(
    input logic clk,                    // Fast clock signal for collision and health checks
    input logic slow_clk,               // Slow clock signal for movement
    input logic reset,                  // Reset signal
    input logic [9:0] bullet_x,         // Bullet X-coordinate
    input logic [8:0] bullet_y,         // Bullet Y-coordinate
    input logic bullet_active,          // Bullet active state
    input logic [9:0] x,                // Current VGA pixel X-coordinate
    input logic [8:0] y,                // Current VGA pixel Y-coordinate
    output logic ghoul_pix,             // Pixel belongs to a ghoul sprite
    output logic [7:0] ghoul_r,         // Ghoul red color output
    output logic [7:0] ghoul_g,         // Ghoul green color output
    output logic [7:0] ghoul_b,         // Ghoul blue color output
    output logic bull_ghoul             // Bullet collision detection flag
);

    logic [9:0] ghoul_x [NUM_GHOULS-1:0];          // Ghouls' X-coordinates
    logic [8:0] ghoul_y [NUM_GHOULS-1:0];          // Ghouls' Y-coordinates
    logic [1:0] ghoul_health [NUM_GHOULS-1:0];     // Health of each ghoul
    logic ghoul_active [NUM_GHOULS-1:0];           // Active status for each ghoul

    integer i;

    // Health initialization and bullet collision detection
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NUM_GHOULS; i++) begin
                ghoul_health[i] <= 3;
                ghoul_active[i] <= 1;
            end
        end else begin 
            for (i = 0; i < NUM_GHOULS; i++) begin
                if (ghoul_active[i]) begin
                    // Check collision with bullet
                    if (bullet_active &&
                        bullet_x >= ghoul_x[i] && bullet_x <= ghoul_x[i] + GHOUL_WIDTH &&
                        bullet_y >= ghoul_y[i] && bullet_y <= ghoul_y[i] + GHOUL_HEIGHT) begin
                        if (ghoul_health[i] > 1)
                            ghoul_health[i] <= ghoul_health[i] - 1;
                        else
                            ghoul_active[i] <= 0;
                        bull_ghoul <= 0;
                    end else begin 
                        bull_ghoul <= bullet_active;
                    end
                end
            end
        end
    end

    // Ghoul movement logic
    always_ff @(posedge slow_clk) begin 
        if (reset) begin
            for (i = 0; i < NUM_GHOULS; i++) begin
                ghoul_x[i] <= 100 + i * 100;
                ghoul_y[i] <= 150;
            end
        end else begin
            for (i = 0; i < NUM_GHOULS; i++) begin
                if (ghoul_active[i]) begin
                    ghoul_x[i] <= ghoul_x[i] + 1;
                    if (ghoul_x[i] > 150) ghoul_x[i] <= 50;

                    ghoul_y[i] <= ghoul_y[i] + 1;
                    if (ghoul_y[i] > 200) ghoul_y[i] <= 100;
                end
            end
        end
    end

    // Ghoul rendering logic
    always_comb begin
        ghoul_pix = 0;
        ghoul_r = 0;
        ghoul_g = 0;
        ghoul_b = 0;

        for (i = 0; i < NUM_GHOULS; i++) begin
            if (ghoul_active[i] && x >= ghoul_x[i] && x <= ghoul_x[i] + GHOUL_WIDTH &&
                y >= ghoul_y[i] && y <= ghoul_y[i] + GHOUL_HEIGHT) begin
                ghoul_pix = 1;
                ghoul_r = 8'h60;
                ghoul_g = 8'hA0;
                ghoul_b = 8'h60;
            end
        end
    end

endmodule // ghoul
