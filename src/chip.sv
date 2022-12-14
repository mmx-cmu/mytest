`default_nettype none

module mmx_chip (
  input logic [7:0] io_in,
  output logic [7:0] io_out
);
    
    logic clk;
    logic [15:0] C;
    assign clk = io_in[0];

    mymult mul(.clk, .A(8'd1), .B(io_in), .C);

    always @(posedge clk) begin

    end

    assign io_out = C[7:0];

endmodule

// pipelined multiplier - always takes 3 cycles

module mymult
 (input logic clk,
  input logic [7:0] A,
  input logic [7:0] B,
  output logic [15:0] C
  );

  logic [7:0][7:0] partials;
  logic [7:0][7:0] partials_flopped;
  logic [15:0][4] sum0;

  // cycle 1: compute partials
  genvar i;
  generate
    for (i = 0; i < 8; i++) begin
      assign partials[i] = {8{A[i]}} & B[7:0];
    end
  endgenerate

  always_ff @(posedge clk) begin
    partials_flopped <= partials;
  end

  // cycle 2: add partials
  generate
    for (i = 0; i < 4; i++) begin
      always_ff @(posedge clk) begin
        sum0[i] <= (partials_flopped[i*2] << i*2) +
                   (partials_flopped[i*2 + 1] << (i * 2 + 1));
      end
    end
  endgenerate

  logic [15:0][2] sum1;
  assign sum1[0] = sum0[0] + sum0[1];
  assign sum1[1] = sum0[2] + sum0[3];

  // cycle 3: add partials
  always_ff @(posedge clk) begin
    C <= sum1[0] + sum1[1];
  end

endmodule : mymult
