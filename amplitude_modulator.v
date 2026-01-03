module amplitude_modulator (
    input [11:0] dds_carrier_in,     
    input amplitude_control_in,       
    output [11:0] ask_modulated_out  
);

    assign ask_modulated_out = amplitude_control_in ? dds_carrier_in : 12'b0;
endmodule
