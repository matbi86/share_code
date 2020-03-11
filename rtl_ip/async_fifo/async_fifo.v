/*******************************************************************************
Author: joohan.kim (https://blog.naver.com/chacagea)
Associated Filename: async_fifo.v
Purpose: async fifo for CDC 
		 ref : http://www.asic-world.com/examples/verilog/asyn_fifo.html
Revision History: February 11, 2020 - initial release
*******************************************************************************/
// Reference
//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================

`timescale 1ns/1ps

module async_fifo
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (
     input wire                          rclk,        
	 output reg  [DATA_WIDTH-1:0]        o_get_cmd, 
     output reg                          o_empty,
     input wire                          i_get_en,
     //Writing port.	 
     input wire                          wclk,
     input wire  [DATA_WIDTH-1:0]        i_put_cmd,  
     output reg                          o_full,
     input wire                          i_put_en,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'o_get_cmd' logic:
    always @ (posedge rclk) begin
        if (i_get_en & !o_empty)
            o_get_cmd <= Mem[pNextWordToRead];
	end
            
    //'i_put_cmd' logic:
    always @ (posedge wclk)
        if (i_put_en & !o_full)
            Mem[pNextWordToWrite] <= i_put_cmd;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = i_put_en & ~o_full;
    assign NextReadAddressEn  = i_get_en  & ~o_empty;
           
    //Addreses (Gray counters) logic:
    gray_counter  # (ADDRESS_WIDTH) 
	GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(wclk)
       );
       
    gray_counter # (ADDRESS_WIDTH)
	GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(rclk)
       );

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, Clear_in) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | Clear_in)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    //'o_full' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    always @ (posedge wclk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            o_full <= 1;
        else
            o_full <= 0;
            
    //'o_empty' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge rclk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            o_empty <= 1;
        else
            o_empty <= 0;
            
endmodule
