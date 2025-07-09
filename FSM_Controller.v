// === fsm_controller.v ===
module fsm_controller #(
    parameter NUM_FLOORS = 10,
    parameter FLOOR_WIDTH = 4
)(
    input clk,
    input reset,
    input emergency_stop,
    input overweight,
    input door_obstruction,
    input [FLOOR_WIDTH-1:0] current_floor,
    input [NUM_FLOORS-1:0] floor_requests,
    input has_request_above,
    input has_request_below,

    output reg moving_up,
    output reg moving_down,
    output reg door_open,
    output reg clear_current_request,
    output reg [7:0] pwm_duty
);

    reg [3:0] state, next_state;
    reg [7:0] timer;

    localparam [3:0]
        IDLE            = 4'd0,
        CHECK_REQUEST   = 4'd1,
        MOVE_UP         = 4'd2,
        MOVE_DOWN       = 4'd3,
        OPEN_DOOR       = 4'd4,
        DOOR_WAIT       = 4'd5,
        CLOSE_DOOR      = 4'd6,
        EMERGENCY_STOP  = 4'd7,
        WAIT_FOR_WEIGHT = 4'd8;

    localparam DOOR_OPEN_TIME = 8'd50; 

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            timer <= 0;
        else if (state == DOOR_WAIT)
            timer <= timer + 1;
        else
            timer <= 0;
    end

  
    always @(*) begin
        moving_up = 0;
        moving_down = 0;
        door_open = 0;
        clear_current_request = 0;
        pwm_duty = 8'd0;

        case (state)
            MOVE_UP: begin
                moving_up = 1;
                pwm_duty = 8'd180;
            end
            MOVE_DOWN: begin
                moving_down = 1;
                pwm_duty = 8'd180;
            end
            OPEN_DOOR: begin
                door_open = 1;
                clear_current_request = 1;
            end
            DOOR_WAIT: door_open = 1;
            EMERGENCY_STOP: door_open = 1;
        endcase
    end

 
    always @(*) begin
        next_state = state;   // keep in current state by default   

        case (state)
            IDLE: begin
                if (emergency_stop)
                    next_state = EMERGENCY_STOP;
                else if (floor_requests != 0)
                    next_state = CHECK_REQUEST;
            end

            CHECK_REQUEST: begin
                if (emergency_stop)
                    next_state = EMERGENCY_STOP;
                else if (floor_requests[current_floor])
                    next_state = OPEN_DOOR;
                else if (has_request_above)
                    next_state = MOVE_UP;
                else if (has_request_below)
                    next_state = MOVE_DOWN;
                else
                    next_state = IDLE;
            end

            MOVE_UP, MOVE_DOWN: begin
                if (emergency_stop)
                    next_state = EMERGENCY_STOP;
                else if (overweight)
                    next_state = WAIT_FOR_WEIGHT;
                else if (floor_requests[current_floor])
                    next_state = OPEN_DOOR;
            end

            OPEN_DOOR: begin
                next_state = DOOR_WAIT;
            end

            DOOR_WAIT: begin
                if (door_obstruction)
                    next_state = DOOR_WAIT;
                else if (timer >= DOOR_OPEN_TIME)
                    next_state = CLOSE_DOOR;
            end

            CLOSE_DOOR: begin
                if (overweight)
                    next_state = WAIT_FOR_WEIGHT;
                else
                    next_state = CHECK_REQUEST;
            end

            WAIT_FOR_WEIGHT: begin
                if (!overweight)
                    next_state = CHECK_REQUEST;
            end

            EMERGENCY_STOP: begin
                if (!emergency_stop)
                    next_state = IDLE;
            end
        endcase
    end

endmodule
