`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Keefe Johnson
// 
// Create Date: 05/09/2019 05:27:29 PM
// Updated Date: 02/13/2020 11:00:00 AM
// Design Name: 
// Module Name: programmer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import memory_bus_sizes::*;

// WARNING: this programmer assumes WORD_SIZE = 4 and ADDR_WIDTH = 32!

module programmer #(
    parameter CLK_RATE = -1,      // rate of clk in MHz (must override)
    parameter BAUD = 115200,      // raw serial rate in bits/s
    parameter IB_TIMEOUT = 200,    // timeout during word in ms  
    parameter WAIT_TIMEOUT = 500  // timeout during multi-word cmd in ms
    )(
    input clk,
    input rst,
    input srx,
    output stx,
    output mcu_reset,
    axi_bus_rw.controller mhub
    );

    // timeout if waiting for a serial word for too long
    localparam TIMEOUT_CLKS = CLK_RATE * WAIT_TIMEOUT * 1000;
    logic [$clog2(TIMEOUT_CLKS+1)-1:0] r_timeout_counter = 0;
    logic waiting;
    wire timed_out;
       
    // commands accepted
    localparam CMD_RESET_ON = 24'h0FF000;
    localparam CMD_RESET_OFF = 24'h0FF001;
    localparam CMD_WRITE_MEM = 24'h0FF002;
    
    // other constants
    localparam FAIL_RESPONSE = 32'hF00FF00F;
    
    // state
    typedef enum {IDLE, FAILED, WM_WAIT_ADDR, WM_WAIT_LEN, WM_WAIT_DATA,
                  WM_DONE, DISABLED} e_state;

    // tx_word mux select
    enum {ECHO, CKSUM, INV_CKSUM, FAIL} sel_tx_word;

    // wires to/from modules
    wire rx_ready;
    wire rx_valid;
    wire tx_idle;
    wire [31:0] rx_word;
    logic [31:0] tx_word;
    logic tx_send;

    // control signals between fsm and datapath 
    e_state next_state;
    logic set_mcu_reset;
    logic clr_mcu_reset;
    logic ld_ram_addr;
    logic inc_ram_addr;
    logic ld_words_remain;
    logic dec_words_remain;
    logic clr_cksum;
    logic acc_cksum;
    logic set_error;
    logic clr_error;

    // registers
    e_state r_state = IDLE;//DISABLED;//IDLE;
    logic [31:0] r_words_remain = 0;
    logic [31:0] r_ram_addr = 0;
    logic r_mcu_reset = 0;
    logic [31:0] r_cksum = 0;
    logic r_error = 0;

    // serial IO modules
    uart_rx_word #(.CLK_RATE(CLK_RATE), .BAUD(BAUD), .IB_TIMEOUT(IB_TIMEOUT))
        uart_rx_word(.clk(clk), .rst(rst), .srx(srx), .ready(rx_ready),
                     .rx_word(rx_word));
    uart_tx_word #(.CLK_RATE(CLK_RATE), .BAUD(BAUD))
        uart_tx_word(.clk(clk), .rst(rst), .start(tx_send), .tx_word(tx_word),
                     .stx(stx), .idle(tx_idle));
    
    // fixed combinational logic
    assign timed_out = (r_timeout_counter == TIMEOUT_CLKS);
    assign rx_valid = (rx_word[7:0] ^ rx_word[15:8] ^ rx_word[23:16]
                       ^ rx_word[31:24]) == 0;
    assign mcu_reset = r_mcu_reset;
    assign mhub.write_addr = r_ram_addr; // [31:2];
    assign mhub.write_data = rx_word;
    //assign mhub.flush = 0;
    //assign mhub.we = 1;  // always write when mhub.en=1
    

    // tx_word mux
    always_comb begin
        case (sel_tx_word)
            ECHO: tx_word = rx_word;
            CKSUM: tx_word = r_cksum;
            INV_CKSUM: tx_word = ~r_cksum;  // used to indicate data flow error
            FAIL: tx_word = FAIL_RESPONSE;
            default: tx_word = FAIL_RESPONSE;
        endcase
    end
    
    // next state and control logic
    always_comb begin

        next_state = r_state;
        waiting = 0;
        mhub.write_addr_valid = 0;
        set_mcu_reset = 0;
        clr_mcu_reset = 0;
        ld_ram_addr = 0;
        inc_ram_addr = 0;
        ld_words_remain = 0;
        dec_words_remain = 0;
        clr_cksum = 0;
        acc_cksum = 0;
        set_error = 0;
        clr_error = 0;
        tx_send = 0;
        sel_tx_word = ECHO;

        case (r_state)

            IDLE: begin
                if (rx_ready && rx_valid && tx_idle) begin
                    case (rx_word[31:8]) 

                        CMD_RESET_ON: begin
                            set_mcu_reset = 1;
                            sel_tx_word = ECHO;
                            tx_send = 1;
                        end

                        CMD_RESET_OFF: begin
                            clr_mcu_reset = 1;
                            sel_tx_word = ECHO;
                            tx_send = 1;
                        end

                        CMD_WRITE_MEM: begin
                            sel_tx_word = ECHO;
                            tx_send = 1;
                            clr_cksum = 1;
                            clr_error = 1;
                            next_state = WM_WAIT_ADDR;
                        end

                    endcase   
                end
            end

            FAILED: begin
                if (tx_idle) begin
                    sel_tx_word = FAIL;
                    tx_send = 1;
                    next_state = IDLE;
                end
            end

            WM_WAIT_ADDR: begin
                waiting = 1;
                if (timed_out) begin
                    next_state = FAILED;
                end else if (rx_ready) begin
                    waiting = 0;
                    ld_ram_addr = 1;
                    acc_cksum = 1;
                    next_state = WM_WAIT_LEN;
                end
            end

            WM_WAIT_LEN: begin
                waiting = 1;
                if (timed_out) begin
                    next_state = FAILED;
                end else if (rx_ready) begin
                    waiting = 0;
                    ld_words_remain = 1;
                    acc_cksum = 1;
                    next_state = WM_WAIT_DATA;
                end
            end

            WM_WAIT_DATA: begin
                waiting = 1;
                if (timed_out) begin
                    next_state = FAILED;
                end else if (rx_ready) begin
                    waiting = 0;
                    acc_cksum = 1;
                    inc_ram_addr = 1;
                    dec_words_remain = 1;
                    if (!r_error) begin
                        // if a previous word failed to be accepted by mhub,
                        //   silently discard remaining words  
                        mhub.write_addr_valid = 1;
                    end 
                    if (!mhub.write_addr_ready) begin
                        // if mhub isn't ready to accept the write immediately,
                        //   the transfer has failed, because we can't wait or
                        //   we'll lose serial data! but we must still read
                        //   the rest of the serial data as there's currently
                        //   no protocol to tell the pc-side to pause or cancel
                        
                        //actually, don't worry about it for now
                        //TODO: make it more robust
                        //set_error = 1;
                    end
                    if (r_words_remain == 1) begin
                        next_state = WM_DONE;
                    end 
                end
            end

            WM_DONE: begin
                if (tx_idle) begin
                    if (r_error) begin
                        // if a data flow error occurred, we need to return a
                        //   known-incorrect checksum rather than a fixed error
                        //   code (which might by chance match the correct
                        //   checksum), until the protocol is revised to handle an
                        //   explicit error code here
                        sel_tx_word = INV_CKSUM;
                    end else begin
                        sel_tx_word = CKSUM;
                    end
                    tx_send = 1;
                    clr_error = 1;
                    next_state = IDLE;
                end
            end
    
            DISABLED: next_state = DISABLED;

            default: next_state = IDLE;
        endcase
    end

    // update registers on clock ticks
    always_ff @(posedge clk) begin

        // r_state
        r_state <= next_state;

        // r_mcu_reset: set or clear
        if (set_mcu_reset) begin
            r_mcu_reset <= 1;
        end else if (clr_mcu_reset) begin
            r_mcu_reset <= 0;
        end
        
        // r_ram_addr: load or increment
        if (ld_ram_addr) begin
            r_ram_addr <= rx_word;
        end else if (inc_ram_addr) begin
            r_ram_addr <= r_ram_addr + 4;
        end

        // r_words_remain: load or decrement
        if (ld_words_remain) begin
            r_words_remain <= rx_word;
        end else if (dec_words_remain) begin
            r_words_remain <= r_words_remain - 1;
        end

        // r_cksum: clear or accumulate
        if (clr_cksum) begin
            r_cksum <= 0;
        end else if (acc_cksum) begin
            r_cksum <= r_cksum ^ rx_word;
        end

        // r_timeout_counter: clear or increment until max
        if (waiting) begin
            if (!timed_out) begin
                r_timeout_counter <= r_timeout_counter + 1;
            end
        end else begin
            r_timeout_counter = 0;
        end

        // error flag
        if (set_error) begin
            r_error <= 1;
        end else if (clr_error) begin
            r_error <= 0;
        end

    end    
    
endmodule
