
`define READ_MEMORY \
   dataout = 16'hzzzz; \
   addr = ar; \
   rdwr = 1'b0; \
   en = 1'b1; \

`define WRITE_MEMORY \
   addr = ar; \
   rdwr = 1'b1; \
   en = 1'b1; \

module cpu (clk, addr, data, en_inp, en_out, rdwr, en, ack, rst, keyboard, display);

   inout [15:0] data;
   output [11:0] addr;
   input clk, en_inp, en_out, ack, rst;
   output en, rdwr;
   input [7:0] keyboard;
   output [7:0] display;

   reg [15:0] ir, tr, ac, dr, dataout, t;
   reg [11:0] pc, ar, addr;
   reg [7:0] outr, inpr, get, d;
   reg [3:0] sc;
   reg i, s, e, r, ien, fgi, fgo, rdwr, en;

   wire [11:0] b;

   integer ac0,ac15;

// For debug purpose
   initial
   begin
      $display($time,"                 e  ac   t   s  ar  dr  pc  ir");
      $monitor($time," THE ANSWER IS = %b %h %h %b %h %h %h %h",e,ac,t,s,ar,dr,pc,ir);
   end
//

   assign display = get; 
   assign data = dataout;
   assign b = ir[11:0];

   always @ (posedge clk or posedge rst)
   begin
     if (rst) begin
      ien = 1'b0;
      r = 1'b0;
      e = 1'b0;
//      s = 1'b0;
      sc = 4'h0;
      pc = 12'h000;
      ac = 16'h0000;
     en = 0;
     rdwr = 0;
     addr = 0;
     get = 0;
   ir = 0;
	   tr = 0;
	   dr = 0;
	   t = 0;
   pc = 0;
	   ar = 0;
	   addr = 0;
   outr = 0;
	   inpr = 0;
	   get = 0;
	   d = 0;
   i = 0;
	   ien = 0;
	   fgi = 0;
	   fgo = 0;
	   rdwr = 0;
	   en = 0;
   end
   end
   always @ (negedge rst)
   begin
      s = 1'b1;
   end

   always @ (keyboard)
      inpr = keyboard;
   always @ (clk)
   begin
      if(fgo == 0 && en_out)begin
	 fgo = 1'b1;
      end
   end
      
   always @ (inpr)
      if(en_inp && fgi == 0 && (inpr || (inpr == 0)))
         fgi = 1'b1;

   always @ (ack) begin
     if (ack) begin
       if (!rdwr) begin
         if (t[1]) begin
           ir = data;
         end
         if (t[3]) begin
           ar = data;
         end
         if (t[4]) begin
           dr = data;
         end
       end
       en = 1'b0;
     end
   end

   always @ (posedge clk)
   begin
///////////////////////////////* FOR INTERRUPT *///////////////////////////////

      if(ien)
	 if(fgi || fgo)
	    r = 1'b1;

