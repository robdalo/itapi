INSTALL_DEVICE = /dev/sdd1
INSTALL_PATH = /media/robd/bootfs

all: clean kernel.img

main.o: src/main.s
	arm-none-eabi-as -o main.o src/main.s

constant.o: src/constant.s
	arm-none-eabi-as -o constant.o src/constant.s

drawing.o: src/drawing.s
	arm-none-eabi-as -o drawing.o src/drawing.s

framebuffer.o: src/framebuffer.s
	arm-none-eabi-as -o framebuffer.o src/framebuffer.s	

gpio.o: src/gpio.s
	arm-none-eabi-as -o gpio.o src/gpio.s

led.o: src/led.s
	arm-none-eabi-as -o led.o src/led.s

mailbox.o: src/mailbox.s
	arm-none-eabi-as -o mailbox.o src/mailbox.s

terminal.o: src/terminal.s
	arm-none-eabi-as -o terminal.o src/terminal.s

timer.o: src/timer.s
	arm-none-eabi-as -o timer.o src/timer.s

kernel.img: main.o constant.o drawing.o framebuffer.o gpio.o led.o mailbox.o terminal.o timer.o
	arm-none-eabi-ld -nostdlib main.o constant.o drawing.o framebuffer.o gpio.o led.o mailbox.o terminal.o timer.o -T kernel.ld -o kernel.elf
	arm-none-eabi-objcopy -O binary kernel.elf kernel.img

clean:
	rm -rf *.elf *.o *.img

install: all
	mkdir -p $(INSTALL_PATH)
	mount $(INSTALL_DEVICE) $(INSTALL_PATH)
	rm -rf $(INSTALL_PATH)/kernel.img
	cp kernel.img $(INSTALL_PATH)/kernel.img
	umount $(INSTALL_DEVICE)
