//--------------------------------------------------------------------------
// Design Name: ALU Bitwise Logic Unit
// File Name:   alu_logic.sv
// Description: Combined bitwise logic unit (AND / OR / XOR).
//              sel = 2'b00 -> y = A & B
//              sel = 2'b01 -> y = A | B
//              sel = 2'b10 -> y = A ^ B
//              sel = 2'b11 -> y = 0   (unused; safe default)
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_logic #(parameter int WIDTH = 8) (
   input  logic [1:0]        sel,
   input  logic [WIDTH-1:0]  a,
   input  logic [WIDTH-1:0]  b,
   output logic [WIDTH-1:0]  y
   );

   always_comb begin
      unique case (sel)
        2'b00:   y = a & b;
        2'b01:   y = a | b;
        2'b10:   y = a ^ b;
        default: y = '0;
      endcase
   end

endmodule // alu_logic
