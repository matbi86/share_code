/*******************************************************************************
Author: joohan.kim (https://blog.naver.com/chacagea)
Associated Filename: skid_buffer_1d.v
Purpose: skid buffer for timing at output_ready signal. 1 cycle delay ver. 
		 ref : https://github.com/alexforencich/verilog-axis/blob/master/rtl/axis_register.v
Revision History: February 11, 2020 - initial release
*******************************************************************************/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Stream register
 */
module skid_buf_1d #
(
    // Width of stream interfaces in bits
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   reset_n,
	input  wire					  i_soft_reset,
    /*
     * Stream input
     */
    input  wire [DATA_WIDTH-1:0]  i_in_dat,
    input  wire                   i_in_vld,
    output wire                   o_in_rdy,
    /*
     * Stream output
     */
    output wire [DATA_WIDTH-1:0]  o_ot_dat,
    output wire                   o_ot_vld,
    input  wire                   i_ot_rdy
);

    // skid buffer, no bubble cycles
    // datapath registers
    reg                  o_in_rdy_reg;

    reg [DATA_WIDTH-1:0] o_ot_dat_reg;
    reg                  o_ot_vld_reg, o_ot_vld_next;

    reg [DATA_WIDTH-1:0] temp_o_ot_dat_reg;
    reg                  temp_o_ot_vld_reg, temp_o_ot_vld_next;

    // datapath control
    reg store_input_to_output;
    reg store_input_to_temp;
    reg store_temp_to_output;

    assign o_in_rdy = o_in_rdy_reg;
    assign o_ot_dat  = o_ot_dat_reg;
    assign o_ot_vld = o_ot_vld_reg;

    // enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
    wire o_in_rdy_early = i_ot_rdy || (!temp_o_ot_vld_reg && (!o_ot_vld_reg || !i_in_vld));

    always @(*) begin
        // transfer sink ready state to source
        o_ot_vld_next = o_ot_vld_reg;
        temp_o_ot_vld_next = temp_o_ot_vld_reg;

        store_input_to_output = 1'b0;
        store_input_to_temp = 1'b0;
        store_temp_to_output = 1'b0;

        if (o_in_rdy_reg) begin
            // input is ready
            if (i_ot_rdy || !o_ot_vld_reg) begin
                // output is ready or currently not valid, transfer data to output
                o_ot_vld_next = i_in_vld;
                store_input_to_output = 1'b1;
            end else begin
                // output is not ready, store input in temp
                temp_o_ot_vld_next = i_in_vld;
                store_input_to_temp = 1'b1;
            end
        end else if (i_ot_rdy) begin
            // input is not ready, but output is ready
            o_ot_vld_next = temp_o_ot_vld_reg;
            temp_o_ot_vld_next = 1'b0;
            store_temp_to_output = 1'b1;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            o_in_rdy_reg <= 1'b0;
            o_ot_vld_reg <= 1'b0;
            temp_o_ot_vld_reg <= 1'b0;
        end else if (i_soft_reset) begin
            o_in_rdy_reg <= 1'b0;
            o_ot_vld_reg <= 1'b0;
            temp_o_ot_vld_reg <= 1'b0;
        end else begin
            o_in_rdy_reg <= o_in_rdy_early;
            o_ot_vld_reg <= o_ot_vld_next;
            temp_o_ot_vld_reg <= temp_o_ot_vld_next;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
			o_ot_dat_reg <= {DATA_WIDTH{1'b0}};
        end else if (i_soft_reset) begin 
			o_ot_dat_reg <= {DATA_WIDTH{1'b0}};
        end else if (store_input_to_output) begin 
            o_ot_dat_reg <= i_in_dat;
        end else if (store_temp_to_output) begin
            o_ot_dat_reg <= temp_o_ot_dat_reg;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
			temp_o_ot_dat_reg <= {DATA_WIDTH{1'b0}};
        end else if (i_soft_reset) begin 
			temp_o_ot_dat_reg <= {DATA_WIDTH{1'b0}};
        end else if (store_input_to_temp) begin 
            temp_o_ot_dat_reg <= i_in_dat;
        end
    end

endmodule
