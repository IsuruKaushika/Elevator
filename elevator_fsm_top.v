`include "DirectionChecker.v"
`include "FloorPositionDetector.v"
`include "requestHandler.v"
`include "FSM_Controller.v"
`include "PwmGenerator.v"
//========================================
//Kaushika M.K.I -EG/2021/4606            
//Sivanujan S - EG/2021/4816
//Senevirathne S.M.K.H.T - EG/2021/4806
//========================================

module elevator_fsm_top #(
    parameter NUM_FLOORS = 10,
    parameter FLOOR_WIDTH = 4
)(
    input clk,
    input reset,
    input emergency_stop,
    input overweight,
    input door_obstruction,
    input [NUM_FLOORS-1:0] new_requests,
    input [NUM_FLOORS-1:0] floor_sensors,

    output [NUM_FLOORS-1:0] floor_requests,
    output [FLOOR_WIDTH-1:0] current_floor,
    output moving_up,
    output moving_down,
    output door_open,
    output pwm_out
);

    wire [NUM_FLOORS-1:0] reqs;
    wire [FLOOR_WIDTH-1:0] floor;
    wire has_above, has_below;
    wire clear_request;
    wire [7:0] pwm_duty;

    assign floor_requests = reqs;
    assign current_floor = floor;

    floor_position_detector #(.NUM_FLOORS(NUM_FLOORS), .FLOOR_WIDTH(FLOOR_WIDTH)) detector (
        .floor_sensors(floor_sensors),
        .current_floor(floor)
    );

    request_handler #(.NUM_FLOORS(NUM_FLOORS), .FLOOR_WIDTH(FLOOR_WIDTH)) handler (
        .clk(clk),
        .reset(reset),
        .new_requests(new_requests),
        .current_floor(floor),
        .clear_current_request(clear_request),
        .floor_requests(reqs)
    );

    direction_checker #(.NUM_FLOORS(NUM_FLOORS), .FLOOR_WIDTH(FLOOR_WIDTH)) checker (
        .current_floor(floor),
        .floor_requests(reqs),
        .has_request_above(has_above),
        .has_request_below(has_below)
    );

    fsm_controller #(.NUM_FLOORS(NUM_FLOORS), .FLOOR_WIDTH(FLOOR_WIDTH)) controller (
        .clk(clk),
        .reset(reset),
        .emergency_stop(emergency_stop),
        .overweight(overweight),
        .door_obstruction(door_obstruction),
        .current_floor(floor),
        .floor_requests(reqs),
        .has_request_above(has_above),
        .has_request_below(has_below),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .door_open(door_open),
        .clear_current_request(clear_request),
        .pwm_duty(pwm_duty)
    );

    pwm_generator pwm_unit (
        .clk(clk),
        .reset(reset),
        .duty_cycle(pwm_duty),
        .pwm_out(pwm_out)
    );

endmodule