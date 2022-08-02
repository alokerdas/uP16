module testbench;

  wire [15:0] datin, datut;
  wire [11:0] adr;
  wire [7:0] display;
  wire rw,n;
  reg ck, rs, intr_in, intr_out;
  reg [7:0] keyboard;

  initial begin
    $readmemh("prog.mem", mem1.mem);
    $display($time,"                 e  ac   t  ar  dr   pc  ir  disp");
    $monitor($time," THE ANSWER IS = %b %h %h %h %h %h %h %h", cpu1.e, cpu1.ac, cpu1.t, cpu1.addr, cpu1.dr, cpu1.pc, cpu1.ir, cpu1.display);

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

`ifdef DUMP_VCD
  initial begin
    $dumpfile("up1.vcd");
    $dumpvars;
  end 
`endif

  always
    #50 ck = ~ck;

  cpu cpu1 (.clkin(ck), .addr(adr), .datain(datut), .dataout(datin), .en_inp(intr_in), .en_out(intr_out), .rdwr(rw), .en(n), .rst(rs), .keyboard(keyboard), .display(display));
  memory mem1 (.clock(ck), .addr(adr), .datain(datin), .dataout(datut), .rdwr(rw), .en(n));
                                                     /* Explicite association */
endmodule