//////////////////////////////////////////////////////////////////////////////

      if(s)
         begin
            sc = sc + 1;
            case (sc)
               4'b0000: t = 16'd32768;
               4'b0001: t = 16'd1;
               4'b0010: t = 16'd2;
               4'b0011: t = 16'd4;
               4'b0100: t = 16'd8;
               4'b0101: t = 16'd16;
               4'b0110: t = 16'd32;
               4'b0111: t = 16'd64;
               4'b1000: t = 16'd128;
               4'b1001: t = 16'd256;
               4'b1010: t = 16'd512;
               4'b1011: t = 16'd1024;
               4'b1100: t = 16'd2048;
               4'b1101: t = 16'd4096;
               4'b1110: t = 16'd8192;
               4'b1111: t = 16'd16384;
            endcase
      end
      if (s == 1'b0) 
      begin
	 $display($time, "  Program Is Terminated.  AC = %h", ac);
	 $finish;
      end

     if (t[0])
     begin
      if (r) begin
         //ar = 12'h000;
         ar = 12'h200;
         tr = pc;
      end else begin
         ar = pc;
      end
     end

     if (t[1])
     begin
      if (r) begin
         pc = 12'h200;
         //pc = 12'h000;
         dataout = tr;
        `WRITE_MEMORY
      end else begin
        `READ_MEMORY
         ir = data;
     //    pc = pc + 1;
      end
     end

     if (t[2])
     begin
      if (r) begin
         ien = 1'b0;
         r = 1'b0;
         pc = pc + 1;
         sc = 4'h0; // instruction retires
      end else begin
         ar = ir[11:0];
         i = ir[15];
         case (ir[14:12]) // decode
            3'b000: d = 8'd1;
            3'b001: d = 8'd2;
            3'b010: d = 8'd4;
            3'b011: d = 8'd8;
            3'b100: d = 8'd16;
            3'b101: d = 8'd32;
            3'b110: d = 8'd64;
            3'b111: d = 8'd128;
         endcase
      end
     end

     if (t[3])
     begin
      if (d[7]) begin
                        
////////////////////////*  input/output instructions  */////////////////////////
                 
         if (i) begin
            if (b[6]) ien = 1'b0;
            if (b[7]) ien = 1'b1;
            if (b[8]) if (fgo) pc = pc + 1;
            if (b[9]) if (fgi) pc = pc + 1;
            if (b[10] && en_out) begin
               outr = ac[7:0];
	       get = outr;
               fgo = 1'b0;
            end
            if (b[11] && en_inp) begin
               ac[7:0] = inpr;
               fgi = 1'b0;
            end
            sc = 4'h0; // instruction retires
            
////////////////////*  REGISTER REFERENCE INSTRUCTIONS  *///////////////////////

         end else begin
            if (b[0]) s = 1'b0;
            if (b[1]) if (!e) pc = pc + 1;
            if (b[2]) if (!ac) pc = pc + 1;
            if (b[3]) if (ac[15]) pc = pc + 1;
            if (b[4]) if (!ac[15]) pc = pc + 1;
            if (b[5]) ac = ac + 1;
            if (b[6]) begin
	       ac15 = ac[15];
               ac = ac << 1;
               ac[0] = e;
               e = ac15;
            end
            if (b[7]) begin
	       ac0 = ac[0];
               ac = ac >> 1;
               ac[15] = e;
               e = ac0;
            end
            if (b[8]) e = ~e;
            if (b[9]) ac = ~ac;
            if (b[10]) e = 1'b0;
            if (b[11]) ac = 16'b0000000000000000;
            sc = 4'h0; // instruction retires
         end
      end else begin

/////////////////*  INDIRECT MEMORY REFERENCE INSTRUCTIONS  *///////////////////

      if (i) begin 
        `READ_MEMORY
         ar = data;
         end
      end
     end

////////////////////////////////////////////////////////////////////////////////
                      /* DIRECT MEMORY REFERENCE INSTRUCTION  */
     if (t[4])
     begin
      if (d[0] || d[1] || d[2] || d[6]) begin
   	`READ_MEMORY
         dr = data;
      end
      if (d[3]) begin 
         dataout = ac;
        `WRITE_MEMORY
         sc = 4'h0; // instruction retires
      end
      if (d[4]) begin
         pc = ar;
         sc = 4'h0; // instruction retires
      end
      if (d[5]) begin
         dataout = pc;
        `WRITE_MEMORY
         ar = ar + 1;
      end
     end

     if (t[5])
     begin
      if (d[0]) begin
         ac = (ac & dr);
         sc = 4'h0; // instruction retires
      end
      if (d[1]) begin
         {e, ac} = ac + dr;
         sc = 4'h0; // instruction retires
      end
      if (d[2]) begin
         ac = dr;
         sc = 4'h0; // instruction retires
      end
      if (d[5]) begin
         pc = ar;
         sc = 4'h0; // instruction retires
      end
      if (d[6]) begin
         dr = dr + 1;
      end
     end

     if (t[6])
     begin
      if (d[6]) begin
         dataout = dr;
        `WRITE_MEMORY
         if (dr == 1'b0) pc = pc + 1;
            sc = 4'h0; // instruction retires
      end
     end
   end

   always @ (sc)
   begin
      if (!rst)
      begin
         if (sc == 4'h0) pc = pc + 1;
      end
   end
endmodule
/*
module DECODER(d, e, a);
        input [2:0] a;
        input e;
        output [7:0] d;
        reg [7:0] d;
        always @(a)
            begin
                if(e)
                    begin
                        d[0] = (~a[2] & ~a[1] & ~a[0]);
                        d[1] = (~a[2] & ~a[1] & a[0]);
                        d[2] = (~a[2] & a[1] & ~a[0]);
                        d[3] = (~a[2] & a[1] & a[0]);
                        d[4] = (a[2] & ~a[1] & ~a[0]);
                        d[5] = (a[2] & ~a[1] & a[0]);
                        d[6] = (a[2] & a[1] & ~a[0]);
                        d[7] = (a[2] & a[1] & a[0]);
                    end
                else
                        d = 8'b00000000;
            end
endmodule
*/
