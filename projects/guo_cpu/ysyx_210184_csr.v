
`include "defines.v"

module ysyx_210184_csr(
    input  wire clk,
	input  wire rst,

	input  wire is_ecall,
	input  wire is_mret, 
	
	input  wire  [11  : 0] w_addr,
	input  wire  [`REG_BUS-1 : 0] w_data,
	input  wire 		   w_ena,
	input  wire  [1   : 0] w_mode,
	
	input  wire  [11  : 0] r_addr,
	output wire  [`REG_BUS-1 : 0] r_data,

	output wire [`REG_BUS-1 : 0] csr_mtvec_o,
	output wire [`REG_BUS-1 : 0] csr_mepc_o,
	output wire                  MIE,
	output wire                  MTIE,
	output wire                  MEIE,
	output wire                  MSIE,
	input wire  [`REG_BUS-1 : 0] pc_from_ex,

	input wire                   inst_valid,
	input wire                   mtime_intr_i,
	input wire                   mtime_intr_enable_i,
	input wire                   ext_intr_i,
	input wire                   ext_intr_enable_i,
	input wire                   software_intr_i,
	input wire                   software_intr_enable_i,
	input wire [`REG_BUS-1 : 0]  pc_intr

	// output wire r_exception,
	// output wire w_exception
	
    );

	//port define 
	wire [63:0] misa;// R W, implement just R
	wire r_misa;
	wire [63:0] mvendorid;// R only
	wire r_mvendorid;
	wire [63:0] marchid;// R only
	wire r_marchid;
	wire [63:0] mimpid;// R only
	wire r_mimpid;
	wire [63:0] mhartid;// R only
	wire r_mhartid;
	reg [63:0] mstatus;
	wire [63:0] mstatus_wire;
	wire r_mstatus, w_mstatus;
	reg [63:0] mepc;
	// wire [63:0] mepc_wire;
	wire r_mepc, w_mepc;
	reg [63:0] mcause;
	wire r_mcause, w_mcause;
	reg [63:0] mtvec;
	wire [63:0] mtvec_wire;
	wire r_mtvec, w_mtvec;
	reg [63:0] mstratch;
	wire [63:0] mstratch_wire;
	wire r_mstratch, w_mstratch;
    reg [63:0] mcycle;
    wire r_mcycle, w_mcycle;
    reg [63:0] minstret;
    wire r_minstret, w_minstret;
	reg [63:0] mip;
	wire r_mip;
	reg [63:0] mie;
	wire r_mie, w_mie;
	reg [`REG_BUS-1 : 0] to_write;
	//port define end

	// reg is_in_trap;
	// always @(posedge clk) begin
	// 	if(~rst) is_in_trap <= 1'b0;
	// 	else begin
	// 		if(trap_event) is_in_trap <= 1'b1;
	// 		else if(is_mert) is_in_trap <= 1'b0;
	// 		else is_in_trap <= is_in_trap;
	// 	end
		
	// end

	assign MIE = mstatus[3];
	assign MTIE = mie[7];
	assign MEIE = mie[11];
	assign MSIE = mie[3];

	assign csr_mtvec_o = mtvec;
	assign csr_mepc_o = mepc;

	// assign w_misa = w_addr == 12'h301;
	assign r_misa = r_addr == 12'h301;
	assign misa = 64'b10_000000000000000000000000000000000000_00000000000000000100000000;


	assign r_mvendorid = r_addr == 12'hf11;
	assign mvendorid = 64'h42206c6f7665204d;


	assign r_marchid = r_addr == 12'hf12;
	assign marchid = 64'h79737978337264;


	assign r_mimpid = r_addr == 12'hf13;
	assign mimpid = 64'b0;


	assign r_mhartid = r_addr == 12'hf14;
	assign mhartid = 64'b0;


	assign r_mstatus = r_addr == 12'h300;
	assign w_mstatus = w_addr == 12'h300;
	assign mstatus_wire = w_mstatus ? {to_write[16:15]==2'b11 | to_write[14:13]==2'b11, // SD
										27'b0,
										13'b0,
										10'b0,
										2'b11, //MPP
										3'b000,
										to_write[7], //MPIE
										3'b0,
										to_write[3], //MIE
										3'b0} :
							(is_ecall | mtime_intr_enable_i | ext_intr_enable_i | software_intr_enable_i) ? {mstatus[63:8], mstatus[3], mstatus[6:4],       1'b0, mstatus[2:0]} :
							is_mret  ? {mstatus[63:8],       1'b1, mstatus[6:4], mstatus[7], mstatus[2:0]} : mstatus;
	always @(posedge clk) begin
		if(rst) mstatus <= {1'b0, 50'b0, 2'b11, 3'b0, 1'b1, 3'b0, 1'b0, 3'b0};
		else if(w_ena | is_ecall | is_mret | mtime_intr_enable_i | ext_intr_enable_i | software_intr_enable_i) mstatus <= mstatus_wire;
		else mstatus <= mstatus;
	end

	assign r_mepc = r_addr == 12'h341;
	assign w_mepc = w_addr == 12'h341;
	always @(posedge clk) begin
		if(rst) mepc <= 64'b0;
		else begin
			if(w_ena) mepc <= w_mepc ? to_write : mepc;
			else if(mtime_intr_enable_i | ext_intr_enable_i | software_intr_enable_i) mepc <= pc_intr;
			else if(is_ecall) mepc <= pc_from_ex;
			else mepc <= mepc;
		end
	end

	assign r_mcause = r_addr == 12'h342;
	assign w_mcause = w_addr == 12'h342;
	always @(posedge clk) begin
		if(rst) mcause <= 64'b0;
		else begin
			if(w_ena) mcause <= w_mcause ? to_write : mcause;
			else if(mtime_intr_enable_i) mcause <= {1'b1, 59'b0, 4'd7};   // mtime priority level 1
			else if(ext_intr_enable_i) mcause <= {1'b1, 59'b0, 4'd11};    // ext   priority level 2
			else if(software_intr_enable_i) mcause <= {1'b1, 59'b0, 4'd3};// software   priority level 3
			else if(is_ecall) mcause <= {1'b0, 59'b0, 4'd11};
			else mcause <= mcause;
		end
	end

	assign r_mtvec = r_addr == 12'h305;
	assign w_mtvec = w_addr == 12'h305;
	assign mtvec_wire = w_mtvec ? to_write : mtvec;
	always @(posedge clk) begin
		if(rst) mtvec <= 64'b0;
		else if(w_ena) mtvec <= {mtvec_wire[63:2], 2'b00 & mtvec_wire[1:0]};
		else mtvec <= {mtvec[63:2], 2'b00 & mtvec[1:0]};
	end


	assign r_mstratch = r_addr == 12'h340;
	assign w_mstratch = w_addr == 12'h340;
	assign mstratch_wire = w_mstratch ? to_write : mstratch;
	always @(posedge clk) begin
		if(rst) mstratch <= 64'b0;
		else if(w_ena) mstratch <= mstratch_wire;
		else mstratch <= mstratch;
	end

    assign r_mcycle = r_addr == 12'hb00;
    assign w_mcycle = w_addr == 12'hb00;
    always @(posedge clk) begin
        if(rst) mcycle <= 64'b0;
        else mcycle <= w_mcycle ? to_write : mcycle + 1'b1;
    end

    assign r_minstret = r_addr == 12'hb02;
    assign w_minstret = w_addr == 12'hb02;
    always @(posedge clk) begin
        if(rst) minstret <= 64'b0;
        else minstret <= w_minstret ? to_write : minstret + {63'b0, inst_valid};
    end

	assign r_mip = r_addr == 12'h344;
	always @(posedge clk) begin
		if(rst) mip <= 64'b0;
		else mip <= {52'b0, ext_intr_i, 3'b0, mtime_intr_i, 3'b0, software_intr_i, 3'b0};
	end


	assign r_mie = r_addr == 12'h304;
	assign w_mie = r_addr == 12'h304;
	always @(posedge clk) begin
		if(rst) mie <= 64'b0;
		else if(w_ena) mie <= w_mie ? {52'b0, to_write[11], 3'b0, to_write[7], 3'b0, to_write[3], 3'b0} : mie;
		else mie <= mie;
	end

	assign r_data = {64{r_misa}}      & misa      | 
					{64{r_mvendorid}} & mvendorid |
					{64{r_marchid}}   & marchid   |
					{64{r_mimpid}}    & mimpid    |
					{64{r_mhartid}}   & mhartid   |
					{64{r_mstatus}}   & mstatus   |
					{64{r_mtvec}}     & mtvec     |
					{64{r_mstratch}}  & mstratch  |
					{64{r_mcycle}}    & mcycle    |
					{64{r_mepc}}      & mepc      |
					{64{r_mcause}}    & mcause    |
					{64{r_minstret}}  & minstret  |
					{64{r_mip}}       & mip       |
					{64{r_mie}}       & mie       ;


	always @(*) begin
		case(w_mode)
			2'b00: to_write = 64'b0;
			2'b01: to_write = w_data;
			2'b10: to_write = r_data | w_data;
			2'b11: to_write = r_data & (~w_data);
		endcase
	end


	


endmodule
