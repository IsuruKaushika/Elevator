`timescale 1ns / 1ps
`include "RequestHandler.v"

module request_handler_tb;

    parameter NUM_FLOORS = 10;
    parameter FLOOR_WIDTH = 4;

    reg clk, reset;
    reg [NUM_FLOORS-1:0] new_requests;
    reg [FLOOR_WIDTH-1:0] current_floor;
    reg clear_current_request;

    wire [NUM_FLOORS-1:0] floor_requests;

    // Instantiate DUT
    request_handler #(
        .NUM_FLOORS(NUM_FLOORS),
        .FLOOR_WIDTH(FLOOR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .new_requests(new_requests),
        .current_floor(current_floor),
        .clear_current_request(clear_current_request),
        .floor_requests(floor_requests)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor output
    initial begin
        $display("Time\tReset\tNewReq\tCurrentFloor\tClear\tFloorRequests");
        $monitor("%0t\t%b\t%b\t%d\t\t%b\t%b", 
                 $time, reset, new_requests, current_floor, clear_current_request, floor_requests);
    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("request_handler.vcd");
        $dumpvars(0, request_handler_tb);
    end

    initial begin
    // Initialize signals
    reset = 1; new_requests = 0; current_floor = 0; clear_current_request = 0;
    #20 reset = 0;

    // Starting floor = 1
    current_floor = 1;

    // Requests at floors 2,4,5,9
    new_requests = 10'b1001100100; 
    // Binary bit indices: floor9=1, floor5=1, floor4=1, floor2=1
    // (bits counted from 0 = floor0 to 9 = floor9)
    #10 new_requests = 0; // Clear new_requests after latching

    // Check requests remain
    #20;

    // Move elevator through floors 2,4,5 (simulate but no clear)
    current_floor = 2;
    #50 current_floor = 4;
    #50 current_floor = 5;

    // Floor 9 reached - clear floor 9 request
    #50 current_floor = 9;
    clear_current_request = 1;
    #10 clear_current_request = 0;

    // Check remaining requests still set at 2,4,5
    #50;

    $finish;
end

endmodule
