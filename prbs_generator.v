// ============================================================================
// THIS FILE IS AI GENERATED
// ============================================================================

module prbs_generator (
    input wire clk,                 // 50 MHz system clock
    input wire reset,               // Active-high reset
    input wire [1:0] bit_rate_sel,  // Bit rate selection:
                                    //   00 = 1 kbps
                                    //   01 = 10 kbps
                                    //   10 = 100 kbps
                                    //   11 = 1 kbps (default)
    output reg data_out,            // Serial bit stream output
    output reg bit_clock            // Bit clock output (for monitoring)
);

// ============================================================================
// Bit Rate Clock Divider
// ============================================================================
// Generates enable pulse at selected bit rate

reg [15:0] bit_clock_counter;
reg [15:0] bit_clock_period;
reg bit_clock_enable;

// Select bit rate period based on bit_rate_sel
always @(*) begin
    case (bit_rate_sel)
        2'b00: bit_clock_period = 16'd50000;  // 1 kbps: 50MHz/50000 = 1000 Hz
        2'b01: bit_clock_period = 16'd5000;   // 10 kbps: 50MHz/5000 = 10000 Hz
        2'b10: bit_clock_period = 16'd500;    // 100 kbps: 50MHz/500 = 100000 Hz
        2'b11: bit_clock_period = 16'd50000;  // Default: 1 kbps
        default: bit_clock_period = 16'd50000;
    endcase
end

// Bit clock counter and enable generator
always @(posedge clk or posedge reset) begin
    if (reset) begin
        bit_clock_counter <= 16'd0;
        bit_clock_enable <= 1'b0;
        bit_clock <= 1'b0;
    end else begin
        if (bit_clock_counter >= bit_clock_period - 1) begin
            bit_clock_counter <= 16'd0;
            bit_clock_enable <= 1'b1;
            bit_clock <= ~bit_clock;  // Toggle for monitoring
        end else begin
            bit_clock_counter <= bit_clock_counter + 1;
            bit_clock_enable <= 1'b0;
        end
    end
end

// ============================================================================
// LFSR (Linear Feedback Shift Register) - PRBS Generator
// ============================================================================
// Polynomial: x^15 + x^14 + 1
// Taps at positions 15 and 14 (feedback from bits [14] and [13] in 0-indexed)
// Generates maximal length sequence: 2^15 - 1 = 32,767 bits

reg [14:0] lfsr;  // 15-bit shift register

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Seed value (must be non-zero for maximal length sequence)
        lfsr <= 15'b000000000000001;
        data_out <= 1'b0;
    end else if (bit_clock_enable) begin
        // PRBS-15 feedback: XOR of bits [14] and [13]
        // Shift left, insert feedback at LSB
        lfsr <= {lfsr[13:0], lfsr[14] ^ lfsr[13]};
        
        // Output is MSB of LFSR
        data_out <= lfsr[14];
    end
end

endmodule
