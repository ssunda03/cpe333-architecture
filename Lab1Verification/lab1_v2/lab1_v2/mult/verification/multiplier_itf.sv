`ifndef multiplier_itf
`define multiplier_itf

interface multiplier_itf;
    import mult_types::*;
    bit clk, reset_n, start, rdy, done;
    operand_t multiplicand, multiplier;
    result_t product;
    op_e mult_op;
    time timestamp;
    
    struct {
        logic bp [time]; // BAD_PRODUCT errors
        logic nr [time]; // NOT_READY errors
    } stu_errors;
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever begin
            #5;
            clk = ~clk;
        end
    end
    
    initial timestamp = 0;
    always @(posedge clk) timestamp += 1;
    
    function automatic void tb_report_dut_error(error_e err);
        case (err)
            BAD_PRODUCT: stu_errors.bp[timestamp] = 1'b1;
            NOT_READY: stu_errors.nr[timestamp] = 1'b1;
        endcase
    endfunction
    
    //finish
    //, tb_report_dut_error
    modport testbench (
            output mult_op, rdy, product, done, 
            input clk, reset_n,
                    multiplicand, multiplier, start,
            ref stu_errors, timestamp, 
            import task finish(), import function automatic void tb_report_dut_error(error_e err)
        );
    
    task finish();
        #1000;
        $finish;
    endtask

endinterface : multiplier_itf

module d_multiplier_itf();
endmodule

`endif
