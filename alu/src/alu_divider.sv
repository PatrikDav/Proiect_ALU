//--------------------------------------------------------------------------
// Design Name: ALU Divider
// File Name:   alu_divider.sv
// Description: Combinational signed divider. Uses the `/` operator (which
//              synthesis tools expand into a multi-cycle divider on FPGAs;
//              here it is treated as a combinational reference model).
//              Flags overflow for the two cases where the mathematical
//              result is undefined or not representable in signed WIDTH:
//                (1) Division by zero.
//                (2) MIN_INT / -1 (e.g. -128/-1 = +128 > +127 for WIDTH=8).
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_divider #(parameter int WIDTH = 8) (
   input  logic signed [WIDTH-1:0]  a,
   input  logic signed [WIDTH-1:0]  b,
   output logic signed [WIDTH-1:0]  quotient,
   output logic                     overflow
   );

   // Special-case detectors
   logic div_by_zero;
   logic min_neg_one;

   assign div_by_zero = (b == '0);

   // MIN_INT for a signed WIDTH-bit number is {1'b1, (WIDTH-1)'b0}
   // and -1 is {WIDTH{1'b1}}. `&b` is high iff b == -1.
   assign min_neg_one = (a == {1'b1, {(WIDTH-1){1'b0}}}) && (&b);

   always_comb begin
      if (div_by_zero) begin
         quotient = '0;     // safe sentinel; V flag signals the issue
         overflow = 1'b1;
      end
      else if (min_neg_one) begin
         quotient = a;      // two's-complement wrap-around of +MIN
         overflow = 1'b1;
      end
      else begin
         quotient = a / b;
         overflow = 1'b0;
      end
   end

endmodule // alu_divider
