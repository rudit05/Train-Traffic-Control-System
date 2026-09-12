module top_module (input clk, rst,
                   input [3:0] train_req,
                   output [2:0] approved_train);
            
    wire req_valid, req_accepted;
    wire [3:0] train_req_temp;
    
    sender inst1(clk, rst, req_accepted, train_req, req_valid, train_req_temp);
    TTCS inst2(clk, rst, req_valid, train_req_temp, approved_train, req_accepted);
    
    
endmodule
