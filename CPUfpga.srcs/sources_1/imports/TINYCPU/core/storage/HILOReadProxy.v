`timescale 1ns / 1ps

// 对 HILO 寄存器进行写操作是在 WB 阶段，而对 HILO 寄存器内数据进行读取和使用是在 EX 阶段
// 因此需要引入 HILOReadProxy 部件进行 HILO 寄存器的数据前递
// 而前递的数据来自于 MEM 和 WB 阶段未能写入 HILO 寄存器的 HILO 寄存器数据

`include "bus.v"

module HILOReadProxy(
    input [`DATA_BUS] hi_input_data,
    input [`DATA_BUS] lo_input_data,
    input             mem_hilo_write_en,
    input [`DATA_BUS] mem_hi_write_data,
    input [`DATA_BUS] mem_lo_write_data,
    input             wb_hilo_write_en,
    input [`DATA_BUS] wb_hi_write_data,
    input [`DATA_BUS] wb_lo_write_data,
    output [`DATA_BUS] hi_output_data,
    output [`DATA_BUS] lo_output_data
);

    assign hi_output_data = mem_hilo_write_en ? mem_hi_write_data :
                        wb_hilo_write_en ? wb_hi_write_data :
                        hi_input_data;
    assign lo_output_data = mem_hilo_write_en ? mem_lo_write_data :
                        wb_hilo_write_en ? wb_lo_write_data :
                        lo_input_data;

endmodule