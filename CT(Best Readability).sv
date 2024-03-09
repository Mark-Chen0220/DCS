module CT(
    input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5,
	input [4:0] opcode,
	output reg [8:0] out_n
);

	wire [4:0] value_0, value_1, value_2, value_3, value_4, value_5;
	wire [4:0] sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5;
	wire [4:0] opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5;
	
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
	
	Rearrange_Sequence RS(value_0, value_1, value_2, value_3, value_4, value_5,sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5,
						opcode[4:3], opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5);
	
	Compute_Output CO(opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5, opcode[2:0], out_n);

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

module Comp_and_Mux(
  input [4:0] in1, in2,
  output reg [4:0]  lesser,
  output reg [4:0]  greater
);
  always@* begin
    if (in1 >= in2) begin 
      greater = in1;
      lesser = in2;
    end 
    else begin
      greater = in2;
      lesser = in1;
    end
  end
endmodule

module Sort(
    input  [4:0] in_num0, in_num1, in_num2, in_num3, in_num4, in_num5,
	output [29:0] out_num 
);

  wire [4:0] No1_lesser,No1_greater;
  wire [4:0] No2_lesser,No2_greater;
  wire [4:0] No3_lesser,No3_greater;
  wire [4:0] No4_lesser,No4_greater;
  wire [4:0] No5_lesser,No5_greater;
  wire [4:0] No6_lesser,No6_greater;
  wire [4:0] No7_lesser,No7_greater;
  wire [4:0] No8_lesser,No8_greater;
  wire [4:0] No9_lesser,No9_greater;
  wire [4:0] No10_lesser,No10_greater;
  wire [4:0] No11_lesser,No11_greater;
  wire [4:0] No12_lesser,No12_greater;
  wire [4:0] No13_lesser,No13_greater;
  wire [4:0] No14_lesser,No14_greater;
  wire [4:0] No15_lesser,No15_greater;

  Comp_and_Mux No1(in_num0,in_num1,No1_lesser,No1_greater);
  Comp_and_Mux No2(in_num2,in_num3,No2_lesser,No2_greater);
  Comp_and_Mux No3(No1_greater,No2_lesser,No3_lesser,No3_greater);
  Comp_and_Mux No4(No2_greater,in_num4,No4_lesser,No4_greater);
  Comp_and_Mux No5(No1_lesser,No3_lesser,No5_lesser,No5_greater);
  Comp_and_Mux No6(No3_greater,No4_lesser,No6_lesser,No6_greater);
  Comp_and_Mux No7(No5_greater,No6_lesser,No7_lesser,No7_greater);
  Comp_and_Mux No8(No6_greater,No4_greater,No8_lesser,No8_greater);
  Comp_and_Mux No9(No5_lesser,No7_lesser,No9_lesser,No9_greater);
  Comp_and_Mux No10(No7_greater,No8_lesser,No10_lesser,No10_greater);
  Comp_and_Mux No11(in_num5,No9_lesser,No11_lesser,No11_greater);
  Comp_and_Mux No12(No11_greater,No9_greater,No12_lesser,No12_greater);
  Comp_and_Mux No13(No12_greater,No10_lesser,No13_lesser,No13_greater);
  Comp_and_Mux No14(No13_greater,No10_greater,No14_lesser,No14_greater);
  Comp_and_Mux No15(No14_greater,No8_greater,No15_lesser,No15_greater);
  
  assign out_num [4:0] = No11_lesser;
  assign out_num [9:5] = No12_lesser;
  assign out_num [14:10] = No13_lesser;
  assign out_num [19:15] = No14_lesser;
  assign out_num [24:20] = No15_lesser;
  assign out_num [29:25] = No15_greater;

endmodule

module Rearrange_Sequence(
	input [4:0] value_0, value_1, value_2, value_3, value_4, value_5,
	input [4:0] sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5,
	input [4:3] opcode,
	output reg [4:0] opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5
);
	always@*begin
		case(opcode[4:3])
		2'b11: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {sorted_0, sorted_1, sorted_2, sorted_3, sorted_4, sorted_5};
		2'b10: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {sorted_5, sorted_4, sorted_3, sorted_2, sorted_1, sorted_0};
		2'b01: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {value_5, value_4, value_3, value_2, value_1, value_0};
		2'b00: {opvalue_0, opvalue_1, opvalue_2, opvalue_3, opvalue_4, opvalue_5} = {value_0, value_1, value_2, value_3, value_4, value_5};
		endcase
	end
endmodule

module Compute_Output(
	input [4:0] value_0, value_1, value_2, value_3, value_4, value_5,
	input [2:0] opcode,
	output reg [8:0]out_n
);	

	reg [7:0] average;
	always@*begin
		out_n = 0;
		case(opcode[2:0])
			3'b000: begin
				average = ((value_0 + value_1 + value_2 + value_3 + value_4 + value_5) / 6);
				out_n = out_n + (value_0 >= average) + (value_1 >= average) + (value_2 >= average)
						+ (value_3 >= average) + (value_4 >= average) + (value_5 >= average);
			end
			3'b001: out_n = value_0 + value_5;
			3'b010: out_n = (value_3 * value_4) / 2;
			3'b011: out_n = value_0 + (value_2 * 2);
			3'b100: out_n = value_1 & value_2;
			3'b101: out_n = ~value_0;
			3'b110: out_n = value_3 ^ value_4;
			3'b111: out_n = value_1 << 1;
		endcase
	end
endmodule
