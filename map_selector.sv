`timescale 1 ps / 1 ps

// map_selector Module
// Selects and outputs map data from two different ROM modules based on a selector input.
module map_selector (
    input logic clock,                 // Clock signal
    input logic [15:0] address,        // Address input to ROM modules
    output logic [23:0] q,             // Output pixel data
    input logic selector               // Selector to choose between ROM modules
);

    logic [23:0] m1_data, m3_data;     // Data from map ROM modules

    // ROM module instances
    some_rom m1 (
        .clock(clock),
        .address(address),
        .q(m1_data)
    );

    some_rom_m3 m3 (
        .clock(clock),
        .address(address),
        .q(m3_data)
    );

    // Output logic based on selector input
    assign q = (selector) ? m3_data : m1_data;

endmodule // map_selector
