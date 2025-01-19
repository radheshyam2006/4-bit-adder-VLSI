

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
module nand_gate(
    input a,
    input b,
    output out
);
    assign out = ~(a & b);
endmodule

module dlatch(
    input d,
    input clk,
    output q,
    output qn
);
    wire n1, n2;
    nand_gate nand1(.a(d), .b(clk), .out(n1));
    nand_gate nand2(.a(~d), .b(clk), .out(n2));
    nand_gate nand3(.a(n1), .b(qn), .out(q));
    nand_gate nand4(.a(n2), .b(q), .out(qn));
endmodule

module dff(
    input d,
    input clk,
    output q,
    output qn
);
    wire master_q, master_qn;
    dlatch master(
        .d(d),
        .clk(~clk),
        .q(master_q),
        .qn(master_qn)
    );
    dlatch slave(
        .d(master_q),
        .clk(clk),
        .q(q),
        .qn(qn)
    );
endmodule

module input4_flip_flop(
    input [3:0] i,
    input clk,
    output [3:0] out
);
    wire [3:0] qn_unused;
    dff dff0(.d(i[0]), .clk(clk), .q(out[0]), .qn(qn_unused[0]));
    dff dff1(.d(i[1]), .clk(clk), .q(out[1]), .qn(qn_unused[1]));
    dff dff2(.d(i[2]), .clk(clk), .q(out[2]), .qn(qn_unused[2]));
    dff dff3(.d(i[3]), .clk(clk), .q(out[3]), .qn(qn_unused[3]));
endmodule

module input1_flip_flop(
    input i,
    input clk,
    output out
);
    wire qn_unused;
    dff dff(.d(i), .clk(clk), .q(out), .qn(qn_unused));
endmodule

// `include "input4_flip_flop.v"
// `include "input1_flip_flop.v"
// `include "cla.v"

module wrap(
    input [3:0] a,
    input [3:0] b,
    input clk,
    input cin,
    output [4:0] c
);
    wire [3:0] da;   
    wire [3:0] db;
    wire [4:0] df;
    wire dcin;

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

    input1_flip_flop cin_inst (
        .i(cin),
        .clk(clk),
        .out(dcin)
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
        .cin(dcin)
    );
endmodule