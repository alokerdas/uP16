/*____________________________________________________________________________*/                     
/////////////////////////*  MEMORY ( 16 X 12 bit )  *///////////////////////////________________________________________________________________________________********************************************************************************
                                                                               
module memory (clock, addr, datain, dataout, rdwr, en);
  input [11:0] addr;
  input [15:0] datain;
  input clock, rdwr, en;
  output [15:0] dataout;

  reg [15:0] dataout;
  reg [15:0] mem [0:4095];
 
  always @ (posedge clock) begin
    if (en) begin
      if (rdwr) begin
        mem[addr] <= datain;
      end else begin
        dataout <= mem[addr];
      end
    end
  end

endmodule
