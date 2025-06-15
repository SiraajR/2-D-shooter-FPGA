`timescale 1 ps / 1 ps


// boss_hit_counter Module
// Counts the number of hits the boss receives from the player's bullets. Utilizes edge detection to avoid multiple increments per bullet hit.
module boss_hit_counter (
    input logic clk,                 // Clock signal
    input logic reset,               // Reset signal
    input logic bullet_hit,          // Input signal indicating bullet collision with boss
    output logic [3:0] count         // Number of hits received
);

    logic prev_hit;                  // Stores previous bullet_hit state to detect edges

    // Edge detection logic to increment hit counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;              // Reset hit count to 0
            prev_hit <= 0;           // Reset previous hit state
        end else begin
            prev_hit <= bullet_hit;  // Update previous state

            // Increment counter only on rising edge of bullet_hit
            if (bullet_hit && !prev_hit)
                count <= count + 1;
        end
    end

endmodule // boss_hit_counter