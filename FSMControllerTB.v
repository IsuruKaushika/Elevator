`timescale 1ns / 1ps
`include "FSM_Controller.v"

module fsm_controller_tb;

    parameter NUM_FLOORS = 10;
    parameter FLOOR_WIDTH = 4;

    // Inputs
    reg clk, reset, emergency_stop, overweight, door_obstruction;
    reg [FLOOR_WIDTH-1:0] current_floor;
    reg [NUM_FLOORS-1:0] floor_requests;
    reg has_request_above, has_request_below;

    // Outputs
    wire moving_up, moving_down, door_open, clear_current_request;
    wire [7:0] pwm_duty;

    // Instantiate DUT
    fsm_controller #(
        .NUM_FLOORS(NUM_FLOORS),
        .FLOOR_WIDTH(FLOOR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .emergency_stop(emergency_stop),
        .overweight(overweight),
        .door_obstruction(door_obstruction),
        .current_floor(current_floor),
        .floor_requests(floor_requests),
        .has_request_above(has_request_above),
        .has_request_below(has_request_below),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .door_open(door_open),
        .clear_current_request(clear_current_request),
        .pwm_duty(pwm_duty)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period (100MHz)

    // Monitor signals
    initial begin
        $display("Time\tFloor\tRequests\tUp\tDown\tDoor\tClear\tPWM");
        $monitor("%0t\t%d\t%b\t%b\t%b\t%b\t%b\t%d", $time, current_floor, floor_requests,
                 moving_up, moving_down, door_open, clear_current_request, pwm_duty);
    end

    // GTKWave setup
    initial begin
        $dumpfile("fsm_controller.vcd");
        $dumpvars(0, fsm_controller_tb);
    end

    // Stimulus
    initial begin
        // Initialize
        reset = 1;
        emergency_stop = 0;
        overweight = 0;
        door_obstruction = 0;
        current_floor = 0;
        floor_requests = 0;
        has_request_above = 0;
        has_request_below = 0;

        #20 reset = 0;

        // === Test 1: Normal up movement to floor 3 ===
        floor_requests[3] = 1;
        has_request_above = 1;
        #100 current_floor = 1;
        #100 current_floor = 2;
        #100 current_floor = 3;

        // Wait for door to open/close
        #600;

        // === Test 2: Normal down movement to floor 1 ===
        floor_requests = 0;
        floor_requests[1] = 1;
        has_request_above = 0;
        has_request_below = 1;
        #100 current_floor = 2;
        #100 current_floor = 1;
        #600;

        // === Test 3: Door obstruction at floor 1 ===
        floor_requests = 0;
        floor_requests[1] = 1;
        #20 current_floor = 1;
        #20 door_obstruction = 1;
        #100 door_obstruction = 0;
        #600;

        // === Test 4: Overweight condition at floor 5 ===
        floor_requests = 0;
        floor_requests[5] = 1;
        has_request_above = 1;
        has_request_below = 0;
        #100 current_floor = 3;
        #100 current_floor = 4;
        #100 current_floor = 5;
        #10 overweight = 1;
        #200 overweight = 0;
        #400;

        // === Test 5: Emergency stop during travel to floor 8 ===
        floor_requests = 0;
        floor_requests[8] = 1;
        has_request_above = 1;
        #100 current_floor = 6;
        #20 emergency_stop = 1;
        #100 emergency_stop = 0;
        #100 current_floor = 7;
        #100 current_floor = 8;
        #600;

        // === Test 6: Idle state (no requests) ===
        floor_requests = 0;
        has_request_above = 0;
        has_request_below = 0;
        #200;

        $finish;
    end

endmodule
