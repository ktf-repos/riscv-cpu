// ============================================================================
// File Name   : reg_file.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-repos
// Date        : 2026-05-23
// Project     : RISC-V 32-bit Processor
// Description : 32x32 synchronous register file with two async read ports and
//               one sync write port. x0 hardwired to zero.
//
// License     : MIT
// ============================================================================
 
module reg_file(
    input logic         clock,
 
    // To write to a register, we need its address and the value to write to it
    input logic [31:0]  rd_val,
    input logic [4:0]   rd_addr,
 
    // To read two registers, we need two address, one for each read.
    input logic [4:0]   rs1_addr,
    input logic [4:0]   rs2_addr,
 
    input logic         write_enable,       // Enable write to rd.
    input logic         reset,              // Reset for when system boots up
 
    // Output for the reads
    output logic [31:0] rs1_val,
    output logic [31:0] rs2_val
 
);
    // RISC-V has 32 general purpose registers
    // Recall: x0 is hardwired to 0.
    logic [31:0] registers [32];
 
    always_comb begin
        // Reads are combinational. Reading x0 is hardwired to output 0
        if(rs1_addr != 5'b0)
            rs1_val = registers[rs1_addr];
        else
            rs1_val = 32'b0;
       
        if(rs2_addr != 5'b0)
            rs2_val = registers[rs2_addr];
        else
            rs2_val = 32'b0;
    end
 
    always_ff @(posedge clock) begin
        // Reset will write 0 to all registers
 
        // Otherwise, on the rising edge, write rd_val into rd_addr
        // if write_enable is enabled (i.e., 1)
        if(reset) begin
            for(int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if(write_enable && rd_addr != 5'b0) begin
            registers[rd_addr] <= rd_val;
        end
    end
 
endmodule