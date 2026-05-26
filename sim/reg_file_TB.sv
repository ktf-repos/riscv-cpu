// ============================================================================
// File Name   : reg_file_TB.sv
// Author      : Kevin Toledo Fernandez / GitHub: ktf-repos
// Date        : 2026-05-25
// Project     : RISC-V 32-bit Processor
// Description : Testbench for the Register File
// ============================================================================

module reg_file_TB();
    logic         clock;
 
    logic [31:0]  rd_val;
    logic [4:0]   rd_addr;
 
    logic [4:0]   rs1_addr;
    logic [4:0]   rs2_addr;
 
    logic         write_enable;     
    logic         reset;     
    
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    
    // Counters for the final score
    int tests_passed = 0;
    int tests_total = 0;

    // Initializing the clock
    initial clock = 0;
    always #5 clock = ~clock;

    reg_file file (
        .clock              (clock),
        .rd_val             (rd_val),
        .rd_addr            (rd_addr),
        .rs1_addr           (rs1_addr),
        .rs2_addr           (rs2_addr),
        .write_enable       (write_enable),
        .reset              (reset),
        .rs1_val            (rs1_val),
        .rs2_val            (rs2_val)
    );

    task automatic run_and_check (
        input string        label,
        input logic [31:0]  expected_result_1,
        input logic [31:0]  expected_result_2,
 
        input logic [31:0]  rd_vl,
        input logic [4:0]   rd_adr,
    
        input logic [4:0]   rs1_adr,
        input logic [4:0]   rs2_adr,
    
        input logic         wrt_en,     
        input logic         rst
    );
        // Drive the test inputs
        rd_val = rd_vl;
        rd_addr = rd_adr;

        rs1_addr = rs1_adr;
        rs2_addr = rs2_adr;

        write_enable = wrt_en;
        reset = rst; 
        
        tests_total++;

        // Wait for the next clock cycle to evaluate 
        #10;

        // Evaluate whether the test passed or failed
        if(rs1_val == expected_result_1 && rs2_val == expected_result_2) begin
            tests_passed++;
            $display("\033[0;32m[PASS]\033[0m %s", label);
        end else begin 
            $display("\033[0;31m[FAIL]\033[0m %s", label);
            $display("       Expected: rs1 = %0d, rs2 = %0d", expected_result_1, expected_result_2);
            $display("       Got     : rs1 = %0d, rs2 = %0d", rs1_val, rs2_val);
        end
    endtask

    initial begin
        $display("\n========================================");
        $display("      STARTING REG FILE TESTBENCH       ");
        $display("========================================\n");

        // --------------------------------------------------------------------
        // Write 32'd5 to all of the registers and check
        // --------------------------------------------------------------------

        $display("Test: Write 32'd5 to all of the registers and check.");

        write_enable = 1;
        rd_val = 5;
        reset = 0;
        
        for (int i = 0; i < 32; i++) begin
            rd_addr = i;
            #10; // wait 1 clock cycle for each save
        end

        run_and_check("Testing Reg 0 and Reg 1", 0, 5, 0, 0, 0, 1, 0, 0);

        for(int i = 2; i < 31; i += 2) begin
            run_and_check($sformatf("Testing Reg %0d and Reg %0d", i, i+1), 5, 5, 0, 0, i, i+1, 0, 0);
        end

        // --------------------------------------------------------------------
        // Test Write Enable = 0
        // --------------------------------------------------------------------
        $display("\nTest: Write Enable = 0");
        // Try to write 99 to Reg 1, but keep we=0
        run_and_check("Write Enable OFF prevents save", 5, 5, 99, 1, 1, 2, 0, 0);

        // --------------------------------------------------------------------
        // Test simulateneously read and write
        // --------------------------------------------------------------------
        
        $display("\nTest: Simultaneous Read/Write");
        // Write 100 to Reg 5, and immediately read Reg 5 on both ports
        write_enable = 1;
        rd_val = 100;
        rd_addr = 5;
        rs1_addr = 5;
        rs2_addr = 5;

        #1;

        if (rs1_val === 100 && rs2_val === 100) begin
            $display("\033[0;32m[PASS]\033[0m Write-through logic works!");
        end else begin
            $display("\033[0;31m[FAIL]\033[0m No write-through detected.");
            $display("       Expected instant update: rs1 = 100, rs2 = 100");
            $display("       Got old vault data   : rs1 = %0d, rs2 = %0d", rs1_val, rs2_val);
        end

        // --------------------------------------------------------------------
        // Test: Master Reset
        // --------------------------------------------------------------------
        $display("\nTest: Master Reset");
        // Trigger Reset
        write_enable = 0;
        reset = 1;
        #10;

        for(int i = 2; i < 31; i += 2) begin
            run_and_check($sformatf("Testing Reg %0d and Reg %0d", i, i+1), 0, 0, 0, 0, i, i+1, 0, 0);
        end

        $display("\nTime: %0d", $time);

        $display("\n========================================");
        $display("      FINISHED REG FILE TESTBENCH       ");
        $display("========================================\n");

        $finish;
    end
endmodule