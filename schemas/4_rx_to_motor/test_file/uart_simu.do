restart
delete wave *
add wave -position insertpoint  \
sim:/uart_to_motor/clk \
sim:/uart_to_motor/rx \
sim:/uart_to_motor/enable_motor \
sim:/uart_to_motor/tx \
sim:/uart_to_motor/pwm_a \
sim:/uart_to_motor/enable_a \
sim:/uart_to_motor/pwm_b \
sim:/uart_to_motor/enable_b \
sim:/uart_to_motor/data_rx \
sim:/uart_to_motor/data_rx_ready \
sim:/uart_to_motor/data_byte \
sim:/uart_to_motor/addresses \
sim:/uart_to_motor/actions
force -freeze sim:/uart_to_motor/clk 1 0, 0 {25 ns} -r 50

