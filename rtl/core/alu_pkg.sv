// ============================================================================
// File Name   : alu_pkg.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-respos
// Date        : 2026-05-22
// Project     : RISC-V 32-bit Processor
// Description : Enum definitions for ALU
//
// License     : MIT
// ============================================================================

package alu_pkg;
    typedef enum logic [3:0] {
        ARITH_ADD,          // adds two 32 bit numbers
        ARITH_SUB,          // subtracts two 32 bit numbers 
        LOGIC_AND,          // logical AND
        LOGIC_OR,           // logical OR
        LOGIC_XOR,          // logical XOR
        SHIFT_L_LOGIC,      // shift left logical
        SHIFT_R_LOGIC,      // shift right logical
        SHIFT_R_ARITH,      // shift right arithmetic
        SET_LESS_U,         // performs less than comparison assuming unsigned integer
        SET_LESS_S          // performs less than comparison assuming signed integer 
    } alu_ops;
endpackage