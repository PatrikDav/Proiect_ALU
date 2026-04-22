//--------------------------------------------------------------------------
// Design Name: 8-bit Arithmetic Logic Unit (ALU)
// File Name:   alu.sv
// Description: Top-level combinational ALU. Instantiates one functional
//              sub-unit for each operation class (addsub, mul, div, shift,
//              logic) and muxes the selected result onto the output.
//
//              Supported operations (selected via the 4-bit `op` input):
//                 ADD, SUB, MUL, DIV, AND, OR, XOR, SLL (<<), SRA (>>>).
//
//              Operands are interpreted as signed 2's-complement values.
//              Status flags:
//                 Z (zero)      : result == 0
//                 N (negative)  : result[WIDTH-1]  (MSB = sign bit)
//                 V (overflow)  : signed arithmetic overflow for
//                                 ADD/SUB/MUL/DIV; 0 for logic/shift ops.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu
   import alu_pkg::*;
   #(parameter int WIDTH = DATA_WIDTH)
   (
    input  logic signed [WIDTH-1:0]    a,
    input  logic signed [WIDTH-1:0]    b,
    input  logic [OP_WIDTH-1:0]        op,
    output logic signed [WIDTH-1:0]    result,
    output logic signed [WIDTH-1:0]    result_hi,   // MUL: high 8 bits of product; 0 otherwise
    output logic                       zero,
    output logic                       negative,
    output logic                       overflow
    );

   //------------------------------------------------------------------
   // Per-unit outputs
   //------------------------------------------------------------------
   logic signed [WIDTH-1:0]   addsub_y, mul_y, div_y, shift_y;
   logic        [WIDTH-1:0]   logic_y;
   logic signed [2*WIDTH-1:0] mul_full;
   logic                      addsub_ov, mul_ov, div_ov;

   //------------------------------------------------------------------
   // Per-unit control signals derived from the opcode
   //------------------------------------------------------------------
   logic        sub_sel;   // 0 = add, 1 = subtract
   logic        shift_dir; // 0 = SLL,  1 = SRA
   logic [1:0]  logic_sel; // 00 AND / 01 OR / 10 XOR

   assign sub_sel   = (op == OP_SUB);
   assign shift_dir = (op == OP_SRA);

   always_comb begin
      unique case (op)
        OP_AND:  logic_sel = 2'b00;
        OP_OR:   logic_sel = 2'b01;
        OP_XOR:  logic_sel = 2'b10;
        default: logic_sel = 2'b11;   // unused path
      endcase
   end

   //------------------------------------------------------------------
   // Functional sub-units (all combinational)
   //------------------------------------------------------------------
   alu_addsub     #(.WIDTH(WIDTH)) u_addsub (
      .sub_sel (sub_sel),
      .a       (a),
      .b       (b),
      .sum     (addsub_y),
      .overflow(addsub_ov)
   );

   alu_multiplier #(.WIDTH(WIDTH)) u_mul (
      .a           (a),
      .b           (b),
      .product     (mul_y),
      .product_full(mul_full),
      .overflow    (mul_ov)
   );

   alu_divider    #(.WIDTH(WIDTH)) u_div (
      .a       (a),
      .b       (b),
      .quotient(div_y),
      .overflow(div_ov)
   );

   alu_shifter    #(.WIDTH(WIDTH)) u_shift (
      .dir      (shift_dir),
      .a        (a),
      .shamt_in (b),
      .y        (shift_y)
   );

   alu_logic      #(.WIDTH(WIDTH)) u_logic (
      .sel(logic_sel),
      .a  (a),
      .b  (b),
      .y  (logic_y)
   );

   //------------------------------------------------------------------
   // Output mux: pick the result and overflow of the selected unit.
   //------------------------------------------------------------------
   always_comb begin
      // Safe defaults (prevent latches on unused opcodes)
      result    = '0;
      result_hi = '0;
      overflow  = 1'b0;

      unique case (op)
        OP_ADD: begin result = addsub_y; overflow = addsub_ov; end
        OP_SUB: begin result = addsub_y; overflow = addsub_ov; end
        OP_MUL: begin result = mul_y; result_hi = mul_full[2*WIDTH-1:WIDTH]; overflow = mul_ov; end
        OP_DIV: begin result = div_y;    overflow = div_ov;    end
        OP_AND,
        OP_OR,
        OP_XOR: begin result = logic_y;  overflow = 1'b0;      end
        OP_SLL,
        OP_SRA: begin result = shift_y;  overflow = 1'b0;      end
        default: begin result = '0;      overflow = 1'b0;      end
      endcase
   end

   //------------------------------------------------------------------
   // Status flags
   //------------------------------------------------------------------
   assign zero     = (result == '0);
   assign negative = result[WIDTH-1];

endmodule // alu
