vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/fifo_generator_v13_2_3
vlib questa_lib/msim/xil_defaultlib

vmap fifo_generator_v13_2_3 questa_lib/msim/fifo_generator_v13_2_3
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work fifo_generator_v13_2_3 -64 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_3 -64 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_3 -64 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib -64 \
"../../../../UART.srcs/sources_1/ip/FIFO_UART/sim/FIFO_UART.v" \


vlog -work xil_defaultlib \
"glbl.v"

