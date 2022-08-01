module debug (of, accu, fsm, ar, datr, prgctr, instr, lcd, dcod);
  input of;
  input [7:0] lcd, dcod;
  input [10:0] fsm;
  input [11:0] ar, prgctr;
  input [15:0] accu, datr, instr;
// For debug purpose
  initial begin
    $display($time,"                 e  ac   t  ar  dr   pc  ir  disp");
    $monitor($time," THE ANSWER IS = %b %h %h %h %h %h %h %h", of, accu, fsm, ar, datr, prgctr, instr, lcd);
  end

  always @* begin
    if (!instr[15] && dcod[7] && fsm[3] && instr[0]) begin
      $display($time, "  Program Is Terminated.  AC = %h", accu);
      $finish;
    end
  end

endmodule

/*____________________________________________________________________________*/
///////////////////////////////*  TEST BENCH  */////////////////////////////////________________________________________________________________________________********************************************************************************

module testbench;

  wire [15:0] datin, datut;
  wire [11:0] adr;
  wire rw,n;
  reg ck, rs, intr_in, intr_out;
  wire [7:0] display;
  reg [7:0] keyboard;

  cpu cpu1 (.clk(ck), .addr(adr), .datain(datut), .dataout(datin), .en_inp(intr_in), .en_out(intr_out), .rdwr(rw), .en(n), .rst(rs), .keyboard(keyboard), .display(display));
  memory mem1 (.clock(ck), .addr(adr), .datain(datin), .dataout(datut), .rdwr(rw), .en(n));
                                                     /* Explicite association */
  always
    #50 ck = ~ck;

`ifdef DUMP_VCD
  initial begin
    $dumpfile("up1.vcd");
    $dumpvars;
  end 
`endif

  initial begin
    $readmemh("prog.mem", mem1.mem);

    ck = 1'b0;
    #10 rs = 1'b1;
    #200 rs = 1'b0; intr_in = 1; intr_out = 1; keyboard = 8'h77;
    #10000 $finish;

/*
      $monitor($time," TEST DISPLAY = %b",display);
      #950 keyboard = 8'h99;
      #5000 keyboard = 8'h77;
      #9000 keyboard = 8'h88;
      #10000 keyboard = 8'hee;
*/
  end 
endmodule
