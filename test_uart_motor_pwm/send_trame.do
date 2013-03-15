#START BIT
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536

#DATA
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 0 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 0 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 0 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536
force -freeze sim:/uart_to_motor/rx 1 0 -cancel 5536
run 5536
#STOP
force -freeze sim:/uart_to_motor/rx 0 0 -cancel 5536
run 5536