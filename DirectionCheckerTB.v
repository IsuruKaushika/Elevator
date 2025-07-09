`timescale 1ns / 1ps
`include "DirectionChecker.v"

module direction_checker_tb;

    // Parameters
    parameter NUM_FLOORS = 10;
    parameter FLOOR_WIDTH = 4;

    // Inputs
    reg [FLOOR_WIDTH-1:0] current_floor;
    reg [NUM_FLOORS-1:0] floor_requests;

    // Outputs
    wire has_request_above;
    wire has_request_below;

    // Instantiate the Unit Under Test (UUT)
    direction_checker #(
        .NUM_FLOORS(NUM_FLOORS),
        .FLOOR_WIDTH(FLOOR_WIDTH)
    ) uut (
        .current_floor(current_floor),
        .floor_requests(floor_requests),
        .has_request_above(has_request_above),
        .has_request_below(has_request_below)
    );

    // Test sequence
    initial begin
        // VCD (GTKWave) dump
        $dumpfile("direction_checker_tb.vcd");  // Output VCD file name
        $dumpvars(0, direction_checker_tb);     // Dump all variables in this testbench

        $display("Time\tFloor\tRequests\tAbove\tBelow");

        // Test 1: No requests
        current_floor = 5;
        floor_requests = 10'b0000000000;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 2: Requests above only
        floor_requests = 10'b1110000000;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 3: Requests below only
        floor_requests = 10'b0000011100;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 4: Requests both above and below
        floor_requests = 10'b1010010100;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 5: Request at current floor only
        floor_requests = 10'b0000010000;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 6: Current floor at top
        current_floor = 9;
        floor_requests = 10'b0111111111;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        // Test 7: Current floor at bottom
        current_floor = 0;
        floor_requests = 10'b1111111110;
        #10 $display("%0t\t%d\t%b\t%b\t%b", $time, current_floor, floor_requests, has_request_above, has_request_below);

        $finish;
    end

endmodule
