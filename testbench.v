`timescale 1ns/1ps

module tb_TrainTrafficControl;

  reg clk;
  reg reset;
  reg [3:0] train_request;
  reg train_done;
  wire [2:0] grant;

  TrainTrafficControl dut (
    .clk(clk),
    .reset(reset),
    .train_request(train_request),
    .train_done(train_done),
    .grant(grant)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    reset = 1;
    train_request = 4'b0000;
    train_done = 0;

    #20;
    reset = 0;

    //Test IDLE
    train_request = 4'b0000;  
    train_done = 0;
    #30;

    //Test GRANT_T1
    train_request = 4'b0001;  
    train_done = 0;
    #10;
    #30;
    train_done = 1;        
    #10;
    train_done = 0;
    #20;

    //Test GRANT_T2
    train_request = 4'b0010;  
    train_done = 0;
    #10;
    #30;
    train_done = 1;          
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;  
    #20;

    //Test GRANT_T3
    train_request = 4'b0100;  
    train_done = 0;
    #10;
    #30;
    train_done = 1;     
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;
    #20;

    //Test GRANT_T4
    train_request = 4'b1000;  
    train_done = 0;
    #10;
    #30;
    train_done = 1;          
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;
    #20;

    //Test Timeout from GRANT_T1 
    train_request = 4'b0001;  
    train_done = 0;
    
    #70;
    
    $finish;
  end

  initial begin
    $display("Time\treset\ttrain_req\ttrain_done\tgrant");
    $monitor("%0t\t%b\t%04b\t\t%b\t\t%03b", $time, reset, train_request, train_done, grant);
  end

endmodule
