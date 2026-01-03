module dds_carrier_generator (
    input clk,
    input reset,
    output [11:0] dds_carrier_out
);
    
    // PHASE_INCREMENT (PI) quyết định tần số carrier		|| AI GENERATE
    // Công thức: PI = (2^32 * f_carrier) / f_clock
    // f_clock = 50 MHz
    parameter PHASE_INCREMENT = 32'h0033126E; // 39 kHz
    //
    reg [31:0] phase_accumulator;
    wire [7:0] lut_address;
    reg [11:0] lut_data_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_accumulator <= 32'h0;
        end 
        else begin
            phase_accumulator <= phase_accumulator + PHASE_INCREMENT;
        end
    end

    assign lut_address = phase_accumulator[31:24];

    // 3. Khối LUT/ROM - Sin Table (256 mẫu, 12-bit output)   ||   AI GENERATE
    // Bảng sin đã được tính trước: sin(2π * i/256) * 2047 + 2048
    reg [11:0] sin_table [0:255];
    
    initial begin
        // Khởi tạo bảng sin 256 mẫu (0-360 độ)
        sin_table[0] = 12'd2048; sin_table[1] = 12'd2098; sin_table[2] = 12'd2148; sin_table[3] = 12'd2198;
        sin_table[4] = 12'd2248; sin_table[5] = 12'd2298; sin_table[6] = 12'd2348; sin_table[7] = 12'd2398;
        sin_table[8] = 12'd2447; sin_table[9] = 12'd2496; sin_table[10] = 12'd2545; sin_table[11] = 12'd2594;
        sin_table[12] = 12'd2642; sin_table[13] = 12'd2690; sin_table[14] = 12'd2737; sin_table[15] = 12'd2784;
        sin_table[16] = 12'd2831; sin_table[17] = 12'd2877; sin_table[18] = 12'd2923; sin_table[19] = 12'd2968;
        sin_table[20] = 12'd3013; sin_table[21] = 12'd3057; sin_table[22] = 12'd3100; sin_table[23] = 12'd3143;
        sin_table[24] = 12'd3185; sin_table[25] = 12'd3227; sin_table[26] = 12'd3268; sin_table[27] = 12'd3308;
        sin_table[28] = 12'd3347; sin_table[29] = 12'd3386; sin_table[30] = 12'd3423; sin_table[31] = 12'd3460;
        sin_table[32] = 12'd3496; sin_table[33] = 12'd3531; sin_table[34] = 12'd3565; sin_table[35] = 12'd3598;
        sin_table[36] = 12'd3630; sin_table[37] = 12'd3662; sin_table[38] = 12'd3692; sin_table[39] = 12'd3722;
        sin_table[40] = 12'd3750; sin_table[41] = 12'd3777; sin_table[42] = 12'd3804; sin_table[43] = 12'd3829;
        sin_table[44] = 12'd3853; sin_table[45] = 12'd3876; sin_table[46] = 12'd3898; sin_table[47] = 12'd3919;
        sin_table[48] = 12'd3939; sin_table[49] = 12'd3958; sin_table[50] = 12'd3975; sin_table[51] = 12'd3992;
        sin_table[52] = 12'd4007; sin_table[53] = 12'd4021; sin_table[54] = 12'd4034; sin_table[55] = 12'd4045;
        sin_table[56] = 12'd4056; sin_table[57] = 12'd4065; sin_table[58] = 12'd4073; sin_table[59] = 12'd4080;
        sin_table[60] = 12'd4086; sin_table[61] = 12'd4090; sin_table[62] = 12'd4093; sin_table[63] = 12'd4095;
        sin_table[64] = 12'd4095; sin_table[65] = 12'd4095; sin_table[66] = 12'd4093; sin_table[67] = 12'd4090;
        sin_table[68] = 12'd4086; sin_table[69] = 12'd4080; sin_table[70] = 12'd4073; sin_table[71] = 12'd4065;
        sin_table[72] = 12'd4056; sin_table[73] = 12'd4045; sin_table[74] = 12'd4034; sin_table[75] = 12'd4021;
        sin_table[76] = 12'd4007; sin_table[77] = 12'd3992; sin_table[78] = 12'd3975; sin_table[79] = 12'd3958;
        sin_table[80] = 12'd3939; sin_table[81] = 12'd3919; sin_table[82] = 12'd3898; sin_table[83] = 12'd3876;
        sin_table[84] = 12'd3853; sin_table[85] = 12'd3829; sin_table[86] = 12'd3804; sin_table[87] = 12'd3777;
        sin_table[88] = 12'd3750; sin_table[89] = 12'd3722; sin_table[90] = 12'd3692; sin_table[91] = 12'd3662;
        sin_table[92] = 12'd3630; sin_table[93] = 12'd3598; sin_table[94] = 12'd3565; sin_table[95] = 12'd3531;
        sin_table[96] = 12'd3496; sin_table[97] = 12'd3460; sin_table[98] = 12'd3423; sin_table[99] = 12'd3386;
        sin_table[100] = 12'd3347; sin_table[101] = 12'd3308; sin_table[102] = 12'd3268; sin_table[103] = 12'd3227;
        sin_table[104] = 12'd3185; sin_table[105] = 12'd3143; sin_table[106] = 12'd3100; sin_table[107] = 12'd3057;
        sin_table[108] = 12'd3013; sin_table[109] = 12'd2968; sin_table[110] = 12'd2923; sin_table[111] = 12'd2877;
        sin_table[112] = 12'd2831; sin_table[113] = 12'd2784; sin_table[114] = 12'd2737; sin_table[115] = 12'd2690;
        sin_table[116] = 12'd2642; sin_table[117] = 12'd2594; sin_table[118] = 12'd2545; sin_table[119] = 12'd2496;
        sin_table[120] = 12'd2447; sin_table[121] = 12'd2398; sin_table[122] = 12'd2348; sin_table[123] = 12'd2298;
        sin_table[124] = 12'd2248; sin_table[125] = 12'd2198; sin_table[126] = 12'd2148; sin_table[127] = 12'd2098;
        sin_table[128] = 12'd2048; sin_table[129] = 12'd1998; sin_table[130] = 12'd1948; sin_table[131] = 12'd1898;
        sin_table[132] = 12'd1848; sin_table[133] = 12'd1798; sin_table[134] = 12'd1748; sin_table[135] = 12'd1698;
        sin_table[136] = 12'd1649; sin_table[137] = 12'd1600; sin_table[138] = 12'd1551; sin_table[139] = 12'd1502;
        sin_table[140] = 12'd1454; sin_table[141] = 12'd1406; sin_table[142] = 12'd1359; sin_table[143] = 12'd1312;
        sin_table[144] = 12'd1265; sin_table[145] = 12'd1219; sin_table[146] = 12'd1173; sin_table[147] = 12'd1128;
        sin_table[148] = 12'd1083; sin_table[149] = 12'd1039; sin_table[150] = 12'd996; sin_table[151] = 12'd953;
        sin_table[152] = 12'd911; sin_table[153] = 12'd869; sin_table[154] = 12'd828; sin_table[155] = 12'd788;
        sin_table[156] = 12'd749; sin_table[157] = 12'd710; sin_table[158] = 12'd673; sin_table[159] = 12'd636;
        sin_table[160] = 12'd600; sin_table[161] = 12'd565; sin_table[162] = 12'd531; sin_table[163] = 12'd498;
        sin_table[164] = 12'd466; sin_table[165] = 12'd434; sin_table[166] = 12'd404; sin_table[167] = 12'd374;
        sin_table[168] = 12'd346; sin_table[169] = 12'd319; sin_table[170] = 12'd292; sin_table[171] = 12'd267;
        sin_table[172] = 12'd243; sin_table[173] = 12'd220; sin_table[174] = 12'd198; sin_table[175] = 12'd177;
        sin_table[176] = 12'd157; sin_table[177] = 12'd138; sin_table[178] = 12'd121; sin_table[179] = 12'd104;
        sin_table[180] = 12'd89; sin_table[181] = 12'd75; sin_table[182] = 12'd62; sin_table[183] = 12'd51;
        sin_table[184] = 12'd40; sin_table[185] = 12'd31; sin_table[186] = 12'd23; sin_table[187] = 12'd16;
        sin_table[188] = 12'd10; sin_table[189] = 12'd6; sin_table[190] = 12'd3; sin_table[191] = 12'd1;
        sin_table[192] = 12'd1; sin_table[193] = 12'd1; sin_table[194] = 12'd3; sin_table[195] = 12'd6;
        sin_table[196] = 12'd10; sin_table[197] = 12'd16; sin_table[198] = 12'd23; sin_table[199] = 12'd31;
        sin_table[200] = 12'd40; sin_table[201] = 12'd51; sin_table[202] = 12'd62; sin_table[203] = 12'd75;
        sin_table[204] = 12'd89; sin_table[205] = 12'd104; sin_table[206] = 12'd121; sin_table[207] = 12'd138;
        sin_table[208] = 12'd157; sin_table[209] = 12'd177; sin_table[210] = 12'd198; sin_table[211] = 12'd220;
        sin_table[212] = 12'd243; sin_table[213] = 12'd267; sin_table[214] = 12'd292; sin_table[215] = 12'd319;
        sin_table[216] = 12'd346; sin_table[217] = 12'd374; sin_table[218] = 12'd404; sin_table[219] = 12'd434;
        sin_table[220] = 12'd466; sin_table[221] = 12'd498; sin_table[222] = 12'd531; sin_table[223] = 12'd565;
        sin_table[224] = 12'd600; sin_table[225] = 12'd636; sin_table[226] = 12'd673; sin_table[227] = 12'd710;
        sin_table[228] = 12'd749; sin_table[229] = 12'd788; sin_table[230] = 12'd828; sin_table[231] = 12'd869;
        sin_table[232] = 12'd911; sin_table[233] = 12'd953; sin_table[234] = 12'd996; sin_table[235] = 12'd1039;
        sin_table[236] = 12'd1083; sin_table[237] = 12'd1128; sin_table[238] = 12'd1173; sin_table[239] = 12'd1219;
        sin_table[240] = 12'd1265; sin_table[241] = 12'd1312; sin_table[242] = 12'd1359; sin_table[243] = 12'd1406;
        sin_table[244] = 12'd1454; sin_table[245] = 12'd1502; sin_table[246] = 12'd1551; sin_table[247] = 12'd1600;
        sin_table[248] = 12'd1649; sin_table[249] = 12'd1698; sin_table[250] = 12'd1748; sin_table[251] = 12'd1798;
        sin_table[252] = 12'd1848; sin_table[253] = 12'd1898; sin_table[254] = 12'd1948; sin_table[255] = 12'd1998;
    end
    //

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lut_data_out <= 12'd0;
		  end
        else begin
            lut_data_out <= sin_table[lut_address];
		  end
    end

    assign dds_carrier_out = lut_data_out;
endmodule
