module ask_modulator_top (
    input CLOCK_50,      
    input [3:0] KEY,    
    input [17:0] SW,    
    output [17:0] LEDR,   
    output [8:0] LEDG,  
    output [7:0] GPIO_0   
);

    wire clk;
    wire reset;
    wire data_in;
    
    // PRBS generator signals
    wire [1:0] bit_rate_sel;      // Bit rate selection from SW[2:1]
    wire manual_override;         // Manual mode from SW[9]
    wire prbs_data;               // PRBS output
    wire prbs_bit_clock;          // PRBS bit clock for monitoring
    
    assign clk = CLOCK_50;        
    assign reset = ~KEY[0];       
    assign bit_rate_sel = SW[2:1];     // SW[2:1]: 00=1kbps, 01=10kbps, 10=100kbps
    assign manual_override = SW[9];     // SW[9]: 1=manual (SW[0]), 0=PRBS
    assign data_in = manual_override ? SW[0] : prbs_data;  // Mode selection         
    
    // tạo clock chậm để thấy LED nháy  // AI Generate
    reg [23:0] slow_clk_counter;
    reg slow_clk;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            slow_clk_counter <= 24'd0;
            slow_clk <= 1'b0;
        end else begin
            if (slow_clk_counter >= 24'd5_000_000) begin  // Chia 50MHz / 10M = 5Hz (nhanh hơn 5 lần)
                slow_clk_counter <= 24'd0;
                slow_clk <= ~slow_clk;
            end else begin
                slow_clk_counter <= slow_clk_counter + 1;
            end
        end
    end

    // Wire declarations
    wire [11:0] carrier_out_w;        
    wire [11:0] carrier_out_slow_w;
    wire amplitude_control_w;         
    wire [11:0] dac_out;             
    wire [11:0] dac_out_slow;       

    // PRBS Generator instantiation
    prbs_generator PRBS (
        .clk(clk),
        .reset(reset),
        .bit_rate_sel(bit_rate_sel),
        .data_out(prbs_data),
        .bit_clock(prbs_bit_clock)
    );

    keying_controller KC (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .amplitude_control(amplitude_control_w)
    );

    dds_carrier_generator DDS (
        .clk(clk),
        .reset(reset),
        .dds_carrier_out(carrier_out_w)
    );
    
    dds_carrier_generator DDS_SLOW (
        .clk(slow_clk),
        .reset(reset),
        .dds_carrier_out(carrier_out_slow_w)
    );
    
    amplitude_modulator AM (
        .dds_carrier_in(carrier_out_w),
        .amplitude_control_in(amplitude_control_w),
        .ask_modulated_out(dac_out)
    );
    
    amplitude_modulator AM_SLOW (
        .dds_carrier_in(carrier_out_slow_w),
        .amplitude_control_in(amplitude_control_w),
        .ask_modulated_out(dac_out_slow)
    );
    

    // LED Status Indicators
    assign LEDR[0] = data_in;                      // Current data bit (SW[0] or PRBS)
    assign LEDR[1] = amplitude_control_w;          // Synchronized amplitude control
    assign LEDR[2] = prbs_bit_clock;               // PRBS bit clock indicator
    assign LEDR[4:3] = bit_rate_sel;               // Show selected bit rate
    assign LEDR[8:5] = 4'b0;                       // Unused
    assign LEDR[17:9] = carrier_out_slow_w[11:3];  // Carrier amplitude (slow)
    
    assign LEDG[0] = manual_override;              // Green: Manual mode indicator
    assign LEDG[8:1] = dac_out_slow[11:4];         // DAC output (slow)
    
    // DAC Output to GPIO (high-speed, for oscilloscope)
    assign GPIO_0[7:0] = dac_out[11:4];  

endmodule
