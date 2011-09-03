/*
 * $Id$
 */

module xbus_ram (
		 clk, reset,
		 addr, datain, dataout,
		 req, write, ack, decode,

		 sdram_addr, sdram_data_in, sdram_data_out,
		 sdram_req, sdram_ready, sdram_write, sdram_done
		);

   input reset;
   input clk;
   input [21:0] addr;
   input [31:0] datain;
   input 	req;
   input 	write;
   
   output [31:0] dataout;
   output 	 ack;
   output 	 decode;

   output [21:0]  sdram_addr;
   output [31:0] sdram_data_out;
   input [31:0]  sdram_data_in;
   output 	 sdram_req;
   input 	 sdram_ready;
   output 	 sdram_write;
   input 	 sdram_done;

//   parameter 	 DRAM_SIZE = 2097152;
//   parameter 	 DRAM_BITS = 21;

//   parameter 	 DRAM_SIZE = 1048576;
//   parameter 	 DRAM_BITS = 20;

//   parameter 	 DRAM_SIZE = 524288;
//   parameter 	 DRAM_BITS = 19;

//   parameter 	 DRAM_SIZE = 262144;
//   parameter 	 DRAM_BITS = 18;

   parameter 	 DRAM_SIZE = 131072;
   parameter 	 DRAM_BITS = 17;
   
   //
   reg [31:0] 	 ram[DRAM_SIZE-1:0];

   integer i, debug;
   
   initial
     begin
	debug = 0;
debug = 1;
	for (i = 0; i < DRAM_SIZE; i = i + 1)
	  ram[i] = 0;
     end
   
   reg 		 req_delayed;
   reg [6:0] 	 ack_delayed;

   // need some dram address space at the end 
   // which is decoded but does not read/write...
   assign 	 decode = addr < 22'o11000000 ? 1'b1: 1'b0;

   assign 	 ack = ack_delayed[1];
//   assign 	 ack = ack_delayed[6];   

   wire [DRAM_BITS-1:0] addr20;
   assign addr20 = addr[DRAM_BITS-1:0];
   
   always @(posedge clk)
     if (reset)
       begin
          req_delayed <= 0;
          ack_delayed <= 7'b0;
       end
    else
      begin
         req_delayed <= req & decode & ~|ack_delayed;
         ack_delayed[0] <= req_delayed;
         ack_delayed[1] <= ack_delayed[0];
         ack_delayed[2] <= ack_delayed[1];
         ack_delayed[3] <= ack_delayed[2];
         ack_delayed[4] <= ack_delayed[3];
         ack_delayed[5] <= ack_delayed[4];
         ack_delayed[6] <= ack_delayed[5];

`ifdef debug_detail_delay
	 if (req & decode)
	   $display("ddr: decode %b; %b %b",
		    req & decode, req_delayed, ack_delayed);

	 if (req & decode & ~|ack_delayed)
	   $display("ddr: req_delayed %b", req & decode & ~|ack_delayed);

	 if (ack_delayed[6])
	     $display("ddr: ack %b", ack);
`endif
      end

   always @(posedge clk)
     begin
	if (req & decode & req_delayed & ~|ack_delayed)
	  if (write)
	    begin
`ifdef debug
	       if (debug != 0)
               $display("sdram: write @%o <- %o", addr20, datain);
`endif
	       if (addr < DRAM_SIZE)
		 ram[addr20] <= datain;
	    end
	  else
	    begin
`ifdef debug
	       if (debug != 0)
               $display("sdram: read @%o -> %o (0x%x) (addr=%o), %t",
			addr20, ram[addr20], ram[addr20], addr, $time);
`endif
	    end
     end

   assign dataout = addr < DRAM_SIZE ? ram[addr20] : 32'hffffffff;

endmodule
