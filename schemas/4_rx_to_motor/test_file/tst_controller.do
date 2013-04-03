restart
delete wave *
add wave -position insertpoint  \
sim:/uart_to_motor/clk \
sim:/uart_to_motor/rx \
sim:/uart_to_motor/framecontroller/state
force -freeze sim:/uart_to_motor/clk 1 0, 0 {25 ns} -r 50

