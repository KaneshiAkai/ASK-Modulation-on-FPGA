module keying_controller (
    input clk,
    input reset,
    input data_in,                  
    output reg amplitude_control    
);

    // Data Synchronization
    reg data_in_sync1; // D-FF đầu tiên
    reg data_in_sync2; // D-FF thứ hai
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_in_sync1 <= 1'b0;
            data_in_sync2 <= 1'b0;
            amplitude_control <= 1'b0;
        end else begin
            data_in_sync1 <= data_in;
            data_in_sync2 <= data_in_sync1;
            amplitude_control <= data_in_sync2;
        end
    end
endmodule
