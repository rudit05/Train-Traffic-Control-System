module TB();
  wire [2:0] approved_train;
  reg clk, rst;
  reg [3:0] train_req;
  
  always #5 clk = ~clk;
  
  top_module dut(clk, rst, train_req, approved_train);
  
  initial begin
    clk = 1;
    rst = 1;
    #15 rst = 0; train_req = 4'b1100;
    #200 train_req = 4'b0110;
    $dumpfile ("out.vcd");
    $dumpvars (0, TB);
    #200 $finish;
  end
  
endmodule
  
  
    
  
