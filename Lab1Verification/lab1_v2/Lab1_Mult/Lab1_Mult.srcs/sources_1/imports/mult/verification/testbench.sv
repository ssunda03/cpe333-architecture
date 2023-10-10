import mult_types::*;

module testbench(multiplier_itf.testbench itf);

add_shift_multiplier dut (
    .clk_i          ( itf.clk          ),
    .reset_n_i      ( itf.reset_n      ),
    .multiplicand_i ( itf.multiplicand ),
    .multiplier_i   ( itf.multiplier   ),
    .start_i        ( itf.start        ),
    .ready_o        ( itf.rdy          ),
    .product_o      ( itf.product      ),
    .done_o         ( itf.done         )
);

assign itf.mult_op = dut.ms.op;
default clocking tb_clk @(negedge itf.clk); endclocking

// error_e defined in package mult_types in file types.sv
// Asynchronously reports error in DUT to grading harness
function void report_error(error_e error);
    itf.tb_report_dut_error(error);
endfunction : report_error


// Resets the multiplier
task reset();
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##1;
endtask : reset

// DO NOT MODIFY CODE ABOVE THIS LINE

/* Uncomment to "monitor" changes to adder operational state over time */
//initial $monitor("dut-op: time: %0t op: %s", $time, dut.ms.op.name);


initial itf.reset_n = 1'b0;

initial begin
    reset();
    /********************** Your Code Here *****************************/
	for (int i = 0; i < 9'b100000000; ++i) begin
	   for(int j = 0; j < 9'b100000000; ++j) begin
	       @(tb_clk iff itf.rdy == 1);
	       itf.multiplicand = i;
	       itf.multiplier = j;
	       itf.start = 1;
	       ##1
	       //itf.multiplicand = 0;
	       //itf.multiplier = 0;
	       itf.start = 0;
	       @(tb_clk iff itf.done == 1);
	       assert(itf.rdy == 1)
	           else begin
	               $error ("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
                   report_error (NOT_READY);
	           end
	       assert(itf.product == i * j)
	           else begin
	               $error ("%0d: %0t: BAD_PRODUCT error detected", `__LINE__, $time);
                   report_error (BAD_PRODUCT);
	           end
	       reset();
	       assert(itf.rdy == 1)
	           else begin
	               $error ("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
                   report_error (NOT_READY);
	           end
	   end
	   @(tb_clk iff itf.rdy == 1);
	   itf.multiplicand = 2454;
	   itf.multiplicand = 4123;
	   itf.start = 1;
	   ##1
	   itf.multiplicand = 0;
	   itf.multiplicand = 0;
	   itf.start = 0;
	   @(tb_clk iff itf.mult_op == ADD);
	   itf.start = 1;
	   ##1
	   itf.start = 0;
	   @(tb_clk iff itf.mult_op == SHIFT);
	   itf.start = 1;
	   ##1
	   itf.start = 0;
	   @(tb_clk iff itf.done == 1);
	   reset();
	   //
	   @(tb_clk iff itf.rdy == 1);
	   itf.multiplicand = 2454;
	   itf.multiplicand = 4123;
	   itf.start = 1;
	   ##1
	   itf.multiplicand = 0;
	   itf.multiplicand = 0;
	   itf.start = 0;
	   @(tb_clk iff itf.mult_op == ADD);
	   reset();
	   @(tb_clk iff itf.rdy == 1);
	   itf.multiplicand = 2454;
	   itf.multiplicand = 4123;
	   itf.start = 1;
	   ##1
	   itf.multiplicand = 0;
	   itf.multiplicand = 0;
	   itf.start = 0;
	   @(tb_clk iff itf.mult_op == SHIFT);
	   reset();
	   
	   reset();
	end

    /*******************************************************************/
    itf.finish(); // Use this finish task in order to let grading harness
                  // complete in process and/or scheduled operations
    $error("Improper Simulation Exit");
end

endmodule : testbench
