`timescale 1ns / 1ps
`include "FloorPositionDetector.v  "

module floor_position_detector_tb;

    // Parameters
    parameter NUM_FLOORS = 10;
    parameter FLOOR_WIDTH = 4;

    // Inputs
    reg [NUM_FLOORS-1:0] floor_sensors;

    // Outputs
    wire [FLOOR_WIDTH-1:0] current_floor;

    // Instantiate the Unit Under Test (UUT)
    floor_position_detector #(
        .NUM_FLOORS(NUM_FLOORS),
        .FLOOR_WIDTH(FLOOR_WIDTH)
    ) uut (
        .floor_sensors(floor_sensors),
        .current_floor(current_floor)
    );

    // VCD dump for GTKWave
    initial begin
        $dumpfile("floor_position_detector.vcd");
        $dumpvars(0, floor_position_detector_tb);
    end

    // Test sequence
    initial begin
        $display("Time\tSensor Input\tDetected Floor");
        
        // Test each floor one by one
        floor_sensors = 10'b0000000001; // Floor 0
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0000000010; // Floor 1
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0000000100; // Floor 2
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0000001000; // Floor 3
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0000010000; // Floor 4
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0000100000; // Floor 5
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0001000000; // Floor 6
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0010000000; // Floor 7
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b0100000000; // Floor 8
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        floor_sensors = 10'b1000000000; // Floor 9
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        // Multiple sensors active (e.g., noise or glitch)
        floor_sensors = 10'b0000100100; // Floor 5 and 2 active → should detect highest (5)
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        // No sensor active (invalid case)
        floor_sensors = 10'b0000000000;
        #10 $display("%0t\t%b\t%d", $time, floor_sensors, current_floor);

        #20 $finish;
    end

endmodule
