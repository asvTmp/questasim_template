`timescale 1ns / 1ps

`define TEST_DELAY 100_000ns
`define TIME_OUT_DELAY_NS 100_000

module tb_top #(
    parameter TIME_OUT_DELAY_STROBS = 700,
    parameter TIME_OUT_DELAY_NS = `TIME_OUT_DELAY_NS,
    parameter TEST_DELAY = `TEST_DELAY,
    parameter SIMULATION = 1 
)();

    localparam CLK_FREQ_HZ = 100_000_000;
    localparam LOCKED_DELAY = 50;
    localparam RESET_DELAY = 70;

    wire clk_i;
    wire reset_n;

    freq_gen #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .LOCKED_DELAY_STROBS(LOCKED_DELAY),
        .RESET_DELAY_STROBS(RESET_DELAY)
    ) U_GCLK (
        .clk_o(clk_i),
        .reset_o(reset_n),
        .locked_o()
    );

    tb_msg #(.MARKER("[T]")) MSG ();

    initial begin
        if (TIME_OUT_DELAY_NS) begin
            #(TIME_OUT_DELAY_NS);
            MSG.timeout();
            $stop;
        end
    end

    initial if (TEST_DELAY) forever #(TEST_DELAY) $display("Simulation time: %1d", ($time));

    task main();
        MSG.start();
        wait(reset_n);
        U_GCLK.delay(300);
        
        U_GCLK.delay(300);
        MSG.complite();
    endtask

endmodule
