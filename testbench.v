`timescale 1ns / 1ps

module TrainTrafficControl_tb;


    reg clk;
    reg reset;
    reg [3:0] train_request;
    reg train_done;

    wire [2:0] grant;

    TrainTrafficControl uut (
        .clk(clk),
        .reset(reset),
        .train_request(train_request),
        .train_done(train_done),
        .grant(grant)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        train_request = 4'b0000;
        train_done = 0;

        $dumpfile("TrainTrafficControl_tb.vcd");
        $dumpvars(0, TrainTrafficControl_tb);
        
        #10 reset = 0;

// Test 1: Request by Train 1
        #10 train_request = 4'b0001;
        #50 train_done = 1;  
        #10 train_done = 0;

// Test 2: Simultaneous request from Train 1 and 4
        #10 train_request = 4'b1001; 
        #50 train_done = 1;
        #10 train_done = 0;

// Test 3: Request by Train 3
        #10 train_request = 4'b0100;
        #50 train_done = 1;
        #10 train_done = 0;

// Test 4: done signal not sent
        #10 train_request = 4'b0010;
        #60; 

// Test 5: Multiple Quick Swiching
        train_done = 1;
        train_request = 4'b1100;
        #10 train_done = 0;
        #20 train_done = 1;
        train_request = 4'b0000;
        #10 train_done = 0;

        #50 $finish;
    end

endmodule
