module IDC(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_id,
    // Output signals
    out_valid,
    out_legal_id
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [5:0] in_id;

output logic out_valid;
output logic out_legal_id;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

reg [3:0] index;
reg [5:0] ID [9:0];
reg [8:0] sum;
reg [3:0] remainder;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		index <= 0;
		out_valid <= 0;
		out_legal_id <= 0;
		sum <= 0;
	end else if (in_valid && index < 10)begin
		index <= index + 1;
		ID[index] <= in_id;
		if(index == 0)begin
			sum <= in_id / 10 + (in_id % 10) * 9;
		end else if(index != 9) begin
			sum <= sum + in_id * (9 - index); //(9-index) is the weight.
		end else
			remainder <= sum % 10;
		
	end else if (10 <= index && index < 14) begin
		index <= index + 1;
	end else if(index == 14) begin
		out_valid <= 1;
		if (10 - remainder == ID[9])out_legal_id <= 1;
		else if (remainder == 0 && ID[9] == 0)out_legal_id <= 1;
		else out_legal_id <= 0;

		index <= index + 1;
	end else if(index == 15)begin
		out_valid <= 0;
		out_legal_id <= 0;
		index <= 0;
	end
end



endmodule