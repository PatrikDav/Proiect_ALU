//--------------------------------------------------------------------------
// Design Name: ALU Adder/Subtractor
// File Name:   alu_addsub.sv
// Description: Combinational adder/subtractor for signed 2's-complement
//              operands, with signed overflow detection (V flag).
//              sub_sel = 0 -> sum = A + B
//              sub_sel = 1 -> sum = A - B (implemented as A + ~B + 1)
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_addsub #(parameter int WIDTH = 8) (
   input  logic                     sub_sel,
   input  logic signed [WIDTH-1:0]  a,
   input  logic signed [WIDTH-1:0]  b,
   output logic signed [WIDTH-1:0]  sum,
   output logic                     overflow
   );

   logic signed [WIDTH-1:0] b_eff;
   logic signed [WIDTH:0]   sum_ext;

   // For subtraction: invert B and add 1 via the carry-in. This reuses the
   // same adder hardware for both operations (classic two's-complement trick).
   assign b_eff   = sub_sel ? ~b : b;

   // Sign-extend both operands to WIDTH+1 bits before adding so we can
   // observe the true signed result without losing information.
   assign sum_ext = {a[WIDTH-1], a} +
                    {b_eff[WIDTH-1], b_eff} +
                    {{WIDTH{1'b0}}, sub_sel};

   assign sum     = sum_ext[WIDTH-1:0];

   // Signed overflow rule:
   //   ADD overflows iff A and B have the same sign but result differs.
   //   SUB overflows iff A and B have different signs and result sign != A.
   always_comb begin
      if (sub_sel)
        overflow = (a[WIDTH-1] != b[WIDTH-1]) && (sum[WIDTH-1] != a[WIDTH-1]);
      else
        overflow = (a[WIDTH-1] == b[WIDTH-1]) && (sum[WIDTH-1] != a[WIDTH-1]);
   end

endmodule // alu_addsub
