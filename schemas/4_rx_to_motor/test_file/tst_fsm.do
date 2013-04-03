restart
delete wave *
add wave -position insertpoint  \
sim:/uart_to_motor/clk \
sim:/uart_to_motor/rx \
sim:/uart_to_motor/enable_motor \
sim:/uart_to_motor/data_rx \
sim:/uart_to_motor/data_rx_ready \
sim:/uart_to_motor/data_byte \
sim:/uart_to_motor/addresses \
sim:/uart_to_motor/actions
add wave -position insertpoint \
/uart_to_motor/framecontroller/line__28/addr_intern
add wave -position insertpoint \
/uart_to_motor/framecontroller/line__28/action_intern
add wave -position insertpoint  \
sim:/uart_to_motor/framecontroller/data_ready
add wave -position insertpoint  \
sim:/uart_to_motor/framecontroller/data_out
add wave -position insertpoint  \
sim:/uart_to_motor/framecontroller/state
force -freeze sim:/uart_to_motor/clk 1 0, 0 {25 ns} -r 50

