module floor_position_detector #(
    parameter NUM_FLOORS = 10,
    parameter FLOOR_WIDTH = 4
)(
    input [NUM_FLOORS-1:0] floor_sensors,
    output reg [FLOOR_WIDTH-1:0] current_floor
);

    integer i;
    always @(*) begin
        current_floor = 0;
        for (i = 0; i < NUM_FLOORS; i = i + 1)
            if (floor_sensors[i])
                current_floor = i[FLOOR_WIDTH-1:0];
    end

endmodule
