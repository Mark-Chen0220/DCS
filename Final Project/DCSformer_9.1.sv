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

logic [7:0] i_reg, w_reg;

logic [6:0] counter, counter_next;

logic [0:7][31:0] O, O_temp;

logic [0:7][0:15][7:0] I, I_temp; //8 * 16 matrix;
logic [0:7][7:0] W, W_temp; //8 * 1 matrix;
logic [0:7][0:7][19:0] IIT, IIT_temp; //8 * 16 matrix;

logic [3:0] i,j, x,y; 

logic [19:0] new_val;

logic [0:7][23:0] IIT_rows_sum;
logic [0:7][20:0] avg;

logic [20:0] Test;

enum logic [2:0] {IDLE, INPUT_I, W_READY, WAIT_W_VALID, INPUT_W, RAT, CALC_MW, OUTPUT} state, next_state;
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
            next_state = (counter == 127) ? W_READY : INPUT_I;
            counter_next = (counter == 127) ? 0 : counter + 1 ;
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
            next_state = (counter == 7) ? RAT: INPUT_W;
			counter_next = (counter == 7) ? 0 : counter + 1;
        end
		RAT: begin
			next_state = (counter == 7) ? CALC_MW : RAT;
            counter_next = (counter == 7) ? 0 : counter + 1 ;
		end
		CALC_MW: begin
			next_state = (counter == 7) ? OUTPUT : CALC_MW;
            counter_next = (counter == 7) ? 0 : counter + 1 ;
		end
        OUTPUT: begin
            next_state = (counter == 7) ? IDLE : OUTPUT;
            counter_next = (counter == 7) ? 0 : counter + 1 ;
        end
		default: begin
			next_state = state;
			counter_next = counter;
			//counter2_next = counter2;
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
		I_temp[x][y] = i_data;
	end
end

assign w_ready = (state == W_READY) ? 1 : 0;

always_comb begin
	W_temp = W;
	if (state == INPUT_W) begin
		W_temp = W_temp << 8;
		W_temp[7] = w_reg;
	end
end

//15
//31
//47
//63
//79
//95
//111
//127

//---------------------------------------------------------------------
//   I * I_Transpose                 
//---------------------------------------------------------------------

assign x = ((counter + 1) >> 4);
assign y = j;

assign i = x - 1;
assign j = (counter % 16) + 1 ;


always_comb begin
	IIT_temp = IIT;
	new_val = 0;
	if (state == INPUT_I) begin 
		new_val = row_column_product(I[i], I[j]);
		if (counter == 15) begin
			IIT_temp[i][j] = new_val;
		end else if (31 <= counter && counter <= 32) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end else if (47 <= counter && counter <= 49) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end else if (63 <= counter && counter <= 66) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end else if (79 <= counter && counter <= 83) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end else if (95 <= counter && counter <= 100) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end else if (111 <= counter && counter <= 117) begin
			IIT_temp[i][j] = new_val;
			IIT_temp[j][i] = new_val;
		end 
	end else if (state == INPUT_W) begin
		new_val = row_column_product(I[7], I[counter]);
		IIT_temp[7][counter] = new_val;
		IIT_temp[counter][7] = new_val;
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

function [19:0] row_column_product (input [0:15][7:0] a, input [0:15][7:0] b);
	row_column_product = a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3] +
						 a[4] * b[4] + a[5] * b[5] + a[6] * b[6] + a[7] * b[7] +
						 a[8] * b[8] + a[9] * b[9] + a[10] * b[10] + a[11] * b[11] + 
						 a[12] * b[12] + a[13] * b[13] + a[14] * b[14] + a[15] * b[15]; 
endfunction

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
		O_temp[counter] = matrix_weight_product(IIT[counter],W);
	end
end

function [31:0] matrix_weight_product (input [0:7][19:0] a, input [0:7][7:0] b);
	matrix_weight_product = a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3] +
						 a[4] * b[4] + a[5] * b[5] + a[6] * b[6] + a[7] * b[7];
endfunction

//---------------------------------------------------------------------
//   Output                
//---------------------------------------------------------------------

assign o_valid = (state == OUTPUT) ? 1 : 0;
assign o_data = (state == OUTPUT) ? O[counter] : 0;

endmodule

