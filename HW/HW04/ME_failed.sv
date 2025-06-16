module ME(
    // Input signals
	clk,
	rst_n,
    block_valid,
	area_valid,
    in_data,
    // Output signals
    out_valid,
    out_vector
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, block_valid, area_valid;
input [7:0] in_data;

output logic out_valid;
output logic signed [2:0] out_vector;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
reg [7:0][7:0][7:0] whole_frame;
reg [3:0][3:0][7:0] block;
reg [14:0] min_dist; //reset as 32767
reg signed [4:0][4:0][2:0] vector_matrix ;
reg signed [3:0] i,j; 
reg signed [2:0] out_vec_x, out_vec_y;
reg signed [2:0] out_vector_temp;
reg out_valid_temp;
reg [1:0] out_cnt, out_cnt_temp;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		whole_frame <= 0;
		block <= 0;	
		out_vec_x <= 0;
		out_vec_y <= 0;
	end else begin
		if (block_valid) begin
			block[i][j] <= in_data;
			if (i == 3 && j == 3)begin
				i <= 0;
				j <= 0;
			end else begin
				if (j == 3)begin
					i <= i + 1;
					j <= 0;
				end else begin
					i <= i;
					j <= j + 1;
				end
			end
		end
		else if(area_valid) begin
			whole_frame[i][j] <= in_data;
			if (i == 7 && j == 7)begin
				i <= 0;
				j <= 0;
			end else begin
				if (j == 7)begin
					i <= i + 1;
					j <= 0;
				end else begin
					i <= i;
					j <= j + 1;
				end
			end
		end 
		else begin
			whole_frame <= whole_frame;
			block <= block;
		end
	end
end

//---------------------------------------------------------------------
//   SAD                        
//---------------------------------------------------------------------
always_comb begin
	if (area_valid && i >= 3 && j >= 3) begin
		case({i,j})
			{3,3}: begin
				if (min_dist > compute_SAD(block, whole_frame[3:0][3:0])) begin
					min_dist = compute_SAD(block, whole_frame[3:0][3:0]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{3,4}: begin
				if (min_dist > compute_SAD(block, whole_frame[3:0][4:1])) begin
					min_dist = compute_SAD(block, whole_frame[3:0][4:1]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{3,5}: begin
				if (min_dist > compute_SAD(block, whole_frame[3:0][5:2])) begin
					min_dist = compute_SAD(block, whole_frame[3:0][5:2]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{3,6}: begin
				if (min_dist > compute_SAD(block, whole_frame[3:0][6:3])) begin
					min_dist = compute_SAD(block, whole_frame[3:0][6:3]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{3,7}: begin
				if (min_dist > compute_SAD(block, whole_frame[3:0][7:4])) begin
					min_dist = compute_SAD(block, whole_frame[3:0][7:4]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{4,3}: begin
				if (min_dist > compute_SAD(block, whole_frame[4:1][3:0])) begin
					min_dist = compute_SAD(block, whole_frame[4:1][3:0]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{4,4}: begin
				if (min_dist > compute_SAD(block, whole_frame[4:1][4:1])) begin
					min_dist = compute_SAD(block, whole_frame[4:1][4:1]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{4,5}: begin
				if (min_dist > compute_SAD(block, whole_frame[4:1][5:2])) begin
					min_dist = compute_SAD(block, whole_frame[4:1][5:2]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{4,6}: begin
				if (min_dist > compute_SAD(block, whole_frame[4:1][6:3])) begin
					min_dist = compute_SAD(block, whole_frame[4:1][6:3]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{4,7}: begin
				if (min_dist > compute_SAD(block, whole_frame[4:1][7:4])) begin
					min_dist = compute_SAD(block, whole_frame[4:1][7:4]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{5,3}: begin
				if (min_dist > compute_SAD(block, whole_frame[5:2][3:0])) begin
					min_dist = compute_SAD(block, whole_frame[5:2][3:0]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{5,4}: begin
				if (min_dist > compute_SAD(block, whole_frame[5:2][4:1])) begin
					min_dist = compute_SAD(block, whole_frame[5:2][4:1]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{5,5}: begin
				if (min_dist > compute_SAD(block, whole_frame[5:2][5:2])) begin
					min_dist = compute_SAD(block, whole_frame[5:2][5:2]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{5,6}: begin
				if (min_dist > compute_SAD(block, whole_frame[5:2][6:3])) begin
					min_dist = compute_SAD(block, whole_frame[5:2][6:3]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{5,7}: begin
				if (min_dist > compute_SAD(block, whole_frame[5:2][7:4])) begin
					min_dist = compute_SAD(block, whole_frame[5:2][7:4]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{6,3}: begin
				if (min_dist > compute_SAD(block, whole_frame[6:3][3:0])) begin
					min_dist = compute_SAD(block, whole_frame[6:3][3:0]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{6,4}: begin
				if (min_dist > compute_SAD(block, whole_frame[6:3][4:1])) begin
					min_dist = compute_SAD(block, whole_frame[6:3][4:1]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{6,5}: begin
				if (min_dist > compute_SAD(block, whole_frame[6:3][5:2])) begin
					min_dist = compute_SAD(block, whole_frame[6:3][5:2]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{6,6}: begin
				if (min_dist > compute_SAD(block, whole_frame[6:3][6:3])) begin
					min_dist = compute_SAD(block, whole_frame[6:3][6:3]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{6,7}: begin
				if (min_dist > compute_SAD(block, whole_frame[6:3][7:4])) begin
					min_dist = compute_SAD(block, whole_frame[6:3][7:4]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{7,3}: begin
				if (min_dist > compute_SAD(block, whole_frame[7:4][3:0])) begin
					min_dist = compute_SAD(block, whole_frame[7:4][3:0]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{7,4}: begin
				if (min_dist > compute_SAD(block, whole_frame[7:4][4:1])) begin
					min_dist = compute_SAD(block, whole_frame[7:4][4:1]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{7,5}: begin
				if (min_dist > compute_SAD(block, whole_frame[7:4][5:2])) begin
					min_dist = compute_SAD(block, whole_frame[7:4][5:2]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{7,6}: begin
				if (min_dist > compute_SAD(block, whole_frame[7:4][6:3])) begin
					min_dist = compute_SAD(block, whole_frame[7:4][6:3]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end
			{7,7}: begin
				if (min_dist > compute_SAD(block, whole_frame[7:4][7:4])) begin
					min_dist = compute_SAD(block, whole_frame[7:4][7:4]);
					out_vec_x = -5 + j;
					out_vec_y = 5 - i; 
				end
			end		
		endcase
		if (min_dist > compute_SAD(block, whole_frame[i:i-3][j:j-3])) begin
			min_dist = compute_SAD(block, whole_frame[i:i-3][j:j-3]);
			out_vec_x = -5 + j;
			out_vec_y = 5 - i; 
		end
		else begin
			min_dist = min_dist;
			out_vec_x = out_vec_x;
			out_vec_y = out_vec_y; 
		end
	end
end

//---------------------------------------------------------------------
//   Output                        
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_cnt <= 2;
	else out_cnt <= out_cnt_temp;
end

always_comb begin
	if (i == 7 && j == 7) out_cnt_temp = 1;
	else if (out_vector == out_vec_x) out_cnt_temp = 0;
	else out_cnt_temp = 2;
end

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_valid <= 0;
	else out_valid <= out_valid_temp;
end

always_comb begin
	if (i == 7 && j == 7 && (out_cnt > 0) ) out_valid_temp = 1;
	else out_valid_temp = 0;
end

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_vector <= 0;
	else out_vector <= out_vector_temp;
end

always_comb begin
	if (i == 7 && j == 7 && (out_cnt == 2) ) out_vector_temp = out_vec_x;
	else if (out_cnt == 1) out_vector_temp = out_vec_y;
	else out_vector_temp = 0;
end

endmodule



//---------------------------------------------------------------------
//   SAD Function                       
//---------------------------------------------------------------------

function [14:0] compute_SAD(input [15:0][7:0] block, input [15:0][7:0] search_area);
	compute_SAD = abs(block[0], search_area[0]) + abs(block[1], search_area[1]) +
				  abs(block[2], search_area[2]) + abs(block[3], search_area[3]) +
				  abs(block[4], search_area[4]) + abs(block[5], search_area[5]) +
				  abs(block[6], search_area[6]) + abs(block[7], search_area[7]) +
				  abs(block[8], search_area[8]) + abs(block[9], search_area[9]) +
				  abs(block[10], search_area[10]) + abs(block[11], search_area[11]) +
				  abs(block[12], search_area[12]) + abs(block[13], search_area[13]) +
				  abs(block[14], search_area[14]) + abs(block[15], search_area[15]);
endfunction

function [8:0] abs(input [7:0] a, input [7:0] b);
	if (a > b) abs = a - b;
	else abs = b - a;
endfunction