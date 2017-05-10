# stm32fdisco
My test of stm32fdisco




------------------------------------------------------------------

To flash

openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -c "init"
To start openocd:

openocd might hang (e.g., do not start again):
ps (to find ps number)
kill --kill ps_number


in a different terminal type:
telnet localhost 4444

To stop and reset:
> reset halt

Identify the flash:
> flash probe 0

Erase and write HEX file into flash
> flash write_image erase file_name.hex

The finish
> reset
> exit
