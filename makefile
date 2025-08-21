all: clean kernel.img

main.o: src/main.s
	arm-none-eabi-as -o main.o src/main.s

framebuffer.o: src/framebuffer.s
	arm-none-eabi-as -o framebuffer.o src/framebuffer.s	

gpio.o: src/gpio.s
	arm-none-eabi-as -o gpio.o src/gpio.s

led.o: src/led.s
	arm-none-eabi-as -o led.o src/led.s

mailbox.o: src/mailbox.s
	arm-none-eabi-as -o mailbox.o src/mailbox.s

timer.o: src/timer.s
	arm-none-eabi-as -o timer.o src/timer.s

kernel.img: main.o framebuffer.o gpio.o led.o mailbox.o timer.o
	arm-none-eabi-ld -nostdlib main.o framebuffer.o gpio.o led.o mailbox.o timer.o -T kernel.ld -o kernel.elf
	arm-none-eabi-objcopy -O binary kernel.elf kernel.img

clean:
	rm -rf *.elf *.o *.img