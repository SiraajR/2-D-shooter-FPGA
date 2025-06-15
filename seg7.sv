/* Extended 7-segment display driver
 * Supports digits 0-F and letters for WIN/LOSE/GAMEOVER
 * Active-low LEDs (0 = on)
 */

module seg7 (
    input  logic [4:0] hex,  // increased bit width to support more letters
    output logic [6:0] leds
);

    always_comb begin
        case (hex)
            //         6543210
            5'h0:  leds = 7'b1000000; // 0
            5'h1:  leds = 7'b1111001; // 1
            5'h2:  leds = 7'b0100100; // 2
            5'h3:  leds = 7'b0110000; // 3
            5'h4:  leds = 7'b0011001; // 4
            5'h5:  leds = 7'b0010010; // 5
            5'h6:  leds = 7'b0000010; // 6
            5'h7:  leds = 7'b1111000; // 7
            5'h8:  leds = 7'b0000000; // 8
            5'h9:  leds = 7'b0010000; // 9
            5'hA:  leds = 7'b0001000; // A
            5'hB:  leds = 7'b0000011; // b
            5'hC:  leds = 7'b1000110; // C
            5'hD:  leds = 7'b0100001; // d
            5'hE:  leds = 7'b0000110; // E
            5'hF:  leds = 7'b0001110; // F
            5'h10: leds = 7'b0001111; // G
            5'h11: leds = 7'b0011000; // H
            5'h12: leds = 7'b1111001; // I (same as 1)
            5'h13: leds = 7'b1000111; // L
            5'h14: leds = 7'b0001001; // M (approximation)
            5'h15: leds = 7'b1001000; // N (approximation)
            5'h16: leds = 7'b1000000; // O (same as 0)
            5'h17: leds = 7'b0001100; // P
            5'h18: leds = 7'b0001001; // Q (approximation)
            5'h19: leds = 7'b0000101; // R (approximation)
            5'h1A: leds = 7'b0010010; // S (same as 5)
            5'h1B: leds = 7'b0000111; // T
            5'h1C: leds = 7'b1000001; // U
            5'h1D: leds = 7'b1110001; // V
            5'h1E: leds = 7'b1111111; // (blank/off)
            5'h1F: leds = 7'b0000001; // dash/-
            default: leds = 7'b1111111; // blank
        endcase
    end

endmodule
