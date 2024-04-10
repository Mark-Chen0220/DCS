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

parameter S_idle = 'd0;
parameter S_input = 'd1;
parameter S_output = 'd2;

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


reg [1:0] state, next_state;
reg [3:0] index, index_next;
reg [5:0] ID [9:0];
reg [8:0] sum;
reg [3:0] remainder;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

	always_ff @(negedge clk or negedge rst_n) begin
		if(!rst_n)
			state <= S_idle;
		else 
			state <= next_state;
	end	
	
	always_ff @(posedge in_valid or negedge clk) begin
        if (state == S_input) begin
            index <= index_next;
        end
        else
            index <= 0;
    end
    
    always_comb begin
        next_state = state;
        case (state)
            S_idle: if (in_valid) next_state = S_input;
            S_input: if (index == 4'd10) next_state = S_output;
            S_output: next_state = S_idle;
        endcase
    end

	always_comb begin
		case(state)
			S_idle: begin
				out_valid = 0;
				out_legal_id = 0;
				sum = 0;
			end
			
			S_input: begin
				if (in_valid && index < 10) begin
                index_next = index + 1;
                ID[index] = in_id;
                    if(index == 0)begin
                        sum = in_id / 10 + (in_id % 10) * 9;
                    end else if(index != 9) 
                        sum = sum + in_id * (9 - index); //(9-index) is the weight.
                end
			end
			
			S_output: begin
				out_valid = 1;
				remainder = sum % 10;	
				if (10 - remainder == ID[9])
					out_legal_id = 1;
				else if (remainder == 0 && ID[9] == 0)
					out_legal_id = 1;
				else 
					out_legal_id = 0;
			end
			
			default: begin
				remainder = 0;
				sum = 0;
			end
			
		endcase
	end

endmodule