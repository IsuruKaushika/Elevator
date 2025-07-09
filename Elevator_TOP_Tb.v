`timescale 1ns / 1ps
`include "elevator_fsm_top.v"

module elevator_fsm_top_tb;

    parameter NUM_FLOORS = 10;
    parameter FLOOR_WIDTH = 4;

    reg clk;
    reg reset;
    reg emergency_stop;
    reg overweight;
    reg door_obstruction;
    reg [NUM_FLOORS-1:0] new_requests;
    reg [NUM_FLOORS-1:0] floor_sensors;

    wire [NUM_FLOORS-1:0] floor_requests;
    wire [FLOOR_WIDTH-1:0] current_floor;
    wire moving_up;
    wire moving_down;
    wire door_open;
    wire pwm_out;

    // Instantiate the elevator top module
    elevator_fsm_top #(
        .NUM_FLOORS(NUM_FLOORS),
        .FLOOR_WIDTH(FLOOR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .emergency_stop(emergency_stop),
        .overweight(overweight),
        .door_obstruction(door_obstruction),
        .new_requests(new_requests),
        .floor_sensors(floor_sensors),
        .floor_requests(floor_requests),
        .current_floor(current_floor),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .door_open(door_open),
        .pwm_out(pwm_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // VCD for GTKWave
    initial begin
        $dumpfile("elevator_fsm_top.vcd");
        $dumpvars(0, elevator_fsm_top_tb);
    end

    // Helper task to print a header
    task print_header;
        begin
            $display("\n---------------------------------------------------------------------------------------------------------------");
            $display("Time(ns) | Reset | EmStop | Overwt | DoorObs | CurrFloor | FloorReqs      | MovingUp | MovingDn | DoorOpen | ClearReq | PWM_Duty | PWM_Out");
            $display("---------------------------------------------------------------------------------------------------------------");
        end
    endtask

    // Helper task to simulate elevator at a given floor
    task set_floor(input [FLOOR_WIDTH-1:0] floor);
        begin
            floor_sensors = 0;
            floor_sensors[floor] = 1;
        end
    endtask

    // Signal change detection for clean printing
    reg [NUM_FLOORS-1:0] prev_floor_requests;
    reg [FLOOR_WIDTH-1:0] prev_floor;
    reg prev_moving_up, prev_moving_down, prev_door_open;
    reg prev_pwm_out;

    always @(posedge clk) begin
        if (reset || 
            prev_floor != current_floor || 
            prev_floor_requests != floor_requests || 
            prev_moving_up != moving_up || 
            prev_moving_down != moving_down || 
            prev_door_open != door_open || 
            prev_pwm_out != pwm_out) begin

            print_header();
            $display("%8d |   %b   |   %b    |   %b    |    %b    |    %2d     | %b |    %b    |    %b    |    %b    |    %b     |   %3d    |   %b",
                $time, reset, emergency_stop, overweight, door_obstruction,
                current_floor, floor_requests, moving_up, moving_down, door_open,
                dut.controller.clear_current_request, dut.controller.pwm_duty, pwm_out);
        end

        prev_floor = current_floor;
        prev_floor_requests = floor_requests;
        prev_moving_up = moving_up;
        prev_moving_down = moving_down;
        prev_door_open = door_open;
        prev_pwm_out = pwm_out;
    end

    initial begin
        $display("\n--- Simulation started ---");

        // === Initialization ===
        reset = 1;
        emergency_stop = 0;
        overweight = 0;
        door_obstruction = 0;
        new_requests = 0;
        floor_sensors = 0;

        #50;
        reset = 0;
        #50;

        set_floor(0); // Start at floor 0
        #200;

        // === Scenario 1 ===
        $display("\n>>> Scenario 1: Requests at floors 3, 5, 9");
        #100; new_requests[3] = 1; #100;
        new_requests[5] = 1; #100;
        new_requests[9] = 1; #100;
        new_requests = 0; #200;

        #200; set_floor(1); #200;
        #200; set_floor(2); #200;
        #200; set_floor(3); #800;

        #300; set_floor(4); #300;
        #300; set_floor(5); #800;

        #300; set_floor(6); #300;
        #300; set_floor(7); #300;
        #300; set_floor(8); #300;
        #300; set_floor(9); #800;

        // === Scenario 2 ===
        $display("\n>>> Scenario 2: Door Obstruction");
        door_obstruction = 1; #600;
        door_obstruction = 0; #400;

        // === Scenario 3 ===
        $display("\n>>> Scenario 3: Overweight Condition");
        overweight = 1; #600;
        overweight = 0; #400;

        // === Scenario 4 ===
        $display("\n>>> Scenario 4: Emergency Stop");
        emergency_stop = 1; #600;
        emergency_stop = 0; #400;

        // === Scenario 5 ===
        $display("\n>>> Scenario 5: Requests at floors 1 and 4");
        #200; new_requests[1] = 1; #200;
        new_requests[4] = 1; #100; new_requests = 0;

        #400; set_floor(8); #300;
        #300; set_floor(7); #300;
        #300; set_floor(6); #300;
        #300; set_floor(5); #300;
        #300; set_floor(4); #800;
        #300; set_floor(3); #300;
        #300; set_floor(2); #300;
        #300; set_floor(1); #800;

        $display("\n--- Simulation finished ---");
        $finish;
    end

endmodule
