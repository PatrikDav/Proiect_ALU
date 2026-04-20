//--------------------------------------------------------------------------
// Design Name: ALU Testbench
// File Name:   alu_tb.sv
// Description: Self-checking testbench for the 8-bit ALU.
//              Exercises each of the 9 operations with directed test
//              vectors (normal cases, boundary cases and overflow cases)
//              and reports PASS/FAIL plus a final tally.
//
//              Each vector also verifies all three status flags: Z, N, V.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_tb;
   import alu_pkg::*;

   localparam int WIDTH = DATA_WIDTH;

   // DUT signals
   logic signed [WIDTH-1:0] a;
   logic signed [WIDTH-1:0] b;
   logic [OP_WIDTH-1:0]     op;
   logic signed [WIDTH-1:0] result;
   logic                    zero;
   logic                    negative;
   logic                    overflow;

   // Scoreboard
   int errors = 0;
   int total  = 0;

   // Device under test
   alu #(.WIDTH(WIDTH)) dut (
      .a        (a),
      .b        (b),
      .op       (op),
      .result   (result),
      .zero     (zero),
      .negative (negative),
      .overflow (overflow)
   );

   // -----------------------------------------------------------------
   // Helper: apply a vector and compare against expected outputs.
   // -----------------------------------------------------------------
   task automatic check(
      input string                   label,
      input logic [OP_WIDTH-1:0]     opcode,
      input logic signed [WIDTH-1:0] ain,
      input logic signed [WIDTH-1:0] bin,
      input logic signed [WIDTH-1:0] exp_result,
      input logic                    exp_z,
      input logic                    exp_n,
      input logic                    exp_v
      );
      a  = ain;
      b  = bin;
      op = opcode;
      #1; // allow combinational logic to settle
      total++;
      if (result === exp_result &&
          zero === exp_z && negative === exp_n && overflow === exp_v) begin
         $display("[PASS] %-18s op=%b  a=%4d b=%4d  => r=%4d z=%b n=%b v=%b",
                  label, opcode, ain, bin, result, zero, negative, overflow);
      end
      else begin
         errors++;
         $display("[FAIL] %-18s op=%b  a=%4d b=%4d  => r=%4d z=%b n=%b v=%b  (exp r=%4d z=%b n=%b v=%b)",
                  label, opcode, ain, bin, result, zero, negative, overflow,
                  exp_result, exp_z, exp_n, exp_v);
      end
   endtask

   // -----------------------------------------------------------------
   // Directed test sequence
   // -----------------------------------------------------------------
   initial begin
      $dumpfile("alu_tb.vcd");
      $dumpvars(0, alu_tb);

      $display("============================================================");
      $display(" 8-bit ALU  -  self-checking testbench");
      $display("============================================================");

      // --- ADD -----------------------------------------------------
      $display("\n--- ADD ---");
      check("ADD basic",       OP_ADD,  8'sd5,    8'sd3,    8'sd8,    0, 0, 0);
      check("ADD zero",        OP_ADD,  8'sd0,    8'sd0,    8'sd0,    1, 0, 0);
      check("ADD negative",    OP_ADD, -8'sd10,   8'sd4,   -8'sd6,    0, 1, 0);
      check("ADD wraps pos",   OP_ADD,  8'sd100,  8'sd50,  -8'sd106,  0, 1, 1); // 150
      check("ADD wraps neg",   OP_ADD, -8'sd100, -8'sd50,   8'sd106,  0, 0, 1); // -150
      check("ADD no-ov mix",   OP_ADD,  8'sd100, -8'sd50,   8'sd50,   0, 0, 0);

      // --- SUB -----------------------------------------------------
      $display("\n--- SUB ---");
      check("SUB basic",       OP_SUB,  8'sd10,   8'sd4,    8'sd6,    0, 0, 0);
      check("SUB zero",        OP_SUB,  8'sd5,    8'sd5,    8'sd0,    1, 0, 0);
      check("SUB negative",    OP_SUB,  8'sd2,    8'sd5,   -8'sd3,    0, 1, 0);
      check("SUB overflow",    OP_SUB, -8'sd128,  8'sd1,    8'sd127,  0, 0, 1); // -128-1
      check("SUB overflow2",   OP_SUB,  8'sd127, -8'sd1,   -8'sd128,  0, 1, 1); // 127+1

      // --- MUL -----------------------------------------------------
      $display("\n--- MUL ---");
      check("MUL basic",       OP_MUL,  8'sd3,    8'sd4,    8'sd12,   0, 0, 0);
      check("MUL zero",        OP_MUL,  8'sd0,    8'sd7,    8'sd0,    1, 0, 0);
      check("MUL negative",    OP_MUL, -8'sd3,    8'sd2,   -8'sd6,    0, 1, 0);
      check("MUL neg*neg",     OP_MUL, -8'sd4,   -8'sd5,    8'sd20,   0, 0, 0);
      check("MUL 16*16 wraps", OP_MUL,  8'sd16,   8'sd16,   8'sd0,    1, 0, 1); // 256
      check("MUL 50*3 wraps",  OP_MUL,  8'sd50,   8'sd3,   -8'sd106,  0, 1, 1); // 150

      // --- DIV -----------------------------------------------------
      $display("\n--- DIV ---");
      check("DIV basic",       OP_DIV,  8'sd20,   8'sd4,    8'sd5,    0, 0, 0);
      check("DIV negative",    OP_DIV, -8'sd20,   8'sd4,   -8'sd5,    0, 1, 0);
      check("DIV truncates",   OP_DIV,  8'sd7,    8'sd2,    8'sd3,    0, 0, 0);
      check("DIV to zero",     OP_DIV,  8'sd3,    8'sd10,   8'sd0,    1, 0, 0);
      check("DIV by zero",     OP_DIV,  8'sd5,    8'sd0,    8'sd0,    1, 0, 1);
      check("DIV MIN/-1",      OP_DIV, -8'sd128, -8'sd1,   -8'sd128,  0, 1, 1);

      // --- AND / OR / XOR ------------------------------------------
      $display("\n--- LOGIC ---");
      check("AND zero",        OP_AND,  8'hF0,    8'h0F,    8'h00,    1, 0, 0);
      check("AND set N",       OP_AND,  8'hFF,    8'hF0,    8'hF0,    0, 1, 0); // -16
      check("OR  all-ones",    OP_OR,   8'hF0,    8'h0F,    8'hFF,    0, 1, 0); // -1
      check("OR  zero",        OP_OR,   8'h00,    8'h00,    8'h00,    1, 0, 0);
      check("XOR",             OP_XOR,  8'hAA,    8'hFF,    8'h55,    0, 0, 0);
      check("XOR self = 0",    OP_XOR,  8'h5A,    8'h5A,    8'h00,    1, 0, 0);

      // --- Shifts --------------------------------------------------
      $display("\n--- SHIFTS ---");
      check("SLL by 0",        OP_SLL,  8'h07,    8'sd0,    8'h07,    0, 0, 0);
      check("SLL by 2",        OP_SLL,  8'h03,    8'sd2,    8'h0C,    0, 0, 0);
      check("SLL drops MSB",   OP_SLL,  8'h81,    8'sd1,    8'h02,    0, 0, 0);
      check("SLL to zero",     OP_SLL,  8'h80,    8'sd1,    8'h00,    1, 0, 0);
      check("SLL by 7",        OP_SLL,  8'h01,    8'sd7,    8'h80,    0, 1, 0); // -128
      check("SRA positive",    OP_SRA,  8'sd32,   8'sd2,    8'sd8,    0, 0, 0);
      check("SRA negative",    OP_SRA, -8'sd32,   8'sd2,   -8'sd8,    0, 1, 0);
      check("SRA -1 keeps -1", OP_SRA, -8'sd1,    8'sd3,   -8'sd1,    0, 1, 0);
      check("SRA to zero",     OP_SRA,  8'sd4,    8'sd4,    8'sd0,    1, 0, 0);

      // ------------------- Final report ----------------------------
      $display("\n============================================================");
      $display(" Total tests: %0d", total);
      $display(" Failures   : %0d", errors);
      $display("============================================================");
      if (errors == 0) $display(" >>> ALL TESTS PASSED <<<");
      else             $display(" >>> %0d TESTS FAILED <<<", errors);
      $display("============================================================\n");

      $finish;
   end

endmodule // alu_tb
