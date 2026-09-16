import common_pkg::*;

module tb_msg #(
    parameter MARKER        = "",
    parameter ERROR_MSG    = ON,
    parameter WARNING_MSG  = ON,
    parameter NORMAL_MSG   = ON,
    parameter DEBUG_MSG    = OFF 
)();

    integer  n_msg_cnt;
    integer  w_msg_cnt;
    integer  d_msg_cnt;
    integer  e_msg_cnt;
    integer  o_msg_cnt;

    initial begin
        n_msg_cnt = 0;
        w_msg_cnt = 0;
        d_msg_cnt = 0;
        e_msg_cnt = 0;
        o_msg_cnt = 0;
    end

    task log_msg(
        input string msg,
        input string tag="",
        input string inst_name="",
        inout integer cntr=o_msg_cnt,
        input on_off=ON 
    );
        if (on_off) begin
            $display(msg_format, $time, MARKER, tag, " ", msg, inst_name);
            cntr++;
        end
    endtask

    task info(input string msg, input string inst_name="");
        log_msg(
            .msg(msg), 
            .tag("[Info   ]"), 
            .inst_name(inst_name), 
            .cntr(n_msg_cnt), 
            .on_off(NORMAL_MSG  )
        );
    endtask

    task warning(input string msg, input string inst_name="");
        log_msg(
            .msg(msg), 
            .tag("[Warning]"), 
            .inst_name(inst_name), 
            .cntr(w_msg_cnt), 
            .on_off(WARNING_MSG )
        );
    endtask

    task debug(input string msg, input string inst_name="");
        log_msg(.msg(msg), 
        .tag("[Debug  ]"), 
        .inst_name(inst_name), 
        .cntr(d_msg_cnt), 
        .on_off(DEBUG_MSG   )
    );
    endtask

    task error(input string msg, input string inst_name="");
        log_msg(
            .msg(msg), 
            .tag("[Error  ]"), 
            .inst_name(inst_name), 
            .cntr(e_msg_cnt), 
            .on_off(ERROR_MSG   )
        );
    endtask

    task start();
        info("Simulation start...");
    endtask

    task complite();
        info("Simulation complite!");
        report();
    endtask

    task timeout();
        warning("Simulation timeout!");
        report();
    endtask

    task report();
        $display("[%12t]: Simulation report...",$time);
        $display("************************");
        $display("***Message Counters*****");
        $display("     Info   : %0d",n_msg_cnt);
        $display("     Warning: %0d",w_msg_cnt);
        $display("     Debug  : %0d",d_msg_cnt);
        $display("     Error  : %0d",e_msg_cnt);
        $display("     Others : %0d",o_msg_cnt);
        $display("************************");
        if(e_msg_cnt) begin
            $display("***SIMULATION FAILED****");
        end
        else begin
            $display("***SIMULATION PASSED****");
        end
    endtask


endmodule
