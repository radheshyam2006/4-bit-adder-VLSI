

module cla (
    input [3:0] A,
    input [3:0] B, 
    output reg [4:0] F,
    input cin
    );
reg [3:0] g;
reg [3:0] p;
reg [4:0] ci;
 always @(*) begin
        ci[0]=cin;
        
        p[0] = A[0] ^ B[0]; g[0] = A[0] & B[0]; 
        p[1] = A[1] ^ B[1]; g[1] = A[1] & B[1];
        p[2] = A[2] ^ B[2]; g[2] = A[2] & B[2]; 
        p[3] = A[3] ^ B[3]; g[3] = A[3] & B[3]; 
        
        ci[1] = g[0] | (p[0] & ci[0]);
        ci[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & ci[0]);
        ci[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & ci[0]);
        ci[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & ci[0]);

        F[0]=p[0]^ci[0];
        F[1]=p[1]^ci[1];
        F[2]=p[2]^ci[2];
        F[3]=p[3]^ci[3];
        
        F[4] = ci[4];         
    end
endmodule

module input4_flip_flop(
	input [3:0]i,
	input clk,
    output reg [3:0]out);

always @(posedge clk)
    begin
		out <= i;
	end
endmodule

module input1_flip_flop(
	input i,
	input clk,
    output reg out);

always @(posedge clk)
    begin
		out <= i;
	end
endmodule

// `include "input4_flip_flop.v"
// `include "input1_flip_flop.v"
// `include "cla.v"


module wrap(
    input [3:0] a,
    input [3:0] b,
    input clk,
    input cin,
    output [4:0] c);
    wire [3:0] da;  
    wire [3:0] db;
    wire [4:0] df;
    input4_flip_flop da_inst (
        .i(a),
        .clk(clk),
        .out(da)
    ); 
    input4_flip_flop db_inst (
        .i(b),
        .clk(clk),
        .out(db)
    );
    input4_flip_flop sum (
        .i(df[3:0]),
        .clk(clk),
        .out(c[3:0])
    ); 
    input1_flip_flop carry (
        .i(df[4]),
        .clk(clk),
        .out(c[4])
    );
    cla cla_inst (
        .A(da),
        .B(db), 
        .F(df),
        .cin(cin)
    );
endmodule
