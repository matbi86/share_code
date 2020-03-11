/*******************************************************************************
Author: joohan.kim (https://blog.naver.com/chacagea)
Associated Filename: async_fifo.v
Purpose: Synchronous Fifo
Revision History: February 11, 2020 - initial release
*******************************************************************************/
module sync_fifo 
# (
	parameter   FIFO_CMD_LENGTH = 10,
	parameter   FIFO_DEPTH      = 4,
	parameter   FIFO_LOG2_DEPTH = 2
)
(
	input           				clk,
	input           				reset_n,
	input           				i_soft_reset,
	input           				i_put_en,
	input   [FIFO_CMD_LENGTH-1:0] 	i_put_cmd,
	input           				i_get_en,
	output  [FIFO_CMD_LENGTH-1:0] 	o_get_cmd,
	output         				 	o_empty,
	output          				o_full
);

/// Wire / Reg 
reg     [FIFO_LOG2_DEPTH-1:0] 	wptr, wptr_nxt;
reg             				wptr_round, wptr_round_nxt;
reg     [FIFO_LOG2_DEPTH-1:0] 	rptr, rptr_nxt;
reg             				rptr_round, rptr_round_nxt;
reg     [FIFO_CMD_LENGTH-1:0] 	cmd_fifo[FIFO_DEPTH-1:0];

/// Body
integer i;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		wptr <= 0;
		wptr_round <= 0;
		for (i=0; i<FIFO_DEPTH; i=i+1)
			cmd_fifo[i] <= {(FIFO_CMD_LENGTH){1'b0}};
	end else if (i_soft_reset) begin
		wptr <= 0;
		wptr_round <= 0;
		for (i=0; i<FIFO_DEPTH; i=i+1)
			cmd_fifo[i] <= {(FIFO_CMD_LENGTH){1'b0}};
	end else if (i_put_en) begin
		cmd_fifo[wptr] <= i_put_cmd;
		{wptr_round,wptr}<= {wptr_round_nxt,wptr_nxt};
	end
end

always @(*) begin
	if (wptr == (FIFO_DEPTH-1)) begin
		wptr_nxt = 0;
		wptr_round_nxt = ~wptr_round;
	end else begin
		wptr_nxt = wptr + 'd1;
		wptr_round_nxt = wptr_round;
	end
end

always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		rptr <= 0;
		rptr_round <= 0;
	end else if (i_soft_reset) begin
		rptr <= 0;
		rptr_round <= 0;
	end else if (i_get_en) begin
		{rptr_round,rptr} <= {rptr_round_nxt,rptr_nxt};
	end
end

assign o_get_cmd = cmd_fifo[rptr];

always @(*) begin
	if (rptr == (FIFO_DEPTH-1)) begin
		rptr_nxt = 0;
		rptr_round_nxt = ~rptr_round;
	end else begin
		rptr_nxt = rptr + 'd1;
		rptr_round_nxt = rptr_round;
	end
end

assign o_empty  = (wptr_round==rptr_round) && (wptr==rptr);
assign o_full = (wptr_round!=rptr_round) && (wptr==rptr);

endmodule

