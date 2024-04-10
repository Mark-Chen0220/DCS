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
reg out_legal_id_temp;
reg [11:0] sum_pipe0, sum_pipe1, sum_pipe2, sum_pipe3, sum_pipe4, sum_pipe5, sum_pipe6, sum_pipe7, sum_pipe8;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		index <= 0;
		out_valid <= 0;
		out_legal_id <= 0;
		
	end else if (in_valid && index < 10)begin
		index <= index + 1;
		ID[index] <= in_id;
		sum_pipe8 <= sum_pipe7 + ID[8];
        sum_pipe7 <= sum_pipe6 + ID[7] * 2;
        sum_pipe6 <= sum_pipe5 + ID[6] * 3;
        sum_pipe5 <= sum_pipe4 + ID[5] * 4;
        sum_pipe4 <= sum_pipe3 + ID[4] * 5;
        sum_pipe3 <= sum_pipe2 + ID[3] * 6;
        sum_pipe2 <= sum_pipe1 + ID[2] * 7;
        sum_pipe1 <= sum_pipe0 + ID[1] * 8; 
		sum_pipe0 <= ID[0] / 10 + ID[0] % 10 * 9;

		
	//end //else if (10 <= index && index < 14) begin
		//index <= index + 1;
	end else if(index == 10) begin
		//ID[index] <= in_id;
		out_legal_id <= out_legal_id_temp;
		out_valid <= 1;
		index <= index + 1;
		
	end else if(index == 11)begin
		out_valid <= 0;
		out_legal_id <= 0;
		index <= 0;
	end
end

always_comb begin
		sum = sum_pipe8;
        remainder = sum % 10;
		if (10 - remainder == ID[9])out_legal_id_temp = 1;
		else if (remainder == 0 && ID[9] == 0)out_legal_id_temp = 1;
		else out_legal_id_temp = 0;	
		
end



endmodule