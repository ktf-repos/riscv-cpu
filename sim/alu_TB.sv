// ============================================================================
// File Name   : alu_TB.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-respos
// Date        : 2026-05-22
// Project     : RISC-V 32-bit Processor
// Description : Testbench for the 10 main ALU operations 
//
// License     : MIT
// ============================================================================

module alu_TB();
    import alu_pkg::*;

    logic [31:0] first_num;
    logic [31:0] second_num;
    logic [3:0]  op;
    logic [31:0] res;
    logic zero;

    ALU alu_dut (
        .first_operand      (first_num),
        .second_operand     (second_num),
        .operation          (op),
        .result             (res),
        .zero_flag          (zero)
    );

    initial begin
        
        $display("=== ARITHMETIC OPERATIONS ===");
        // Case 1: (10 + 15 = 25)
        first_num   = 32'd10;
        second_num  = 32'd15;
        op          = ARITH_ADD;
        #10;
        $display("[ADD] %0d + %0d = %0d. Zero = %0b", first_num, second_num, res, zero);

        // Case 2: (15 + (-15) = 0)
        first_num   = 32'd15;
        second_num  = -32'd15; // SystemVerilog handles the 2s complement negative automatically
        op          = ARITH_ADD;
        #10;
        $display("[ADD] %0d + %0d = %0d. Zero = %0b", $signed(first_num), $signed(second_num), $signed(res), zero);

        // Case 3: (20 - 5 = 15)
        first_num   = 32'd20;
        second_num  = 32'd5;
        op          = ARITH_SUB;
        #10;
        $display("[SUB] %0d - %0d = %0d. Zero = %0b", first_num, second_num, res, zero);

        // Case 4: (5 - 20 = -15)
        first_num   = 32'd5;
        second_num  = 32'd20;
        op          = ARITH_SUB;
        #10;

        $display("[SUB] %0d - %0d = %0d. Zero = %0b", first_num, second_num, $signed(res), zero);

        $display("\n=== LOGICAL OPERATIONS ===");

        // Case 5: Bitwise AND
        first_num   = 32'hFFFF_0000;
        second_num  = 32'hFF00_FF00;
        op          = LOGIC_AND;
        #10;
        $display("[AND] %0h & %0h = %0h. Zero = %0b", first_num, second_num, res, zero);

        // Case 6: Bitwise OR
        first_num   = 32'hAAAA_0000;
        second_num  = 32'h0000_5555;
        op          = LOGIC_OR;
        #10;
        $display("[ OR] %0h | %0h = %0h. Zero = %0b", first_num, second_num, res, zero);

        // Case 7: Bitwise XOR (Self-XOR should equal 0)
        first_num   = 32'h1234_5678;
        second_num  = 32'h1234_5678;
        op          = LOGIC_XOR;
        #10;
        $display("[XOR] %0h ^ %0h = %0h. Zero = %0b", first_num, second_num, res, zero);


        $display("\n=== SHIFT OPERATIONS ===");

        // Case 8: Logical Shift Left 
        first_num   = 32'd1;
        second_num  = 32'd4;
        op          = SHIFT_L_LOGIC;
        #10;
        $display("[SLL] %0d << %0d = %0d. Zero = %0b", first_num, second_num, res, zero);

        // Case 9: Logical Shift Right 
        first_num   = 32'hF000_0000; // Top bits are 1s
        second_num  = 32'd4;
        op          = SHIFT_R_LOGIC;
        #10;
        $display("[SRL] %0h >> %0d = %0h. Zero = %0b", first_num, second_num, res, zero);

        // Case 10: Arithmetic Shift Right 
        first_num   = 32'hF000_0000; // Negative number
        second_num  = 32'd4;
        op          = SHIFT_R_ARITH;
        #10;

        $display("[SRA] %0h >>> %0d = %0h. Zero = %0b", first_num, second_num, res, zero);


        $display("\n=== COMPARISON OPERATIONS ===");

        // Case 11: Set Less Than Signed (-5 < 10)
        first_num   = -32'd5; 
        second_num  = 32'd10;
        op          = SET_LESS_S;
        #10;

        $display("[SLT] %0d < %0d = %0d. Zero = %0b", $signed(first_num), second_num, res, zero);

        // Case 12: Set Less Than Unsigned (-5 < 10)
        first_num   = -32'd5; 
        second_num  = 32'd10;
        op          = SET_LESS_U;
        #10;
    end

endmodule