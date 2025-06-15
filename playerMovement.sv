`timescale 1 ps / 1 ps

// playerMovement Module
// Manages player movement logic based on directional input signals, updating the player's position.
module playerMovement (
	input logic left,                 // Move player left
	input logic right,                // Move player right
	input logic up,                   // Move player up
	input logic down,                 // Move player down
	input logic [9:0] x,              // Current X-coordinate
	input logic [8:0] y,              // Current Y-coordinate
	output logic [9:0] dx,            // Updated X-coordinate
	output logic [8:0] dy             // Updated Y-coordinate
);

	logic [9:0] curr_x;
	logic [8:0] curr_y;

	assign curr_x = x; 
	assign curr_y = y;

	// Movement logic based on directional inputs and boundary checks
	always_comb begin 
		if (left && curr_x > 0) begin 
			dx = curr_x - 10;
		end else if (right && curr_x < 35) begin 
			dx = curr_x + 10;
		end else begin
			dx = x;
		end
		
		if (up && curr_y > 1) begin 
			dy = curr_y - 10;
		end else if (down && curr_y < 25) begin 
			dy = curr_y + 10;
		end else begin 
			dy = y;
		end
	end

endmodule // playerMovement
