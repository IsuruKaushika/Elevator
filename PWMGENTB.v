`timescale 1ns / 1ps
`include "PwmGenerator.v"

module pwm_generator_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] duty_cycle;

    // Output
    wire pwm_out;

    // Instantiate the DUT
    pwm_generator uut (
        .clk(clk),
        .reset(reset),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor output
    initial begin
        $display("Time\tReset\tDutyCycle\tPWM");
        $monitor("%0t\t%b\t%d\t\t%b", $time, reset, duty_cycle, pwm_out);
    end

    // VCD file for GTKWave
    initial begin
        $dumpfile("pwm_generator.vcd");
        $dumpvars(0, pwm_generator_tb);
    end

    // Stimulus
    initial begin
        reset = 1;
        duty_cycle = 0;
        #20 reset = 0;

        // 25% duty cycle
        duty_cycle = 8'd64;  // 64 / 255 ≈ 25%
        #2560;               // Run for a few PWM periods

        // 50% duty cycle
        duty_cycle = 8'd128; // 50%
        #2560;

        // 75% duty cycle
        duty_cycle = 8'd192; // 75%
        #2560;

        // 0% duty cycle
        duty_cycle = 8'd0;
        #2560;

        // 100% duty cycle
        duty_cycle = 8'd255;
        #2560;

        $finish;
    end

endmodule
