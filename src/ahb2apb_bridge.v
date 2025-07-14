`timescale 1ns / 1ps
// AHB to APB Bridge Module
// Converts AHB-Lite protocol transactions into APB-compliant transactions
module ahb2apb_bridge (
    input hclk,                // AHB Clock
    input hresetn,             // Active-low reset
    input hselapb,             // Slave select signal from AHB
    input hwrite,              // AHB write control
    input [1:0] htrans,        // AHB transfer type
    input [31:0] haddr,        // AHB address bus 
    input [31:0] hwdata,       // AHB write data
    input [31:0] prdata,       // APB read data input
    output reg [31:0] paddr,   // APB address
    output reg [31:0] pwdata,  // APB write data
    output reg psel,           // APB select
    output reg penable,        // APB enable
    output reg pwrite,         // APB write control
    output reg hresp,          // AHB response
    output reg hready,         // AHB ready signal
    output reg [31:0] hrdata   // AHB read data output
);
    
    // State encoding for FSM
    parameter IDLE     = 3'b000;
    parameter READ     = 3'b001;
    parameter RENABLE  = 3'b010;
    parameter W_WAIT    = 3'b011;
    parameter WRITE    = 3'b100;
    parameter WRITE_P  = 3'b101;
    parameter WENABLE  = 3'b110;
    parameter WENABLE_P = 3'b111;

    reg [2:0] present_state, next_state;
    reg [31:0] haddr_temp, hwdata_temp;   // Temporary storage of address and write data
    reg valid, hwrite_temp;               // Valid signal and stored write control

    // Combinational logic to determine if the current transaction is valid AHB access
    always @(*) begin
        valid = (hselapb == 1'b1) && (htrans == 2'b10 || htrans == 2'b11);
    end
    
    // Sequential logic to update present state 
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end
    
    // Combinational logic to control the FSM outputs and next state transitions
    always @(*) begin
        next_state = present_state;
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
        hready = 1'b1;
        hresp = 1'b0;
        paddr = 32'b0;
        pwdata = 32'b0;
        hrdata = 32'b0;

        case (present_state)
            // IDLE: Wait for a valid AHB transaction
            IDLE: begin
                hready = 1'b1;
                if (valid) begin
                    if (hwrite == 1'b0)
                        next_state = READ;
                    else
                        next_state = W_WAIT;
                end
            end
            // READ: Set up APB read transaction with psel=1, then wait for data in next state
            READ: begin
                psel = 1'b1; 
                paddr = haddr;
                pwrite = 1'b0;
                hready = 1'b0;  // Stall AHB until read completes
                next_state = RENABLE;
            end
            // RENABLE: Complete APB read by Asserting penable, capture read data, and decide next
            RENABLE: begin
                penable = 1'b1;
                hrdata = prdata;    // Forward read data to AHB
                hready = 1'b1;      // Indicate AHB transaction complete
                if (valid) begin
                    if (hwrite == 1'b0)
                        next_state = READ;
                    else
                        next_state = W_WAIT;
                end else
                    next_state = IDLE;
            end
            // W_WAIT: Store/latch address and data for write; wait for valid
            W_WAIT: begin
                haddr_temp = haddr;
                hwdata_temp = hwdata;
                hwrite_temp = hwrite;
                if (valid)
                    next_state = WRITE_P;
                else
                    next_state = WRITE;
            end
            // WRITE: Initiate APB write without valid next AHB transfer
            WRITE: begin
                psel = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                hready = 1'b0;
                if (valid)
                    next_state = WENABLE_P;
                else
                    next_state = WENABLE;
            end
            // WRITE_P: Same as WRITE but anticipates next valid pipelined AHB write
            WRITE_P: begin
                psel = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                hready = 1'b0;
                next_state = WENABLE_P;   // Anticipate another valid access
            end
            // WENABLE: Assert penable for APB write, complete transaction
            WENABLE: begin
                penable = 1'b1;   // FInal APB phase
                hready = 1'b1;    // Resume AHB
                if (valid) begin
                    if (hwrite == 1'b0)
                        next_state = READ;
                    else
                        next_state = W_WAIT;
                end else
                    next_state = IDLE;
            end
            // WENABLE_P: Same as WENABLE but optimizes for pipelined writes
            WENABLE_P: begin
                penable = 1'b1;
                hready = 1'b1;
                if (valid) begin
                    if (hwrite == 1'b1)
                        next_state = WRITE_P;
                    else
                        next_state = READ;
                end else if (hwrite == 1'b0)
                    next_state = READ;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule