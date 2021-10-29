/*____________________________________________________________________________*/

///////////////////////////////*  TEST BENCH  */////////////////////////////////________________________________________________________________________________********************************************************************************

module testbench;

   wire [15:0] dat;
   wire [11:0] adr;
   wire rw,n,ak;;
   reg ck, rs, intr_in, intr_out;
   wire [7:0] display;
   reg [7:0] keyboard;

   cpu cpu1 (.clk(ck), .addr(adr), .data(dat), .en_inp(intr_in), .en_out(intr_out), .rdwr(rw), .en(n), .ack(ak), .rst(rs), .keyboard(keyboard), .display(display));
   memory mem1 (.addr(adr), .data(dat), .rdwr(rw), .en(n), .ack(ak));
                                                     /* Explicite association */
   always
      #50 ck = ~ck;

/*
   initial
   begin
     $dumpfile("up.vcd");
     $dumpvars;
   end 
*/

   initial
   begin
      ck = 1'b0;
      #10 rs = 1'b1;
      #200 rs = 1'b0; intr_in = 1; intr_out = 1; keyboard = 8'h77;

/*
      $monitor($time," TEST DISPLAY = %b",display);
      #950 keyboard = 8'h99;
      #5000 keyboard = 8'h77;
      #9000 keyboard = 8'h88;
      #10000 keyboard = 8'hee;
*/
   end 
endmodule
