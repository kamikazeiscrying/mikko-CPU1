// 仿真环境下指令存储器与数据存储器的参数定义
// 用于存放 ROM 与 RAM 中的相关宽度

`ifndef TINYMIPS_SIM_V_
`define TINYMIPS_SIM_V_

`define DATA_MEM_ADDR_WIDTH   5
`define DATA_MEM_SIZE         2 ** `DATA_MEM_ADDR_WIDTH
`define DATA_MEM_BUS          `DATA_MEM_SIZE - 1:0

`define INST_MEM_ADDR_WIDTH   8
// 指令存储器地址宽度（8 位）
`define INST_MEM_SIZE         2 ** `INST_MEM_ADDR_WIDTH
// 地址宽度为 8 位时的指令存储器大小
`define INST_MEM_BUS          `INST_MEM_SIZE - 1:0

`endif  // TINYMIPS_SIM_V_
