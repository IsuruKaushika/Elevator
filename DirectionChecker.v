module direction_checker #(
    parameter NUM_FLOORS = 10,
    parameter FLOOR_WIDTH = 4
)(
    input [FLOOR_WIDTH-1:0] current_floor,
    input [NUM_FLOORS-1:0] floor_requests,
    output reg has_request_above,
    output reg has_request_below
);

    integer i;
    always @(*) begin
        has_request_above = 0;
        has_request_below = 0;
        for (i = 0; i < NUM_FLOORS; i = i + 1) begin
            if (i > current_floor && floor_requests[i])
                has_request_above = 1;
            if (i < current_floor && floor_requests[i])
                has_request_below = 1;
        end
    end

endmodule
