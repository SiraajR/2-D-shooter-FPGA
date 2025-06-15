`timescale 1 ps / 1 ps

// character_rend Module
// Renders character sprite based on VGA pixel coordinates, fetching pixel data from ROM.
module character_rend (
    input logic [9:0] x,               // Current VGA pixel X-coordinate
    input logic [8:0] y,               // Current VGA pixel Y-coordinate
    input logic [9:0] char_x,          // Character position X-coordinate
    input logic [8:0] char_y,          // Character position Y-coordinate
    input logic clk,                   // Clock signal
    output logic char_pix,             // Indicates pixel is part of character sprite
    output logic [7:0] char_r,         // Character red color output
    output logic [7:0] char_g,         // Character green color output
    output logic [7:0] char_b          // Character blue color output
);

    // Internal signals for sprite handling
    logic [3:0] sprite_x, sprite_y;
    logic [7:0] rom_r, rom_g, rom_b;
    logic [23:0] sprite_data;
    logic [7:0] sprite_addr;

    // Calculate sprite pixel coordinates and fetch sprite data address
    assign sprite_x = x - char_x;
    assign sprite_y = y - char_y;
    assign sprite_addr = sprite_y * 16 + sprite_x;

    // ROM instance storing character sprite data
    char rom (
        .address(sprite_addr),
        .clock(clk),  
        .q(sprite_data)
    );

    // Extract sprite RGB color data
    assign rom_r = sprite_data[23:16];
    assign rom_g = sprite_data[15:8];
    assign rom_b = sprite_data[7:0];

    // Character sprite rendering logic
    always_comb begin
        if (x >= char_x && x < char_x + 16 &&
            y >= char_y && y < char_y + 16 && sprite_data != 24'hFFFFFF) begin
            
            char_pix = 1;
            char_r = rom_r;
            char_g = rom_g;
            char_b = rom_b;
            
        end else begin
            char_pix = 0;
            char_r = 0;
            char_g = 0;
            char_b = 0;
        end
    end

endmodule // character_rend
