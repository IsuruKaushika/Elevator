module pwm_generator(
    input clk,
    input reset,
    input [7:0] duty_cycle,
    output reg pwm_out
);
    reg [7:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            pwm_out <= 0;
        else
            pwm_out <= (counter < duty_cycle);
    end
endmodule