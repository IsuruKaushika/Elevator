module request_handler #(
    parameter NUM_FLOORS = 10,
    parameter FLOOR_WIDTH = 4
)(
    input clk,
    input reset,
    input [NUM_FLOORS-1:0] new_requests,
    input [FLOOR_WIDTH-1:0] current_floor,
    input clear_current_request,
    output reg [NUM_FLOORS-1:0] floor_requests
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            floor_requests <= 0;
        else begin
            floor_requests <= floor_requests | new_requests;
            if (clear_current_request)
                floor_requests[current_floor] <= 0;
        end
    end

endmodule
