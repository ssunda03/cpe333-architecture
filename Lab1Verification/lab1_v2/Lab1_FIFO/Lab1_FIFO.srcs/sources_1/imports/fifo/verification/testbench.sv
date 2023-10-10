`ifndef testbench
`define testbench

import fifo_types::*;

module testbench(fifo_itf itf);

fifo_synch_1r1w dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),

    // valid-ready enqueue protocol
    .data_i    ( itf.data_i  ),
    .valid_i   ( itf.valid_i ),
    .ready_o   ( itf.rdy     ),

    // valid-yumi deqeueue protocol
    .valid_o   ( itf.valid_o ),
    .data_o    ( itf.data_o  ),
    .yumi_i    ( itf.yumi    )
);
logic [7:0] count;
logic [8:0] i;
// Clock Synchronizer
default clocking tb_clk @(negedge itf.clk); endclocking
task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err); 
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

task enqueue();
	
endtask : enqueue


task dequeue();

endtask : dequeue


task simultaneously();
	
endtask : simultaneously

initial itf.reset_n = 1'b1;
initial count = 0;
initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.
    itf.valid_i <= 1;
    for(i = 0; i < 256; ++i) begin
        itf.data_i <= i;
        ##(1);
    end
    itf.valid_i <= 0;
    for(i = 0; i < 256; ++i) begin
        itf.yumi <= 1;
        assert(i == itf.data_o)
            else begin
                $error ("%0d: %0t: INCORRECT_DATA_O_ON_YUMI_I error detected", `__LINE__, $time);
                report_error (INCORRECT_DATA_O_ON_YUMI_I);
            end
        ##(1);     
    end
    itf.yumi <= 0;
    ##(1);
    for(i = 0; i < 256; ++i) begin
        itf.data_i <= count;
        itf.valid_i <= 1;
        itf.yumi <= 0;
        count <= count + 1;
        ##(1);
        itf.yumi <= 1;
        itf.data_i <= count;
        count <= count + 1;
        assert(i == itf.data_o)
            else begin
                $error ("%0d: %0t: INCORRECT_DATA_O_ON_YUMI_I error detected", `__LINE__, $time);
                report_error (INCORRECT_DATA_O_ON_YUMI_I);
            end
        ##(1);
    end
    itf.valid_i <= 0;
    itf.yumi <= 0;
    @(tb_clk);
    itf.reset_n <= 0;
    @(posedge tb_clk);
    itf.reset_n <= 1;
    assert(itf.rdy == 1)
        else begin
            $error ("%0d: %0t: RESET_DOES_NOT_CAUSE_READY_O error detected", `__LINE__, $time);
            report_error (RESET_DOES_NOT_CAUSE_READY_O);
        end
    
    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif

