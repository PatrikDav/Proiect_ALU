//--------------------------------------------------------------------------
// Design Name: ALU Opcode / Parameter Package
// File Name:   alu_pkg.sv
// Description: Shared constants (data width, opcode encoding) for the 8-bit
//              ALU and its testbench. Kept in a SystemVerilog package so a
//              single source of truth is used everywhere.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

package alu_pkg;

   // Width of the data path (operands and result).
   localparam int DATA_WIDTH = 8;

   // Width of the opcode. 4 bits gives us room for 16 operations; we use 9.
   localparam int OP_WIDTH   = 4;

   // Opcode encoding. Unused codes (4'b1001..4'b1111) map to zero via
   // the default case in the ALU result mux.
   localparam logic [OP_WIDTH-1:0] OP_ADD = 4'b0000; // A + B      (signed)
   localparam logic [OP_WIDTH-1:0] OP_SUB = 4'b0001; // A - B      (signed)
   localparam logic [OP_WIDTH-1:0] OP_MUL = 4'b0010; // A * B      (low WIDTH bits)
   localparam logic [OP_WIDTH-1:0] OP_DIV = 4'b0011; // A / B      (signed truncating)
   localparam logic [OP_WIDTH-1:0] OP_AND = 4'b0100; // A & B      (bitwise)
   localparam logic [OP_WIDTH-1:0] OP_OR  = 4'b0101; // A | B      (bitwise)
   localparam logic [OP_WIDTH-1:0] OP_XOR = 4'b0110; // A ^ B      (bitwise)
   localparam logic [OP_WIDTH-1:0] OP_SLL = 4'b0111; // A << B[2:0](logical left)
   localparam logic [OP_WIDTH-1:0] OP_SRA = 4'b1000; // A >>> B[2:0](arithmetic right)

endpackage // alu_pkg
