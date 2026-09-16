`timescale 1ns / 1ps

module freq_gen#(
    parameter RESET_ACTIVE          = 0,
    parameter DUTY_CYCLE            = 0.6,
    parameter CLK_FREQ_HZ           = 100_000_000,
    parameter LOCKED_DELAY_STROBS   = 100,
    parameter RESET_DELAY_STROBS    = 200,
    parameter LOCKED_DELAY_TIME     = LOCKED_DELAY_STROBS * (1_000_000_000 / CLK_FREQ_HZ),
    parameter RESET_DELAY_TIME      = RESET_DELAY_STROBS * (1_000_000_000 / CLK_FREQ_HZ) 
)(
    output logic clk_o      ,
    output logic reset_o    ,
    output logic locked_o    
);
    localparam CLK_PERIOD_NS    = 1_000_000_000 / CLK_FREQ_HZ;
    localparam CLK_PERIOD_NS_L  = CLK_PERIOD_NS * DUTY_CYCLE;
    localparam CLK_PERIOD_NS_H  = CLK_PERIOD_NS - CLK_PERIOD_NS_L;

    localparam HIGH = 1'b1;
    localparam LOW  = 1'b0;
    localparam TRIZ = 1'bz;

    logic clk_r;
    logic locked_r;
    logic reset_r;

    // Генерация тактового сигнала
    initial begin
        $display("%s.CLK_PERIOD_NS = %0d", $sformatf("%m"), CLK_PERIOD_NS);
        forever begin
            clk_r = LOW;
            #(CLK_PERIOD_NS_L);
            clk_r = HIGH;
            #(CLK_PERIOD_NS_H);
        end
    end

    initial begin
        locked_r = LOW;
        #(LOCKED_DELAY_TIME);
        locked_r = HIGH;
        // $display("%0t ns : Set locked", $time);
    end

    initial begin
        reset_r = LOW;
        // $display("%0t ns : Set reset", $time);
        #(RESET_DELAY_TIME);
        reset_r = HIGH;
        // $display("%0t ns : Unset reset", $time);
    end

    task delay (
        input integer num_cycles
    );
        repeat(num_cycles) @(posedge (clk_r));
    endtask

    task gen_reset(input integer cnt_t);
        reset_r = LOW;
        delay(cnt_t);
        reset_r = HIGH;
    endtask

    assign clk_o = clk_r;
    assign locked_o = locked_r;
    assign reset_o = (RESET_ACTIVE == 0) ? reset_r: ~reset_r;

endmodule
