module CT(
  input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5,
	input [4:0] opcode,
	output reg [8:0] out_n
);

	wire [4:0] value_0, value_1, value_2, value_3, value_4, value_5;
	wire [4:0] sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5;
	reg [4:0] opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5;
	reg [7:0] average = ((value_0 + value_1 + value_2 + value_3 + value_4 + value_5) / 6);

	//---------------------------------------------------------------------
	//   Your design                        
	//---------------------------------------------------------------------
	register_file val0 (.address(in_n0), .value(value_0));
	register_file val1 (.address(in_n1), .value(value_1));
	register_file val2 (.address(in_n2), .value(value_2));
	register_file val3 (.address(in_n3), .value(value_3));
	register_file val4 (.address(in_n4), .value(value_4));
	register_file val5 (.address(in_n5), .value(value_5));
	
	Sort LeftLargest(value_0, value_1, value_2, value_3, value_4, value_5, {sorted_5, sorted_4, sorted_3, sorted_2, sorted_1, sorted_0});
	
	always@*begin
		out_n = 0;
		case(opcode[4:3])
		2'b11: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5};
		2'b10: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {sorted_5, sorted_4, sorted_3, sorted_2, sorted_1, sorted_0};
		2'b01: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {value_5, value_4, value_3, value_2, value_1, value_0};
		2'b00: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {value_0, value_1, value_2, value_3, value_4, value_5};
		endcase
		
		case(opcode[2:0])
		3'b000: out_n = out_n + (opvalue_0 >= average) + (opvalue_1 >= average) + (opvalue_2 >= average) + (opvalue_3 >= average) + (opvalue_4 >= average) + (opvalue_5 >= average);
		3'b001: out_n = opvalue_0 + opvalue_5;
		3'b010: out_n = (opvalue_3 * opvalue_4) >> 1;
		3'b011: out_n = opvalue_0 + (opvalue_2 << 1);
		3'b100: out_n = opvalue_1 & opvalue_2;
		3'b101: out_n = ~opvalue_0;
		3'b110: out_n = opvalue_3 ^ opvalue_4;
		3'b111: out_n = opvalue_1 << 1;
		endcase
	end

endmodule

//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule

module Sort(
    input [4:0] in_num0, in_num1, in_num2, in_num3, in_num4, in_num5,
    output [29:0] out_num
);

wire [4:0] No1_lesser, No1_greater;
wire [4:0] No2_lesser, No2_greater;
wire [4:0] No3_lesser, No3_greater;
wire [4:0] No4_lesser, No4_greater;
wire [4:0] No5_lesser, No5_greater;
wire [4:0] No6_lesser, No6_greater;
wire [4:0] No7_lesser, No7_greater;
wire [4:0] No8_lesser, No8_greater;
wire [4:0] No9_lesser, No9_greater;
wire [4:0] No10_lesser, No10_greater;
wire [4:0] No11_lesser, No11_greater;
wire [4:0] No12_lesser, No12_greater;
wire [4:0] No13_lesser, No13_greater;
wire [4:0] No14_lesser, No14_greater;
wire [4:0] No15_lesser, No15_greater;

assign No1_lesser = (in_num0 < in_num1) ? in_num0 : in_num1;
assign No1_greater = (in_num0 >= in_num1) ? in_num0 : in_num1;

assign No2_lesser = (in_num2 < in_num3) ? in_num2 : in_num3;
assign No2_greater = (in_num2 >= in_num3) ? in_num2 : in_num3;

assign No3_lesser = (No1_greater < No2_lesser) ? No1_greater : No2_lesser;
assign No3_greater = (No1_greater >= No2_lesser) ? No1_greater : No2_lesser;

assign No4_lesser = (No2_greater < in_num4) ? No2_greater : in_num4;
assign No4_greater = (No2_greater >= in_num4) ? No2_greater : in_num4;

assign No5_lesser = (No1_lesser < No3_lesser) ? No1_lesser : No3_lesser;
assign No5_greater = (No1_lesser >= No3_lesser) ? No1_lesser : No3_lesser;

assign No6_lesser = (No3_greater < No4_lesser) ? No3_greater : No4_lesser;
assign No6_greater = (No3_greater >= No4_lesser) ? No3_greater : No4_lesser;

assign No7_lesser = (No5_greater < No6_lesser) ? No5_greater : No6_lesser;
assign No7_greater = (No5_greater >= No6_lesser) ? No5_greater : No6_lesser;

assign No8_lesser = (No6_greater < No4_greater) ? No6_greater : No4_greater;
assign No8_greater = (No6_greater >= No4_greater) ? No6_greater : No4_greater;

assign No9_lesser = (No5_lesser < No7_lesser) ? No5_lesser : No7_lesser;
assign No9_greater = (No5_lesser >= No7_lesser) ? No5_lesser : No7_lesser;

assign No10_lesser = (No7_greater < No8_lesser) ? No7_greater : No8_lesser;
assign No10_greater = (No7_greater >= No8_lesser) ? No7_greater : No8_lesser;

assign No11_lesser = (in_num5 < No9_lesser) ? in_num5 : No9_lesser;
assign No11_greater = (in_num5 >= No9_lesser) ? in_num5 : No9_lesser;

assign No12_lesser = (No11_greater < No9_greater) ? No11_greater : No9_greater;
assign No12_greater = (No11_greater >= No9_greater) ? No11_greater : No9_greater;

assign No13_lesser = (No12_greater < No10_lesser) ? No12_greater : No10_lesser;
assign No13_greater = (No12_greater >= No10_lesser) ? No12_greater : No10_lesser;

assign No14_lesser = (No13_greater < No10_greater) ? No13_greater : No10_greater;
assign No14_greater = (No13_greater >= No10_greater) ? No13_greater : No10_greater;

assign No15_lesser = (No14_greater < No8_greater) ? No14_greater : No8_greater;
assign No15_greater = (No14_greater >= No8_greater) ? No14_greater : No8_greater;

assign out_num[4:0] = No11_lesser;
assign out_num[9:5] = No12_lesser;
assign out_num[14:10] = No13_lesser;
assign out_num[19:15] = No14_lesser;
assign out_num[24:20] = No15_lesser;
assign out_num[29:25] = No15_greater;

endmodule