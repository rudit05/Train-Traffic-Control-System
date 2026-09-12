module sender(input clk, rst, req_accepted,
              input [3:0] train_req,
              output reg req_valid,
              output reg [3:0] train_req_out);
              
    reg req_accepted_shift;
              
    always @(posedge clk) begin
        if(rst) begin
            req_valid <= 1'b0;
            train_req_out <= 4'd0;
            req_accepted_shift <= 1'b00;
        end
        else begin
            req_accepted_shift <= req_accepted;
            if(!req_valid && !req_accepted && (train_req != 4'b0000) && (train_req != train_req_out)) begin
                req_valid <= 1;
                train_req_out <= train_req;
            end
            else if(~req_accepted_shift && req_accepted && req_valid) begin
                req_valid <= 0;
            end
        end
    end
    
    
endmodule
