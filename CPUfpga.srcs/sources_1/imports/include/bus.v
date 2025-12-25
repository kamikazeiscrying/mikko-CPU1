// 定义处理器中各类总线的位宽和位段常量
`ifndef TINYMIPS_BUS_V_
`define TINYMIPS_BUS_V_

// 地址总线
`define ADDR_BUS                31:0
`define ADDR_BUS_WIDTH          32

// 指令总线
`define INST_BUS                31:0
`define INST_BUS_WIDTH          32

// 数据总线
`define DATA_BUS                31:0
`define DATA_BUS_WIDTH          32

// 半字数据总线
`define HALF_DATA_BUS           15:0
`define HALF_DATA_BUS_WIDTH     16

// 双字数据总线
`define DOUBLE_DATA_BUS         63:0
`define DOUBLE_DATA_BUS_WIDTH   64

// 寄存器地址总线
`define REG_ADDR_BUS            4:0
`define REG_ADDR_BUS_WIDTH      5        //因为一共有32个寄存器，所以要用5位二进制数来表示

// 指令字段总线
`define INST_OP_BUS             5:0
`define INST_OP_BUS_WIDTH       6
`define FUNCT_BUS               5:0
`define FUNCT_BUS_WIDTH         6
`define SHAMT_BUS               4:0
`define SHAMT_BUS_WIDTH         5

// 存储器字节选择总线
`define MEM_SEL_BUS             3:0
`define MEM_SEL_BUS_WIDTH       4

// 异常类型总线
`define EXC_TYPE_BUS            3:0
`define EXC_TYPE_BUS_WIDTH      4
`endif  // TINYMIPS_BUS_V_
