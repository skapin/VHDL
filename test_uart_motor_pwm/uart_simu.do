restart
delete wave *
add wave -position insertpoint  \
sim:/uart_to_motor/sense_vector
add wave -position insertpoint  \
sim:/uart_to_motor/rx
add wave -position insertpoint  \
sim:/uart_to_motor/pwm_intern
add wave -position insertpoint  \
sim:/uart_to_motor/pwm_b
add wave -position insertpoint  \
sim:/uart_to_motor/pwm_a
add wave -position insertpoint  \
sim:/uart_to_motor/enable_b
add wave -position insertpoint  \
sim:/uart_to_motor/enable_a
add wave -position insertpoint  \
sim:/uart_to_motor/clk
add wave -position insertpoint  \
sim:/uart_to_motor/uart/uart_rxx/state
force -freeze sim:/uart_to_motor/clk 1 0, 0 {1 ns} -r 2
run 10