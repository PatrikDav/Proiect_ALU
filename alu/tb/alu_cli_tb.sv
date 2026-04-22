`timescale 1ns/1ps

module alu_cli_tb;
   import alu_pkg::*;

   localparam int WIDTH = DATA_WIDTH;

   logic signed [WIDTH-1:0]   a;
   logic signed [WIDTH-1:0]   b;
   logic [OP_WIDTH-1:0]       op;
   logic signed [WIDTH-1:0]   result;
   logic signed [WIDTH-1:0]   result_hi;
   logic                      zero;
   logic                      negative;
   logic                      overflow;
   logic signed [2*WIDTH-1:0] result16;

   alu #(.WIDTH(WIDTH)) dut (
      .a         (a),
      .b         (b),
      .op        (op),
      .result    (result),
      .result_hi (result_hi),
      .zero      (zero),
      .negative  (negative),
      .overflow  (overflow)
   );

   assign result16 = {result_hi, result};

   int aval;
   int bval;
   int opval;

   initial begin
      if (!$value$plusargs("a=%d", aval)) begin
         $display("ERROR: missing +a=<value>");
         $finish;
      end
      if (!$value$plusargs("b=%d", bval)) begin
         $display("ERROR: missing +b=<value>");
         $finish;
      end
      if (!$value$plusargs("op=%d", opval)) begin
         $display("ERROR: missing +op=<value>");
         $finish;
      end

      a  = aval[WIDTH-1:0];
      b  = bval[WIDTH-1:0];
      op = opval[OP_WIDTH-1:0];
      #1;

      if (op == OP_MUL)
         $display("result=%0d  result_hex=0x%02h  result16=%0d  result16_hex=0x%04h  Z=%0d N=%0d V=%0d",
                  result, result, result16, result16, zero, negative, overflow);
      else
         $display("result=%0d  result_hex=0x%02h  Z=%0d N=%0d V=%0d",
                  result, result, zero, negative, overflow);
      $finish;
   end

endmodule
