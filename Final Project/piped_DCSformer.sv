module DCSformer(
	// Input signals
	clk,
	rst_n,
	i_valid,
	w_valid,
	i_data,
	w_data,
	// Output signals
	w_ready,
	o_valid,
	o_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input               clk, rst_n, i_valid, w_valid;
input         [7:0] i_data, w_data;
output logic        w_ready, o_valid;
output logic [31:0] o_data;

//Reg to hold data (compensate for counter delay) 
logic [7:0] i_reg, w_reg;

enum logic [2:0] {IDLE, INPUT_I, W_READY, WAIT_W_VALID, INPUT_W, RAT, CALC_MW, OUTPUT} state, next_state;
logic [7:0] counter, counter_next;

logic [0:7][0:15][7:0] I, I_temp; //8 * 16 input matrix;
logic [0:7][7:0] W, W_temp; //8 * 1 weight vector;
logic [0:7][0:7][19:0] IIT, IIT_temp; //8 * 16 I * IT matrix;
logic [0:7][31:0] O, O_temp; //8 * 1 IIT * W result vector

//Array location index
logic [3:0] i,j, x,y, j_prime, ic, jc; 

//I * IT value
logic [19:0] new_val;

//Row sum & average for RAT
logic [0:7][23:0] IIT_rows_sum;
logic [0:7][20:0] avg;

//Pipeline in_valid control
logic pipe_8_8_module_valid;
logic pipe_20_8_module_valid;

//Array for holding pipelined multiplication results
logic [0:15][15:0] RC_product;
logic [0:7][27:0] MW_product;

//---------------------------------------------------------------------
//   Your Design                       
//---------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
		counter <= 0;
	end
	else begin
		state <= next_state;
		counter <= counter_next;
	end
end

//---------------------------------------------------------------------
//   Next State + Counter                  
//---------------------------------------------------------------------

always_comb begin
    case(state)
        IDLE: begin
            next_state = (i_valid) ? INPUT_I : IDLE;
            counter_next = (i_valid) ? 0 : 10;
        end
        INPUT_I: begin
            next_state = (counter == 130) ? W_READY : INPUT_I;
            counter_next = (counter == 130) ? 0 : counter + 1 ;
        end
		W_READY: begin
            next_state = WAIT_W_VALID;
            counter_next = 0;
        end
		WAIT_W_VALID: begin
            next_state = (w_valid) ? INPUT_W : WAIT_W_VALID;
            counter_next = 0;
        end
		INPUT_W: begin
            next_state = (counter == 10) ? RAT: INPUT_W;
			counter_next = (counter == 10) ? 0 : counter + 1;
        end
		RAT: begin
			next_state = (counter == 7) ? CALC_MW : RAT;
            counter_next = (counter == 7) ? 0 : counter + 1 ;
		end
		CALC_MW: begin
			next_state = (counter == 10) ? OUTPUT : CALC_MW;
            counter_next = (counter == 10) ? 0 : counter + 1 ;
		end
        OUTPUT: begin
            next_state = (counter == 7) ? IDLE : OUTPUT;
            counter_next = (counter == 7) ? 0 : counter + 1 ;
        end
		default: begin
			next_state = state;
			counter_next = counter;
		end
    endcase
end

//---------------------------------------------------------------------
//   Parse Input                  
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		I <= 0;
		W <= 0;
		i_reg <= 0;
		w_reg <= 0;
		IIT <= 0;
		O <= 0;
	end else begin
		I <= I_temp;
		W <= W_temp;
		i_reg <= i_data;
		w_reg <= w_data;
		IIT <= IIT_temp;
		O <= O_temp;
	end
end

always_comb begin
	I_temp = I;
	if (state == INPUT_I) begin
		if (counter == 0) I_temp[0][0] = i_reg;
		if (counter <= 127) I_temp[x][y] = i_data;
	end
end

assign w_ready = (state == W_READY) ? 1 : 0;

always_comb begin
	W_temp = W;
	if (state == INPUT_W) begin
		if (counter <= 7) begin
			W_temp = W_temp << 8;
			W_temp[7] = w_reg;
		end
	end
end

//---------------------------------------------------------------------
//   I * I_Transpose                 
//---------------------------------------------------------------------

assign x = ((counter + 1) >> 4);
assign y = j;

assign i = x - 1;
assign j = (counter % 16) + 1 ;

assign j_prime = j - 3;

assign pipe_8_8_module_valid = (state == INPUT_I) || (state == INPUT_W);

assign ic = (state == INPUT_I) ? i : counter;
assign jc = (state == INPUT_I) ? j : 7;

piped_8_8 n0  (I[ic][0], I[jc][0], rst_n, clk, pipe_8_8_module_valid, RC_product[0]);
piped_8_8 n1  (I[ic][1], I[jc][1], rst_n, clk, pipe_8_8_module_valid, RC_product[1]);
piped_8_8 n2  (I[ic][2], I[jc][2], rst_n, clk, pipe_8_8_module_valid, RC_product[2]);
piped_8_8 n3  (I[ic][3], I[jc][3], rst_n, clk, pipe_8_8_module_valid, RC_product[3]);
piped_8_8 n4  (I[ic][4], I[jc][4], rst_n, clk, pipe_8_8_module_valid, RC_product[4]);
piped_8_8 n5  (I[ic][5], I[jc][5], rst_n, clk, pipe_8_8_module_valid, RC_product[5]);
piped_8_8 n6  (I[ic][6], I[jc][6], rst_n, clk, pipe_8_8_module_valid, RC_product[6]);
piped_8_8 n7  (I[ic][7], I[jc][7], rst_n, clk, pipe_8_8_module_valid, RC_product[7]);
piped_8_8 n8  (I[ic][8], I[jc][8], rst_n, clk, pipe_8_8_module_valid, RC_product[8]);
piped_8_8 n9  (I[ic][9], I[jc][9], rst_n, clk, pipe_8_8_module_valid, RC_product[9]);
piped_8_8 n10 (I[ic][10], I[jc][10], rst_n, clk, pipe_8_8_module_valid, RC_product[10]);
piped_8_8 n11 (I[ic][11], I[jc][11], rst_n, clk, pipe_8_8_module_valid, RC_product[11]);
piped_8_8 n12 (I[ic][12], I[jc][12], rst_n, clk, pipe_8_8_module_valid, RC_product[12]);
piped_8_8 n13 (I[ic][13], I[jc][13], rst_n, clk, pipe_8_8_module_valid, RC_product[13]);
piped_8_8 n14 (I[ic][14], I[jc][14], rst_n, clk, pipe_8_8_module_valid, RC_product[14]);
piped_8_8 n15 (I[ic][15], I[jc][15], rst_n, clk, pipe_8_8_module_valid, RC_product[15]);

assign new_val =  RC_product[0] + RC_product[1] + RC_product[2] + RC_product[3] + RC_product[4] + 
				  RC_product[5] + RC_product[6] + RC_product[7] + RC_product[8] + RC_product[9] + 
				  RC_product[10] + RC_product[11] + RC_product[12] + RC_product[13] + RC_product[14] + 
				  RC_product[15];

always_comb begin
	IIT_temp = IIT;
	if (state == INPUT_I) begin 
		if ((counter-3) == 15) begin
			IIT_temp[i][j_prime] = new_val;
		end else if (31 <= (counter - 3) && (counter - 3) <= 32) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end else if (47 <= (counter - 3) && (counter - 3) <= 49) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end else if (63 <= (counter - 3) && (counter - 3) <= 66) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end else if (79 <= (counter - 3) && (counter - 3) <= 83) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end else if (95 <= (counter - 3) && (counter - 3) <= 100) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end else if (111 <= (counter - 3) && (counter - 3) <= 117) begin
			IIT_temp[i][j_prime] = new_val;
			IIT_temp[j_prime][i]= new_val;
		end 
	end else if (state == INPUT_W) begin
		if (counter >= 3) begin
			IIT_temp[7][counter-3] = new_val;
			IIT_temp[counter-3][7] = new_val;
		end
	end else if (state == RAT) begin
		IIT_temp[counter][0] = (IIT[counter][0] < avg[counter]) ? 0 : IIT[counter][0];
		IIT_temp[counter][1] = (IIT[counter][1] < avg[counter]) ? 0 : IIT[counter][1];
		IIT_temp[counter][2] = (IIT[counter][2] < avg[counter]) ? 0 : IIT[counter][2];
		IIT_temp[counter][3] = (IIT[counter][3] < avg[counter]) ? 0 : IIT[counter][3];
		IIT_temp[counter][4] = (IIT[counter][4] < avg[counter]) ? 0 : IIT[counter][4];
		IIT_temp[counter][5] = (IIT[counter][5] < avg[counter]) ? 0 : IIT[counter][5];
		IIT_temp[counter][6] = (IIT[counter][6] < avg[counter]) ? 0 : IIT[counter][6];
		IIT_temp[counter][7] = (IIT[counter][7] < avg[counter]) ? 0 : IIT[counter][7];
	end
end

/*function [19:0] row_column_product (input [0:15][7:0] a, input [0:15][7:0] b);
    reg [15:0][19:0] products;
    integer i;
   
    for (i = 0; i < 16; i = i + 1) begin
        products[i] = a[i] * b[i];
    end
    
    row_column_product = products[0] + products[1] + products[2] + products[3] +
                         products[4] + products[5] + products[6] + products[7] +
                         products[8] + products[9] + products[10] + products[11] +
                         products[12] + products[13] + products[14] + products[15];
endfunction*/

//---------------------------------------------------------------------
//   RAT                 
//---------------------------------------------------------------------

assign IIT_rows_sum[0] = IIT[0][0] + IIT[0][1] + IIT[0][2] + IIT[0][3] + IIT[0][4] + IIT[0][5] +
                         IIT[0][6] + IIT[0][7];
                         
assign IIT_rows_sum[1] = IIT[1][0] + IIT[1][1] + IIT[1][2] + IIT[1][3] + IIT[1][4] + IIT[1][5] +
                         IIT[1][6] + IIT[1][7];
                         
assign IIT_rows_sum[2] = IIT[2][0] + IIT[2][1] + IIT[2][2] + IIT[2][3] + IIT[2][4] + IIT[2][5] +
                         IIT[2][6] + IIT[2][7];
                         
assign IIT_rows_sum[3] = IIT[3][0] + IIT[3][1] + IIT[3][2] + IIT[3][3] + IIT[3][4] + IIT[3][5] +
                         IIT[3][6] + IIT[3][7];
                         
assign IIT_rows_sum[4] = IIT[4][0] + IIT[4][1] + IIT[4][2] + IIT[4][3] + IIT[4][4] + IIT[4][5] +
                         IIT[4][6] + IIT[4][7];
                         
assign IIT_rows_sum[5] = IIT[5][0] + IIT[5][1] + IIT[5][2] + IIT[5][3] + IIT[5][4] + IIT[5][5] +
                         IIT[5][6] + IIT[5][7];
                         
assign IIT_rows_sum[6] = IIT[6][0] + IIT[6][1] + IIT[6][2] + IIT[6][3] + IIT[6][4] + IIT[6][5] +
                         IIT[6][6] + IIT[6][7];
                         
assign IIT_rows_sum[7] = IIT[7][0] + IIT[7][1] + IIT[7][2] + IIT[7][3] + IIT[7][4] + IIT[7][5] +
                         IIT[7][6] + IIT[7][7];
						 
assign avg[0] = IIT_rows_sum[0] >> 3;
assign avg[1] = IIT_rows_sum[1] >> 3;
assign avg[2] = IIT_rows_sum[2] >> 3;
assign avg[3] = IIT_rows_sum[3] >> 3;
assign avg[4] = IIT_rows_sum[4] >> 3;
assign avg[5] = IIT_rows_sum[5] >> 3;
assign avg[6] = IIT_rows_sum[6] >> 3;
assign avg[7] = IIT_rows_sum[7] >> 3;

//---------------------------------------------------------------------
//   Matrix * W                
//---------------------------------------------------------------------

always_comb begin
	O_temp = O;
	if (state == CALC_MW)begin
		O_temp[counter-3] = MW_product[0] + MW_product[1] + MW_product[2] + MW_product[3] + MW_product[4] + 
							MW_product[5] + MW_product[6] + MW_product[7];
	end
end

assign pipe_module_valid = (state == CALC_MW);

piped_20_8 no0 (IIT[counter][0], W[0], rst_n, clk, pipe_module_valid, MW_product[0]);
piped_20_8 no1 (IIT[counter][1], W[1], rst_n, clk, pipe_module_valid, MW_product[1]);
piped_20_8 no2 (IIT[counter][2], W[2], rst_n, clk, pipe_module_valid, MW_product[2]);
piped_20_8 no3 (IIT[counter][3], W[3], rst_n, clk, pipe_module_valid, MW_product[3]);
piped_20_8 no4 (IIT[counter][4], W[4], rst_n, clk, pipe_module_valid, MW_product[4]);
piped_20_8 no5 (IIT[counter][5], W[5], rst_n, clk, pipe_module_valid, MW_product[5]);
piped_20_8 no6 (IIT[counter][6], W[6], rst_n, clk, pipe_module_valid, MW_product[6]);
piped_20_8 no7 (IIT[counter][7], W[7], rst_n, clk, pipe_module_valid, MW_product[7]);

/*function [31:0] matrix_weight_product (input [0:7][19:0] a, input [0:7][7:0] b);
    reg [7:0][31:0] products;
    integer i;

    for (i = 0; i < 8; i = i + 1) begin
        products[i] = a[i] * b[i];
    end

    matrix_weight_product = products[0] + products[1] + products[2] + products[3] +
                            products[4] + products[5] + products[6] + products[7];
endfunction*/


//---------------------------------------------------------------------
//   Output                
//---------------------------------------------------------------------

assign o_valid = (state == OUTPUT) ? 1 : 0;
assign o_data = (state == OUTPUT) ? O[counter] : 0;

endmodule



//---------------------------------------------------------------------
//   Pipelined 20-bit * 8-bit                
//---------------------------------------------------------------------

module piped_20_8(
	in_1,
	in_2,
	rst_n,
	clk,
	in_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [19:0] in_1;
input [7:0] in_2;
input rst_n, clk;
input in_valid;
output logic [27:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] A_a, A_b, A_c, A_d, A_e;
logic [3:0] B_a, B_b;
logic [0:9][7:0] arr;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff@(posedge clk) begin
	if (in_valid) begin
		{A_a, A_b, A_c, A_d, A_e} <= in_1; //[19:16][15:12][11:8][7:4][3:0]
		{B_a, B_b} <= in_2; //[7:4][3:0]
	end
	else begin
		{A_a, A_b, A_c, A_d, A_e} <= 0; //[19:16][15:12][11:8][7:4][3:0]
		{B_a, B_b} <= 0; //[7:4][3:0]
	end
end

// change to 7

always_ff@(posedge clk) begin
	arr[0] <= A_a * B_a; //product(20, A_a, B_a);
	arr[1] <= A_a * B_b; //product(16, A_a, B_b);
	
	arr[2] <= A_b * B_a; //product(16, A_b, B_a); 
	arr[3] <= A_b * B_b; //product(12, A_b, B_b);
	
	arr[4] <= A_c * B_a; //product(12, A_c, B_a);
	arr[5] <= A_c * B_b; //product(8, A_c, B_b); 
	
	arr[6] <= A_d * B_a; //product(8, A_c, B_a);
	arr[7] <= A_d * B_b; //product(4, A_c, B_b); 
	
	arr[8] <= A_e * B_a; //product(4, A_c, B_a);
	arr[9] <= A_e * B_b; //product(0, A_c, B_b); 
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) out <= 0;
	else out <= (arr[0] << 20) + ((arr[1] + arr[2]) << 16) + ((arr[3] + arr[4]) << 12) + ((arr[5] + arr[6]) << 8) + 
				((arr[7] + arr[8]) << 4) + (arr[9] << 0);
end
endmodule 

//---------------------------------------------------------------------
//   Pipelined 8-bit * 8-bit                
//---------------------------------------------------------------------

module piped_8_8(
	in_1,
	in_2,
	rst_n,
	clk,
	in_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [7:0] in_1;
input [7:0] in_2;
input rst_n, clk;
input in_valid;
output logic [15:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] A_a, A_b;
logic [3:0] B_a, B_b;
logic [0:3][7:0] arr;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff@(posedge clk) begin
	if (in_valid) begin
		{A_a, A_b} <= in_1; //[7:4][3:0]
		{B_a, B_b} <= in_2; //[7:4][3:0]
	end
	else begin
		{A_a, A_b} <= 0; //[7:4][3:0]
		{B_a, B_b} <= 0; //[7:4][3:0]
	end
end

always_ff@(posedge clk) begin
	arr[0] <= A_a * B_a; //product(8, A_a, B_a);
	arr[1] <= A_a * B_b; //product(4, A_a, B_b);
	
	arr[2] <= A_b * B_a; //product(4, A_b, B_a); 
	arr[3] <= A_b * B_b; //product(0, A_b, B_b);
	
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) out <= 0;
	else out <= (arr[0] << 8) + ((arr[1] + arr[2]) << 4) + arr[3];
end
endmodule 
