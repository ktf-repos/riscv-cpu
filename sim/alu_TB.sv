// ============================================================================
// File Name   : alu_TB.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-repos
// Date        : 2026-05-22
// Project     : RISC-V 32-bit Processor
// Description : Testbench for the 10 main ALU operations with Pass/Fail counting
// ============================================================================
 
module alu_TB();
    import alu_pkg::*;
 
    logic [31:0] first_num;
    logic [31:0] second_num;
    logic [3:0]  op;
    logic [31:0] res;
    logic        zero;
 
    // Counters for the final score
    int tests_passed = 0;
    int tests_total = 0;
 
    ALU alu_dut (
        .first_operand      (first_num),
        .second_operand     (second_num),
        .operation          (op),
        .result             (res),
        .zero_flag          (zero)
    );
 
    // Refactored check task to track passes and failures
    task automatic check (
        input string        label,
        input logic [31:0]  expected_res,
        input logic         expected_zero
    );
        tests_total++;
        if (res === expected_res && zero === expected_zero) begin
            tests_passed++;
            $display("[PASS] %s", label);
        end else begin
            $display("[FAIL] %s", label);
            $display("       Expected: Res = %0h, Zero = %0b", expected_res, expected_zero);
            $display("       Got     : Res = %0h, Zero = %0b", res, zero);
        end
    endtask
 
    // Helper task to cleanly assign inputs, wait, and check in one line
    task automatic run_test (
        input string        label,
        input logic [3:0]   test_op,
        input logic [31:0]  a,
        input logic [31:0]  b,
        input logic [31:0]  exp_res,
        input logic         exp_zero
    );
        first_num = a;
        second_num = b;
        op = test_op;
        #10;
        check(label, exp_res, exp_zero);
    endtask
 
    initial begin
        $display("\n========================================");
        $display("   STARTING ALU TESTBENCH (50 CASES)    ");
        $display("========================================\n");
 
        // --------------------------------------------------------------------
        // ARITH_ADD (Addition)
        // --------------------------------------------------------------------
        run_test("ADD 1: Basic Positive",  ARITH_ADD, 32'd0,  32'd10, 32'd10, 1'b0);
        run_test("ADD 2: Basic Positive 2",ARITH_ADD, 32'd15, 32'd25, 32'd40, 1'b0);
        run_test("ADD 3: Negative + Pos",  ARITH_ADD, -32'd1, 32'd1,  32'd0,  1'b1);
        run_test("ADD 4: Large Numbers",   ARITH_ADD, 32'h7FFFFFFF, 32'd1, 32'h80000000, 1'b0);
        run_test("ADD 5: Neg + Neg",       ARITH_ADD, -32'd5, -32'd5, -32'd10, 1'b0);
 
        // --------------------------------------------------------------------
        // ARITH_SUB (Subtraction)
        // --------------------------------------------------------------------
        run_test("SUB 1: Basic Positive",  ARITH_SUB, 32'd10, 32'd5,  32'd5,  1'b0);
        run_test("SUB 2: Result is Zero",  ARITH_SUB, 32'd10, 32'd10, 32'd0,  1'b1);
        run_test("SUB 3: Neg - Neg",       ARITH_SUB, -32'd10,-32'd5, -32'd5, 1'b0);
        run_test("SUB 4: Zero - One",      ARITH_SUB, 32'd0,  32'd1,  32'hFFFFFFFF, 1'b0);
        run_test("SUB 5: Pos - Larger Pos",ARITH_SUB, 32'd100,32'd200,-32'd100, 1'b0);
 
        // --------------------------------------------------------------------
        // LOGIC_AND (Bitwise AND)
        // --------------------------------------------------------------------
        run_test("AND 1: All 1s & All 0s", LOGIC_AND, 32'hFFFFFFFF, 32'h00000000, 32'h00000000, 1'b1);
        run_test("AND 2: Alternating Bits",LOGIC_AND, 32'hAAAAAAAA, 32'h55555555, 32'h00000000, 1'b1);
        run_test("AND 3: Masking",         LOGIC_AND, 32'hFFFFFFFF, 32'h12345678, 32'h12345678, 1'b0);
        run_test("AND 4: Half and Half",   LOGIC_AND, 32'h0F0F0F0F, 32'hF0F0F0F0, 32'h00000000, 1'b1);
        run_test("AND 5: Identical Vals",  LOGIC_AND, 32'h12345678, 32'h12345678, 32'h12345678, 1'b0);
 
        // --------------------------------------------------------------------
        // LOGIC_OR (Bitwise OR)
        // --------------------------------------------------------------------
        run_test("OR 1: Alternating Bits", LOGIC_OR,  32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, 1'b0);
        run_test("OR 2: All 0s",           LOGIC_OR,  32'h00000000, 32'h00000000, 32'h00000000, 1'b1);
        run_test("OR 3: Number | 0",       LOGIC_OR,  32'h12345678, 32'h00000000, 32'h12345678, 1'b0);
        run_test("OR 4: Half and Half",    LOGIC_OR,  32'h0000FFFF, 32'hFFFF0000, 32'hFFFFFFFF, 1'b0);
        run_test("OR 5: Overlapping Bits", LOGIC_OR,  32'h11111111, 32'h22222222, 32'h33333333, 1'b0);
 
        // --------------------------------------------------------------------
        // LOGIC_XOR (Bitwise XOR)
        // --------------------------------------------------------------------
        run_test("XOR 1: Identical Vals",  LOGIC_XOR, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'h00000000, 1'b1);
        run_test("XOR 2: Alternating",     LOGIC_XOR, 32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, 1'b0);
        run_test("XOR 3: Number ^ 0",      LOGIC_XOR, 32'h12345678, 32'h00000000, 32'h12345678, 1'b0);
        run_test("XOR 4: Half and Half",   LOGIC_XOR, 32'h0000FFFF, 32'hFFFF0000, 32'hFFFFFFFF, 1'b0);
        run_test("XOR 5: Same Number",     LOGIC_XOR, 32'h12345678, 32'h12345678, 32'h00000000, 1'b1);
 
        // --------------------------------------------------------------------
        // SHIFT_L_LOGIC (Shift Left Logical)
        // --------------------------------------------------------------------
        run_test("SLL 1: Shift by 0",      SHIFT_L_LOGIC, 32'd1, 32'd0,  32'd1, 1'b0);
        run_test("SLL 2: Shift by 1",      SHIFT_L_LOGIC, 32'd1, 32'd1,  32'd2, 1'b0);
        run_test("SLL 3: Shift by 31",     SHIFT_L_LOGIC, 32'd1, 32'd31, 32'h80000000, 1'b0);
        run_test("SLL 4: Shift All 1s",    SHIFT_L_LOGIC, 32'hFFFFFFFF, 32'd4, 32'hFFFFFFF0, 1'b0);
        run_test("SLL 5: Shift out",       SHIFT_L_LOGIC, 32'h80000000, 32'd1, 32'h00000000, 1'b1);
 
        // --------------------------------------------------------------------
        // SHIFT_R_LOGIC (Shift Right Logical)
        // --------------------------------------------------------------------
        run_test("SRL 1: Shift Sign Bit",  SHIFT_R_LOGIC, 32'h80000000, 32'd31, 32'd1, 1'b0);
        run_test("SRL 2: Shift All 1s",    SHIFT_R_LOGIC, 32'hFFFFFFFF, 32'd4,  32'h0FFFFFFF, 1'b0);
        run_test("SRL 3: Half Shift",      SHIFT_R_LOGIC, 32'hFFFF0000, 32'd16, 32'h0000FFFF, 1'b0);
        run_test("SRL 4: Basic Math",      SHIFT_R_LOGIC, 32'd10, 32'd1, 32'd5, 1'b0);
        run_test("SRL 5: Shift to Zero",   SHIFT_R_LOGIC, 32'h0000000F, 32'd4,  32'h00000000, 1'b1);
 
        // --------------------------------------------------------------------
        // SHIFT_R_ARITH (Shift Right Arithmetic - maintains sign)
        // --------------------------------------------------------------------
        run_test("SRA 1: Propagate Neg",   SHIFT_R_ARITH, 32'h80000000, 32'd31, 32'hFFFFFFFF, 1'b0);
        run_test("SRA 2: All 1s stays 1s", SHIFT_R_ARITH, 32'hFFFFFFFF, 32'd16, 32'hFFFFFFFF, 1'b0);
        run_test("SRA 3: Positive Num",    SHIFT_R_ARITH, 32'h0000FFFF, 32'd4,  32'h00000FFF, 1'b0);
        run_test("SRA 4: Math / 2",        SHIFT_R_ARITH, -32'd4, 32'd1, -32'd2, 1'b0);
        run_test("SRA 5: One Shift",       SHIFT_R_ARITH, 32'h80000000, 32'd1,  32'hC0000000, 1'b0);
 
        // --------------------------------------------------------------------
        // SET_LESS_S (Set Less Than - Signed)
        // --------------------------------------------------------------------
        run_test("SLT 1: Pos < Pos",       SET_LESS_S,  32'd10, 32'd20, 32'd1, 1'b0);
        run_test("SLT 2: Pos > Pos",       SET_LESS_S,  32'd20, 32'd10, 32'd0, 1'b1);
        run_test("SLT 3: Neg < Neg",       SET_LESS_S, -32'd5, -32'd1,  32'd1, 1'b0);
        run_test("SLT 4: Neg > Neg",       SET_LESS_S, -32'd1, -32'd5,  32'd0, 1'b1);
        run_test("SLT 5: Neg < Pos",       SET_LESS_S, -32'd100,32'd50, 32'd1, 1'b0);
 
        // --------------------------------------------------------------------
        // SET_LESS_U (Set Less Than - Unsigned)
        // --------------------------------------------------------------------
        run_test("SLTU 1: Pos < Pos",      SET_LESS_U, 32'd10, 32'd20, 32'd1, 1'b0);
        run_test("SLTU 2: MaxUnsigned",    SET_LESS_U, 32'hFFFFFFFF, 32'd50, 32'd0, 1'b1); 
        run_test("SLTU 3: Small < Max",    SET_LESS_U, 32'd50, 32'hFFFFFFFF, 32'd1, 1'b0);
        run_test("SLTU 4: 0 < 1",          SET_LESS_U, 32'd0,  32'd1,  32'd1, 1'b0);
        run_test("SLTU 5: 0 < 0",          SET_LESS_U, 32'd0,  32'd0,  32'd0, 1'b1);
 
        // --------------------------------------------------------------------
        // Final Score Output
        // --------------------------------------------------------------------
        $display("\n========================================");
        $display("   TESTBENCH COMPLETE");
        $display("   Passed: %0d / %0d", tests_passed, tests_total);
        if (tests_passed == tests_total) begin
            // Prints in green if everything passes
            $display("   STATUS: \033[0;32m[SUCCESS]\033[0m");
        end else begin
            // Prints in red if there is a failure
            $display("   STATUS: \033[0;31m[FAILED]\033[0m Check logs above.");
        end
        $display("   Time: %0d", $time);
        $display("========================================");
 
        $finish;
    end
 
endmodule