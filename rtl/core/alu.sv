// ============================================================================
// File Name   : alu.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-respos
// Date        : 2026-05-22
// Project     : RISC-V 32-bit Processor
// Description : Arithmetic Logic Unit. Implements RISC-V RV32I second_operandase integer 
//               instructions. Combinational logic only.
//             : Supported operations:
//             : ARIRTHMETIC -- add (0), subtract (1)
//
// License     : MIT
// ============================================================================

module ALU (
    input logic [31:0] first_operand, 
    input logic [31:0] second_operand, 
    input logic [3:0] operation,

    output logic [31:0] result,
    output logic zero_flag
);
    import alu_pkg::*;
    
    logic [4:0] shamt;
    assign shamt = second_operand[4:0];

    always_comb begin 
        case (operation)
            ARITH_ADD:      result = first_operand + second_operand;
            ARITH_SUB:      result = first_operand - second_operand;
            LOGIC_AND:      result = first_operand & second_operand;
            LOGIC_OR:       result = first_operand | second_operand;
            LOGIC_XOR:      result = first_operand ^ second_operand;
            SHIFT_L_LOGIC:  result = first_operand << shamt; 
            SHIFT_R_LOGIC:  result = first_operand >> shamt;
            SHIFT_R_ARITH:  result = $signed(first_operand) >>> shamt;
            SET_LESS_U:     result = first_operand < second_operand;
            SET_LESS_S:     result = $signed(first_operand) < $signed(second_operand);
            default:        result = 0;
        endcase

        zero_flag = (result == 32'b0);
    end

endmodule