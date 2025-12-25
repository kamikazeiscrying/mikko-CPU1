`timescale 1ns / 1ps

// ROM 作为只读存储，用于保存我们预先编译好的程序，在 CPU 运行后从 ROM 的 0 号地址读取第一条指令开始执行。
// 在 MIPS 指令集规范中规定初始地址为 0Xbfc00000，因此这里的初始地址即为 PC 与初始值相减后的相对 0 号地址。
// ROM 中的写使能与写数据端口实际未被使用。（只读存储器）

`include "bus.v"
`include "pcdef.v"
`include "sim.v"

module ROM(
  input                       clk,
  input                       rst,
  
  input       [`MEM_SEL_BUS]  rom_write_en,
  input       [`DATA_BUS]     rom_write_data,
//实际未用到
  input                       rom_en,
  input       [`ADDR_BUS]     rom_addr,
  output  reg [`DATA_BUS]     rom_read_data//32位
);
//  存储器可以存储8位宽的指令
  reg[7:0] inst_mem[`INST_MEM_BUS];
//`define INST_MEM_ADDR_WIDTH   8
////指令存储器的地址宽度是8位
//`define INST_MEM_SIZE         2 ** `INST_MEM_ADDR_WIDTH
////计算地址宽度为8位时的存储器大小
//`define INST_MEM_BUS          `INST_MEM_SIZE - 1:0

  // initialize with program
  always @(posedge clk) begin
    if (rst) begin
//      { inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'hffff_0824;        //addiu$8,$0,-1
//      { inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0200_0924;        //addiu $9,$0,2   24_09_00_02
//      { inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h2150_0901;      //addu $10,$8,$9
//      { inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h1800_0901;    //mult $8,$9
//      { inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] } <= 32'h0000_f00b;    //j 66060288#跳到ROM初始地址
//      { inst_mem[23],inst_mem[22],inst_mem[21],inst_mem[20] } <= 32'h0200_0924;    //addiu $9,$0,2


//      { inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'hffff_0124;//addiu $1, $0, -1# 将 1 号寄存器赋值为 -1
//      { inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0200_0224;// addiu $2, $0, 2# 将 2 号寄存器赋值为 2
//      { inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h2118_2200;//addu $3, $1, $2# 寄存器 1 和 2 的值相加，赋给 3 号寄存器=1
//      { inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h0000_438c;// lw $3, 0($2)# 3号寄存器的值1，存入存储到内存地址$2 + 0处
//      { inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] } <= 32'h0000_44ac;// sw $4, 0($2)# 取出内存地址$2 + 0处的值1，放入4号寄存器=1
//      { inst_mem[23],inst_mem[22],inst_mem[21],inst_mem[20] } <= 32'h1800_2200;// mult $1,$2# 寄存器 1 和 2 的值相乘，-2
//      { inst_mem[27],inst_mem[26],inst_mem[25],inst_mem[24] } <= 32'h0000_438c;//lw $3, 0($2)# 3号寄存器的值1，存入存储到内存地址$2 + 0处
//      { inst_mem[31],inst_mem[30],inst_mem[29],inst_mem[28] } <= 32'h0000_45ac;//sw $5, 0($2) # 取出内存地址$2 + 0处的值1，放入5号寄存器=1
//      { inst_mem[35],inst_mem[34],inst_mem[33],inst_mem[32] } <= 32'h1a00_4100;//div $2,$1# 寄存器 2 和 1 的值相除，-2
//      { inst_mem[39],inst_mem[38],inst_mem[37],inst_mem[36] } <= 32'h0000_f00b;//# 跳到ROM初始地址跳到ROM初始地址
//      { inst_mem[43],inst_mem[42],inst_mem[41],inst_mem[40] } <= 32'h0200_0924;//addiu $9,$0,2


     { inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'hffff_0824;           //addiu$8,$0,-1       $8=-1
     { inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0200_0924;           //addiu $9,$0,2       $9=2
     { inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h2150_0901;         //addu $10,$8,$9    $10=1
     { inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h1800_0901;       //mult $8,$9      $8*$9=-2
     { inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] } <= 32'h1a00_2a01;       //div $9,$10      $9/$10=2
     { inst_mem[23],inst_mem[22],inst_mem[21],inst_mem[20] } <= 32'h0000_f00b;       //j 66060288#跳到ROM初始地址
     { inst_mem[27],inst_mem[26],inst_mem[25],inst_mem[24] } <= 32'h0600_0824;       //addiu$8,$0,-1


//{ inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'hffff_0824;          //addiu$8,$0,-1       $8=-1
//{ inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0200_0924;          //addiu $9,$0,2       $9=2
//{ inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h0a00_28ad;        //sw $8,10($9) #memory[$9+10]=$8
//{ inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h0a00_218d;      //lw $1,10($9) #$1=memory[$9+10] $1=-1
//{ inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] } <= 32'h0000_f00b;      //j 66060288#跳到ROM初始地址
//{ inst_mem[23],inst_mem[22],inst_mem[21],inst_mem[20] } <= 32'h0600_0824;      //addiu$8,$0,-1


//      { inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'hffff_0124;      //# addiu $1, $0, -1将 1 号寄存器赋值为 -1
//      { inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0200_0224;      // # addiu $2, $0, 2将 2 号寄存器赋值为 2
//      { inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h0000_43ac;    //sw $3, 0($2)# 3号寄存器=1存入内存地址$2 + 0处  
//      { inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h0000_448c;  //lw $4, 0($2)# 取出内存地址$2 + 0处的值到4号寄存器
//      { inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] }<= 32'h2118_2200;   //# 寄存器 1 和 2 的值相加，赋给 3 号寄存器=1
//      { inst_mem[23],inst_mem[22],inst_mem[21],inst_mem[20] } <= 32'h0000_43ac;  //sw $3, 0($2)# 3号寄存器=1存入内存地址$2 + 0处
//      { inst_mem[27],inst_mem[26],inst_mem[25],inst_mem[24] }<= 32'h1800_2200;   // mult $1,$2# 寄存器 1 和 2 的值相乘，-2
//      { inst_mem[31],inst_mem[30],inst_mem[29],inst_mem[28] } <= 32'h0000_458c;  // lw $5, 0($2)# 取出内存地址$2 + 0处的值到5号寄存器
//      { inst_mem[35],inst_mem[34],inst_mem[33],inst_mem[32] } <= 32'h1a00_8500;  //div $5,$4  #寄存器 5 和 4 的值相除，1
//      { inst_mem[39],inst_mem[38],inst_mem[37],inst_mem[36] } <= 32'h0000_f00b;  //# 跳到ROM初始地址跳到ROM初始地址
//      { inst_mem[43],inst_mem[42],inst_mem[41],inst_mem[40] } <= 32'h0200_0924;  //addiu $9,$0,2




        // { inst_mem[3], inst_mem[2], inst_mem[1], inst_mem[0] }        <= 32'h0100_0124; // addiu $1, $0, 1
        // { inst_mem[7], inst_mem[6], inst_mem[5], inst_mem[4] }        <= 32'h0200_0224; // addiu $2, $0, 2
        // { inst_mem[11], inst_mem[10], inst_mem[9], inst_mem[8] }      <= 32'h0300_0324; // addiu $3, $0, 3
        // { inst_mem[15], inst_mem[14], inst_mem[13], inst_mem[12] }    <= 32'h0400_0424; // addiu $4, $0, 4
        // { inst_mem[19], inst_mem[18], inst_mem[17], inst_mem[16] }    <= 32'h0500_0524; // addiu $5, $0, 5
        // { inst_mem[23], inst_mem[22], inst_mem[21], inst_mem[20] }    <= 32'h0600_0624; // addiu $6, $0, 6
        // { inst_mem[27], inst_mem[26], inst_mem[25], inst_mem[24] }    <= 32'h0700_0724; // addiu $7, $0, 7
        // { inst_mem[31], inst_mem[30], inst_mem[29], inst_mem[28] }    <= 32'h0800_0824; // addiu $8, $0, 8
        // { inst_mem[35], inst_mem[34], inst_mem[33], inst_mem[32] }    <= 32'h0900_0924; // addiu $9, $0, 9
        // { inst_mem[39], inst_mem[38], inst_mem[37], inst_mem[36] }    <= 32'h0a00_0a24; // addiu $10, $0, 10
        // { inst_mem[43], inst_mem[42], inst_mem[41], inst_mem[40] }    <= 32'h0b00_0b24; // addiu $11, $0, 11
        // { inst_mem[47], inst_mem[46], inst_mem[45], inst_mem[44] }    <= 32'h2108_4300; // addu $1, $2, $3       $1 = 2 + 3 = 5
        // { inst_mem[51], inst_mem[50], inst_mem[49], inst_mem[48] }    <= 32'h2120_2500; // addu $4, $1, $5       $4 = 5 + 5 = 10  测试数据冒险
        // { inst_mem[55], inst_mem[54], inst_mem[53], inst_mem[52] }    <= 32'h0100_2510; // beq $1, $5, 1        If $1 == $5, jump forward 1 instruction (skip next) 测试分支
        // { inst_mem[59], inst_mem[58], inst_mem[57], inst_mem[56] }    <= 32'h2130_2700; // addu $6, $1, $7       $6 = 5 + 7 = 12
        // { inst_mem[63], inst_mem[62], inst_mem[61], inst_mem[60] }    <= 32'h2140_2900; // addu $8, $1, $9        $8 = 5 + 9 = 14   分支成功将执行这条指令
        // { inst_mem[67], inst_mem[66], inst_mem[65], inst_mem[64] }    <= 32'h2150_2b00; // addu $10, $1, $11       $10 = 5 + 11 = 16   数据冒险
        // { inst_mem[71], inst_mem[70], inst_mem[69], inst_mem[68] }    <= 32'h1800_0901; // mult $8, $9             14*9=126          乘法运算  结果保留在HILO寄存器
        // { inst_mem[75], inst_mem[74], inst_mem[73], inst_mem[72] }    <= 32'h1a00_2201; // div $9, $2              9/2=4.....1       除法运算  结果保存在HILO寄存器
        // { inst_mem[79], inst_mem[78], inst_mem[77], inst_mem[76] }    <= 32'hffff_0824; //addiu $8,$0,-1             $8=-1
        // { inst_mem[83], inst_mem[82], inst_mem[81], inst_mem[80] }    <= 32'h0200_0924; //addiu $9,$0,2              $9=2
        // { inst_mem[87], inst_mem[86], inst_mem[85], inst_mem[84] }    <= 32'h0a00_28ad; // sw $8, 10($9)           memory[$9+10]=$8   测试存取指令
        // { inst_mem[91], inst_mem[90], inst_mem[89], inst_mem[88] }    <= 32'h0a00_218d; // lw $1, 10($9)           $1=memory[$9+10]      -1   
        // { inst_mem[95], inst_mem[94], inst_mem[93], inst_mem[92] }    <= 32'h0600_2c24; // addiu $12, $1, 6      $12=$1+6    测试流水暂停
        // { inst_mem[99], inst_mem[98], inst_mem[97], inst_mem[96] }    <= 32'h0000_f00b; // j 66060288           跳回初始地址  测试跳转指令
        // { inst_mem[103], inst_mem[102], inst_mem[101], inst_mem[100]} <= 32'h0600_0824; // addiu $8, $0, 6 (不会执行)     验证跳转成功


    end
  end
  wire[`ADDR_BUS] addr = rom_addr - `INIT_PC;

  always @(posedge clk) begin
    if (!rom_en) begin
      rom_read_data <= 0;
    end
    else begin
      rom_read_data <= {
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 0],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 1],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 2],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 3]
      };
    end
  end

endmodule // ROM
