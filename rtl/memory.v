/*____________________________________________________________________________*/                     
/////////////////////////*  MEMORY ( 16 X 12 bit )  *///////////////////////////________________________________________________________________________________********************************************************************************
                                                                               
module memory (addr, data, rdwr, en, ack);
   input [11:0] addr;
   inout [15:0] data;
   input rdwr, en;
   output ack;
                                                                               
   reg [15:0] dataout;
   reg ack;
   reg [15:0] mem [0:4095];
   integer j;
                                                                               
   initial begin
      $readmemh("prog.mem", mem);
   end

   assign data = dataout;
   always @ (rdwr or en)
//   always @ (rdwr)
      begin
         if (en) begin
            if (rdwr) begin
               mem[addr] = data;
            end else begin
	       dataout = mem[addr];
            end
            ack = 1'b1;
        end else begin
           dataout = 16'hzzzz;
           ack = 1'b0;
        end
     end
endmodule
