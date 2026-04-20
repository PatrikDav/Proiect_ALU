//--------------------------------------------------------------------------
// Design Name: ALU Barrel Shifter
// File Name:   alu_shifter.sv
// Description: Combinational barrel shifter supporting logical left shift
//              (SLL) and arithmetic right shift (SRA).
//              dir = 0 -> y = A << shamt  (logical left, zero-fill)
//              dir = 1 -> y = A >>> shamt (arithmetic right, sign-fill)
//
//              The shift amount is taken from the low $clog2(WIDTH) bits
//              of the second operand; shifting by more than WIDTH-1 is
//              not meaningful for a WIDTH-bit value.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_shifter #(parameter int WIDTH = 8) (
   input  logic                     dir,
   input  logic signed [WIDTH-1:0]  a,
   input  logic [WIDTH-1:0]         shamt_in,
   output logic signed [WIDTH-1:0]  y
   );

   localparam int SHAMT_W = $clog2(WIDTH);

   logic [SHAMT_W-1:0] shamt;
   assign shamt = shamt_in[SHAMT_W-1:0];

   always_comb begin
      unique case (dir)
        1'b0:    y = a <<  shamt;   // logical left
        1'b1:    y = a >>> shamt;   // arithmetic right (preserves sign)
        default: y = '0;
      endcase
   end

endmodule // alu_shifter
