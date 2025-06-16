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
reg [0:7][0:7][7:0] whole_frame;
reg [0:3][0:3][7:0] block;
reg [14:0] min_dist, min_dist_temp, SAD_value; //reset as 32767
reg signed [3:0] i, j; 
reg signed [3:0] u, v, u_temp, v_temp; 
reg signed [2:0] out_vec_x, out_vec_y, out_vec_x_temp, out_vec_y_temp;
reg signed [2:0] out_vector_temp;
reg out_valid_temp;
reg [1:0] out_cnt, out_cnt_temp;
reg [1:0] hold_cnt, hold_cnt_temp;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   Calculate Current Location                       
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		u <= -2;
		v <= 2;
	end
	else begin
		u <= u_temp;
		v <= v_temp;
	end
end

always_comb begin
	if (i == 3 && j == 4) begin
		if (u == 2 && hold_cnt == 3)begin
			u_temp <= -2;
			v_temp <= v - 1;
		end 
		else if (hold_cnt || hold_cnt_temp) begin
			u_temp <= u;
			v_temp <= v;
		end
		else begin
			u_temp <= u + 1;
			v_temp <= v;
		end
	end
	else begin
		u_temp <= -2;
		v_temp <= 2;
	end
end

//---------------------------------------------------------------------
//   Hold operation for 3 cycles once u reaches edge                       
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) hold_cnt <= 0;
	else hold_cnt <= hold_cnt_temp;
end

always_comb begin
	if (u == 2) hold_cnt_temp = hold_cnt + 1;
	else hold_cnt_temp = 0;
end

//---------------------------------------------------------------------
//   Parse Input                      
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		whole_frame <= 0;
		block <= 0;	
		i <= 0;
		j <= 0;
	end else begin
		whole_frame <= whole_frame;
		block <= block;
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
			whole_frame [i][j] <= in_data;
			if (i == 3 && j == 4)begin
				i <= i;
				j <= j;
				whole_frame <= (whole_frame << 8);
				whole_frame [3][3] <= in_data; // Why is it that [3][3] doesn't update if this line doesn't exist
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
		else if (out_cnt == 1)begin
			i <= 0;
			j <= 0;
		end
	end
end

//---------------------------------------------------------------------
//   SAD                        
//---------------------------------------------------------------------
always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) min_dist <= 32767;
	else min_dist <= min_dist_temp;
end

always_comb begin
	if ((area_valid || (u == 2 && v == -2)) && i == 3 && j == 4 && !hold_cnt) begin
		SAD_value = compute_SAD(block, {whole_frame[0][0],whole_frame[0][1],whole_frame[0][2],whole_frame[0][3],
										whole_frame[1][0],whole_frame[1][1],whole_frame[1][2],whole_frame[1][3],
										whole_frame[2][0],whole_frame[2][1],whole_frame[2][2],whole_frame[2][3],
										whole_frame[3][0],whole_frame[3][1],whole_frame[3][2],whole_frame[3][3]});
		if (min_dist > SAD_value) min_dist_temp = SAD_value;
		else min_dist_temp = min_dist;
	end
	else if (block_valid) begin
		min_dist_temp = 32767;
		SAD_value = 32767;
	end
	else begin
		min_dist_temp = min_dist;
		SAD_value = 32767;
	end
end

//---------------------------------------------------------------------
//   Save Nearest Coords                        
//---------------------------------------------------------------------
always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		out_vec_x = 0;
		out_vec_y = 0; 
	end
	else begin
		out_vec_x = out_vec_x_temp;
		out_vec_y = out_vec_y_temp;
	end
end

always_comb begin
	if (min_dist > SAD_value) begin
		out_vec_x_temp = u;
		out_vec_y_temp = v; 
	end
	else begin
		out_vec_x_temp = out_vec_x;
		out_vec_y_temp = out_vec_y; 
	end
end

//---------------------------------------------------------------------
//   Output-Counter                        
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_cnt <= 2;
	else out_cnt <= out_cnt_temp;
end

always_comb begin
	if (out_cnt == 1 && out_vector == out_vec_x) out_cnt_temp = 0;
	else if (i == 3 && j == 4 && !area_valid ) out_cnt_temp = 1;
	else out_cnt_temp = 2;
end

//---------------------------------------------------------------------
//   Output-Valid                        
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_valid <= 0;
	else out_valid <= out_valid_temp;
end

always_comb begin
	if (i == 3 && j == 4 && !area_valid && (out_cnt > 0) ) out_valid_temp = 1;
	else out_valid_temp = 0;
end

//---------------------------------------------------------------------
//   Output-Vector                        
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_vector <= 0;
	else out_vector <= out_vector_temp;
end

always_comb begin
	if (i == 3 && j == 4 && !area_valid && (out_cnt == 2)) begin
		if (out_vec_x_temp == 2 && out_vec_y_temp == -2) out_vector_temp = out_vec_x_temp;
		else out_vector_temp = out_vec_x;
	end
	else if (out_cnt == 1) out_vector_temp = out_vec_y;
	else out_vector_temp = 0;
end

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

//---------------------------------------------------------------------
//   abs Function                       
//---------------------------------------------------------------------

function [8:0] abs(input [7:0] a, input [7:0] b);
	if (a >= b) abs = a - b;
	else abs = b - a;
endfunction

endmodule