
`timescale 1 ps / 1 ps

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	logic char_pix; 
	logic [7:0] char_r , char_g , char_b;
	logic [9:0] char_x;
	logic [8:0] char_y;
	logic [9:0] next_x_bullet;
    logic [8:0] next_y_bullet;
    logic game_over;
    logic boss_bullet_hit_player;
    assign reset = SW[5];
	video_driver #(.WIDTH(200), .HEIGHT(300))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	logic [7:0] curr_r , curr_g , curr_b;
	logic blocked;
	logic bullet_fired, bullet_active;
    logic [7:0] bullet_r, bullet_g, bullet_b;
    logic bull_ghoul;
	//map1 m1 (.x , .y , .r(curr_r) , .g(curr_g), .b(curr_b));
	//playerMovement move (.left(SW[0]) , .right(SW[1]) , .up(SW[2]) , .down(SW[3]) , .x(char_x) , .y(char_y) , .dx(next_x) , .dy(next_y));
	character_rend bocs (.x , .y ,.char_x(char_x) , .char_y(char_y) , .char_pix(char_pix) , .char_r(char_r) , .char_g(char_g) , .char_b(char_b) , .clk(CLOCK_50));
	//localparam logic [23:0] GREY_BLOCK = 24'hb7b7b7;
	logic [31:0] divided_clk;
      clock_divider getCLK (
        .clock(CLOCK_50),
        .reset(reset),
        .divided_clock(divided_clk)
      );
  assign slow_clk = divided_clk[20];
  assign slower = divided_clk[24];
  assign slowest = divided_clk[30];
  logic prev_left, prev_right, prev_up, prev_down;
  logic left_edge, right_edge, up_edge, down_edge;
  logic [9:0] ghoul_x;
  logic [8:0] ghoul_y;
  logic ghoul_pix;
  logic [7:0] ghoul_r, ghoul_g, ghoul_b;

  bullet bull(.clk(slow_clk) , .reset(reset) , .fire(~KEY[3]) , .char_x(char_x) , .char_y(char_y) , .x(x) , .y(y) , .bullet_fired(bullet_fired) , .bullet_r(bullet_r) , .bullet_g(bullet_g) , .bullet_b(bullet_b) , .active(bullet_active) , .bull_x(next_x_bullet) , .bull_y(next_y_bullet));
  ghoul gh (
    .clk(CLOCK_50),
    .slow_clk(slow_clk),
    .reset(reset),
    .bullet_x(next_x_bullet),
    .bullet_y(next_y_bullet),
    .bullet_active(bullet_fired),
    .x(x),
    .y(y),
    .ghoul_pix(ghoul_pix),
    .ghoul_r(ghoul_r),
    .ghoul_g(ghoul_g),
    .ghoul_b(ghoul_b) , 
    .bull_ghoul(bull_ghoul)
    );
    logic [15:0] map_addr;
    //logic map_select;
    logic map_select;
    logic [23:0] map_data;
    assign map_addr = y * 200 + x;
    //assign map_select = 0;
    map_selector(.clock(CLOCK_50) , .address(map_addr) , .q(map_data) , .selector(map_select));
    logic pressed;
    assign curr_r = map_data[23:16];
    assign curr_g = map_data[15:8];
    assign curr_b = map_data[7:0];

    
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            prev_left <= 0;
            prev_right <= 0;
            prev_up <= 0;
            prev_down <= 0;
        end else begin
         //   down_edge_fast <= (~KEY[3] & ~prev_down);
            prev_left <= ~KEY[1];
            prev_right <= ~KEY[0];
            prev_up <= ~KEY[2];
            //prev_down <= ~KEY[3];
        end
    end
    
    assign left_edge = ~KEY[1] && ~prev_left;
    assign right_edge = ~KEY[0] && ~prev_right;
    assign up_edge = ~KEY[2] && ~prev_up;
   
    logic left_latch, right_latch, up_latch;
    assign pressed = (prev_left | prev_right | prev_up);
    // At slow clock, capture the latched edges
    logic [7:0] gravity_counter;
    logic gravity_tick;
    
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            gravity_counter <= 0;
            gravity_tick <= 0;
        end else if (pressed) begin
            gravity_counter <= 0;
            gravity_tick <= 0;
        end else if (game_over) begin 
            gravity_counter <= 0;
            gravity_tick <= 0;
        end else if (gravity_counter == 20) begin // gravity tick every ~0.4s
            gravity_counter <= 0;
            gravity_tick <= 1;
        end else begin
            gravity_counter <= gravity_counter + 1;
            gravity_tick <= 0;
        end
    end

    always_ff @(posedge slow_clk) begin
        if( reset | pressed) begin 
            down_edge <= 0;
        end else begin 
            down_edge <= 1;
        end
    end
    logic checker;
    assign checker = SW[3];
    
    // Movement logic — only update position on switch edge
    always_ff @(posedge slow_clk or posedge reset) begin 
        if (reset) begin 
            char_x <= 20;
            char_y <= 20;
            map_select <= 0;
        end 
        else if (game_over) begin 
            char_x <= char_x;
            char_y <= char_y;
            map_select <= map_select;
        end
        else if (checker) begin
            if (left_edge && char_x >= 10)
                char_x <= char_x - 15;
            else if (right_edge && char_x <= 199)
                char_x <= char_x + 15;
    
            else if (up_edge && char_y >= 10)
                char_y <= char_y - 20;
            else if (gravity_tick) //if (down_edge && char_y <= 299)
                char_y <= char_y + 15;
            if (right_edge && char_x >= 199) begin
                char_x <= 0;
                map_select <= 1;
            end
            
        end else begin 
            char_x <= char_x;
            char_y <= char_y ;
        
        end
    end
	logic boss_pix;
	logic [7:0] boss_r , boss_g , boss_b;
	logic [9:0] boss_x;
	logic [8:0] boss_y;
	logic boss_bullet_pix;
    logic [7:0] boss_bullet_r, boss_bullet_g, boss_bullet_b;
    logic boss_bullet_hit;
    logic [31:0] fire_counter;
    logic boss_fire;
    logic boss_dead;
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            fire_counter <= 0;
            boss_fire <= 0;
        end else if (game_over) begin 
            fire_counter <= 0;
            boss_fire <= 0;
        end else if (map_select == 1) begin
            fire_counter <= fire_counter + 1;
            if (fire_counter == 10) begin // Adjust firing rate here
                boss_fire <= 1;
                fire_counter <= 0;
            end else begin
                boss_fire <= 0;
            end
        end
    end
    logic player_bullet_hits_boss;
    assign player_bullet_hits_boss = bullet_active &&
                                     (next_x_bullet + 4 >= boss_x) &&
                                     (next_x_bullet <= boss_x + 20) &&
                                     (next_y_bullet + 4 >= boss_y) &&
                                     (next_y_bullet <= boss_y + 20);
                                     
    logic prev_hit;
    logic bullet_hit_pulse;
    
    always_ff @(posedge CLOCK_50 or posedge reset) begin
        if (reset)
            prev_hit <= 0;
        else
            prev_hit <= player_bullet_hits_boss;
    end
    
    assign bullet_hit_pulse = player_bullet_hits_boss && !prev_hit;
    
    // Hit counter output
    logic [4:0] boss_hit_count;
    logic [6:0] seg_leds;
    
    //assign HEX0 = seg_leds;  // active-low 7-seg display
    
    // Counter module
    boss_hit_counter bhc (
        .clk(CLOCK_50),
        .reset(reset),
        .bullet_hit(bullet_hit_pulse),
        .count(boss_hit_count)
    );
    
    // 7-segment display driver
    seg7 h2 (.hex((boss_dead && !game_over) ? 5'h17 : 5'h1E), .leds(HEX2)); // W
    seg7 h1 (.hex((boss_dead && !game_over) ? 5'h12 : 5'h1E), .leds(HEX1)); // I
    seg7 h0 (.hex((boss_dead && !game_over) ? 5'h15 : 5'h1E), .leds(HEX0)); // N

    
    seg7 h5 (.hex(game_over ? 5'h13 : boss_hit_count), .leds(HEX5)); // L
    seg7 h4 (.hex(game_over ? 5'h16 : 5'h1E), .leds(HEX4)); // O
    seg7 h3 (.hex(game_over ? 5'h1A : 5'h1E), .leds(HEX3)); // S
    //seg7 h2x(.hex(game_over ? 5'h0E : 5'h1E), .leds(HEX2)); // E


    final_boss fb (
        .clk(slow_clk),
        .reset(reset),
        .x(x),
        .y(y),
        .boss_active(map_select),
        .bullet_hit(player_bullet_hits_boss),
        .boss_pix(boss_pix),
        .boss_r(boss_r),
        .boss_g(boss_g),
        .boss_b(boss_b),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_dead(boss_dead)
    );
	boss_bullet bb (
    .clk(slow_clk),
    .reset(reset),
    .fire(boss_fire),
    .start_x(boss_x),
    .start_y(boss_y + 20),  // Center of boss
    .x(x),
    .y(y),
    .char_x(char_x),
    .char_y(char_y),
    .bullet_pix(boss_bullet_pix),
    .bullet_r(boss_bullet_r),
    .bullet_g(boss_bullet_g),
    .bullet_b(boss_bullet_b),
    .bullet_hit(boss_bullet_hit)
    );
    
    

	always_ff @(posedge CLOCK_50) begin 
	    if (char_pix) begin 
	        r <= char_r;
	        g <= char_g;
	        b <= char_b;
	   end else if (ghoul_pix  & ~map_select & !bull_ghoul ) begin 
	        r <= ghoul_r;
	        g <= ghoul_g;
	        b <= ghoul_b;
	   end else if (bullet_fired) begin 
	        r <= bullet_r;
	        g <= bullet_g;
	        b <= bullet_b;
	    end else if (boss_pix) begin
	        r <= boss_r;
	        g <= boss_g;
	        b <= boss_b;
	    end else if (boss_bullet_pix & map_select == 1) begin
            r <= boss_bullet_r;
            g <= boss_bullet_g;
            b <= boss_bullet_b;
        end else begin 
		    r <= curr_r; 
		    g <= curr_g; 
		    b <= curr_b;
		 end
	end

    
    logic prev_boss_bullet_hit;

    always_ff @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            game_over <= 0;
            prev_boss_bullet_hit <= 0;
        end else if (SW[7] & SW[2]) begin 
            game_over <= 0;
            prev_boss_bullet_hit <= 0;
        end else begin
            prev_boss_bullet_hit <= boss_bullet_hit;
            if ((!prev_boss_bullet_hit && boss_bullet_hit) | char_y >= 250)
                game_over <= 1;
        end
    end
endmodule  // DE1_SoC




`timescale 1 ps / 1 ps
module DE1_SoC_testbench ();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR, SW;
	logic [3:0] KEY;
	logic CLOCK_50;
	logic [7:0] VGA_R, VGA_G, VGA_B;
	logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	
	// instantiate module
	DE1_SoC dut (.*);
	
	// create simulated clock
	parameter T = 20;
	initial begin
		CLOCK_50 <= 0;
		forever #(T/2) CLOCK_50 <= ~CLOCK_50;
	end  // clock initial
	
	// simulated inputs
	initial begin
		
		$stop();
	end  // inputs initial
	
endmodule  // DE1_SoC_testbench

module clock_divider(clock, reset, divided_clock);

    input logic clock, reset;
    output logic [31:0] divided_clock;

    // Initialize counter
    initial divided_clock = 32'd0;

    // Increment the divided_clock on every clock cycle, reset if reset signal is asserted
    always_ff @(posedge clock) begin
        if (reset) begin
            divided_clock <= 32'd0; // reset counter
        end else begin
            divided_clock <= divided_clock + 32'd1; // increment counter
        end
    end  // always_ff

endmodule  // clock_divider






