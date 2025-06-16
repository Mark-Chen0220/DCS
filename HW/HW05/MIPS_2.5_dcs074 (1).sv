module MIPS(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
logic [5:0] a, b, a_temp, b_temp;


input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;

logic [15:0] immediate, immediate_reg, rs_val, rt_val, rs_val_temp, rt_val_temp;
logic [5:0]opcode, funct, opcode_reg, funct_reg;
logic [4:0] rs, rt,  rd, shamt, rs_reg, rt_reg, rd_reg, shamt_reg; 

logic [1:0] out_delay; 
logic [1:0] instruction_fail_delay;

logic [15:0] reg0, reg1, reg2, reg3, reg4, reg5;
logic [15:0] reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp;
logic [15:0] write_val, write_val_temp;
logic [4:0] write_addr, write_addr_temp;

wire invalid_opcode;

//================================================================
// DESIGN 
//================================================================
assign opcode = instruction[31:26];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign shamt = instruction[10:6];
assign funct = instruction[5:0];
assign immediate = instruction[15:0];

assign invalid_opcode = !((opcode == 6'b000000) || (opcode == 6'b001000));

//================================================================
// out_valid 
//================================================================

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
		out_delay <= 2'b00;
	end
	else {out_valid, out_delay} <= {out_delay, in_valid};
end

assign out_0 = reg0;
assign out_1 = reg1;
assign out_2 = reg2;
assign out_3 = reg3;
assign out_4 = reg4;
assign out_5 = reg5;

//================================================================
// instruction_fail
//================================================================

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		instruction_fail <= 0;
		instruction_fail_delay <= 0;
	end
	else {instruction_fail, instruction_fail_delay} <= {instruction_fail_delay, in_valid && invalid_opcode};
end

//================================================================
// Read input 
//================================================================

always_ff@(posedge clk) begin
	if (in_valid || out_delay != 0)begin
		if (opcode == 6'b000000) 
			{opcode_reg, rs_reg, rt_reg, rd_reg, shamt_reg, funct_reg} <= instruction;
		else if (opcode == 6'b001000)
			{opcode_reg, rs_reg, rt_reg, immediate_reg} <= instruction;
		else 
			{opcode_reg, rs_reg, rt_reg, rd_reg, shamt_reg, funct_reg, immediate_reg} <= 0; 
	end
end

//================================================================
// Compute 
//================================================================

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) write_val <= 0;
	else write_val <= write_val_temp;
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) write_addr <= 0;
	else write_addr <= write_addr_temp;
end

always_comb begin
	
	if(opcode_reg == 6'b000000)begin
		write_addr_temp = rd_reg;
		case(funct_reg) 
			6'b100000: write_val_temp = rs_val + rt_val;
			6'b100100: write_val_temp = rs_val & rt_val;
			6'b100101: write_val_temp = rs_val | rt_val;
			6'b100111: write_val_temp = ~(rs_val | rt_val);
			6'b000000: write_val_temp = rt_val << shamt_reg;
			6'b000010: write_val_temp = rt_val >> shamt_reg;
			default: write_val_temp = 0;
		endcase
	end
	else if(opcode_reg == 6'b001000) begin
		write_addr_temp = rt_reg;
		write_val_temp = rs_val + immediate_reg;
	end
	else begin
		write_addr_temp = 0;
		write_val_temp = 0;
	end
	
end


//================================================================
// Get Value At Address 
//================================================================


always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		rs_val <= 0;
		rt_val <= 0;
		{reg0, reg1, reg2, reg3, reg4, reg5} <= 0;
	end
	else begin
		rs_val <= rs_val_temp;
		rt_val <= rt_val_temp;
		{reg0, reg1, reg2, reg3, reg4, reg5} <= {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp};
	end
end

always_comb begin
	if(in_valid || out_delay != 0) begin
		case(rs)
			5'b10001: rs_val_temp = reg0;
			5'b10010: rs_val_temp = reg1;
			5'b01000: rs_val_temp = reg2;
			5'b10111: rs_val_temp = reg3;
			5'b11111: rs_val_temp = reg4;
			5'b10000: rs_val_temp = reg5;
			default: rs_val_temp = 0;
		endcase
	end else rs_val_temp = 0;
end

always_comb begin
	if(in_valid || out_delay != 0) begin
		case(rt)
			5'b10001: rt_val_temp = reg0;
			5'b10010: rt_val_temp = reg1;
			5'b01000: rt_val_temp = reg2;
			5'b10111: rt_val_temp = reg3;
			5'b11111: rt_val_temp = reg4;
			5'b10000: rt_val_temp = reg5;
			default: rt_val_temp = 0;
		endcase
	end
	else rt_val_temp = 0;
end

//================================================================
// Write Computed Value 
//================================================================

always_comb begin
	if (out_delay[1] == 1'b1) begin
		case(write_addr)
			5'b10001: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {write_val, reg1, reg2, reg3, reg4, reg5};
			5'b10010: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, write_val, reg2, reg3, reg4, reg5};
			5'b01000: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, write_val, reg3, reg4, reg5};
			5'b10111: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, reg2, write_val, reg4, reg5};
			5'b11111: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, reg2, reg3, write_val, reg5};
			5'b10000: {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, reg2, reg3, reg4, write_val};
			default:  {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, reg2, reg3, reg4, reg5};
		endcase
	end
	else if (out_delay == 0) {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = 0;
	else {reg0_temp, reg1_temp, reg2_temp, reg3_temp, reg4_temp, reg5_temp} = {reg0, reg1, reg2, reg3, reg4, reg5};
end

endmodule
