//--------------------------------------------------------------------------
// Design Name: ALU Multiplier
// File Name:   alu_multiplier.sv
// Description: Combinational signed multiplier. Returns the low WIDTH bits
//              of the full 2*WIDTH-bit product and flags overflow whenever
//              the mathematical result does not fit in signed WIDTH bits.
//
//              Uses the `*` operator. Synthesis tools map this to a
//              parallel hardware multiplier. For a sequential textbook
//              implementation of the same function, see ../../booth/src.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_multiplier #(parameter int WIDTH = 8) (
   input  logic signed [WIDTH-1:0]     a,
   input  logic signed [WIDTH-1:0]     b,
   output logic signed [WIDTH-1:0]     product,
   output logic                        overflow
   );

   // Full 2*WIDTH-bit signed product. Both operands are signed so SV's
   // `*` does a signed multiplication.
   logic signed [2*WIDTH-1:0] full;

   // The upper (WIDTH+1) bits: bits [2*WIDTH-1 : WIDTH-1]. We include bit
   // WIDTH-1 because for a valid signed truncation those bits must all
   // equal the sign bit of the low half.
   logic                      upper_all_zero;
   logic                      upper_all_one;

   assign full           = a * b;
   assign product        = full[WIDTH-1:0];

   assign upper_all_zero = (full[2*WIDTH-1:WIDTH-1] == '0);
   assign upper_all_one  = (&full[2*WIDTH-1:WIDTH-1]);

   // Overflow iff the upper portion is neither all-zeros (for a non-negative
   // result) nor all-ones (for a negative result); i.e., the truncation lost
   // information.
   assign overflow       = ~(upper_all_zero | upper_all_one);

endmodule // alu_multiplier
