#!/bin/bash
# OpenHardware.co.za - and Cmdrkeen.net - Firmware Burning Script for AVRs
# (C) 2012


PRGRM=$(zenity --width=650 --height=400 --list \
--title="OpenHardware.co.za Firmware Burner"  --text "Select the Programmer you are using" --radiolist \
--column "Select" --column "Programmer" \
TRUE "USBtinyISP" \
FALSE "Arduino UNO or Leonardo as ISP" \
FALSE "Arduino Duemilanova as ISP"\
) 

case "$PRGRM" in
	'USBtinyISP')
	echo "Setting up AVRDUDE to use $PRGRM"
	PROGRAMMER="usbtiny "
	;;
      
	'Arduino UNO or Leonardo as ISP')
	echo "Setting AVRDUDE up to use $PRGRM"
	PORT=$(ls -l /sys/class/tty/ttyACM* | cut -d/ -f5 |  cut -d" " -f1 | zenity --list --title="Choose CDC-Serial Port" --column="Port")
	PROGRAMMER="-P $PORT -c avrisp -b 19200"
	;;

	'Arduino Duemilanova as ISP')
	echo "Setting AVRDUDE up to use $PRGRM"
	PORT=$(ls -l /sys/class/tty/ttyUSB* | cut -d/ -f5 |  cut -d" " -f1 | zenity --list --title="Choose  FTDI Serial Port" --column="Port")
	PROGRAMMER="-P $PORT -c avrisp -b 19200"
	;;

	'')

esac

ans=$(zenity --width=650 --height=400 --list \
--title="OpenHardware.co.za Firmware Burner"  --text "Select the firmware / chip combination to Burn?" --radiolist \
--column "Target" --column "Firmware" \
TRUE "AVR-CDC to ATtiny45 - max 4800 Baud" \
FALSE "AVR-CDC to ATtiny45 - max 4800 Baud - Inverted USB" \
FALSE "AVR-CDC to ATtiny85 - max 4800 Baud" \
FALSE "AVR-CDC to ATtiny85 - max 4800 Baud - Inverted USB" \
FALSE "AVR-CDC to ATtiny2313 - 16Mhz - max 38400 Baud with DTR on PB5" \
FALSE "AdaBoot Bootloader to ATmega328P - 19200 Baud" \
FALSE "VUSBtiny to ATTiny45" \
FALSE "VUSBtiny to ATTiny85" \
)


case "$ans" in
	'AVR-CDC to ATtiny45 - max 4800 Baud')
	echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt45 -U flash:w:./hex_files/avrcdc/cdctiny45.hex -U lfuse:w:0xf1:m -U hfuse:w:0xce:m -U efuse:w:0xff:m      
	;;

	'AVR-CDC to ATtiny45 - max 4800 Baud - Inverted USB')
	echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt45 -U flash:w:./hex_files/avrcdc/cdctiny45invusb.hex -U lfuse:w:0xf1:m -U hfuse:w:0xce:m -U efuse:w:0xff:m
	;;

	'AVR-CDC to ATtiny85 - max 4800 Baud')
        echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt85 -U flash:w:./hex_files/avrcdc/cdctiny85.hex -U lfuse:w:0xf1:m -U hfuse:w:0xce:m -U efuse:w:0xff:m
	;;

	'AVR-CDC to ATtiny85 - max 4800 Baud - Inverted USB')
        echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt85 -U flash:w:./hex_files/avrcdc/cdctiny85invusb.hex -U lfuse:w:0xf1:m -U hfuse:w:0xce:m -U efuse:w:0xff:m
	;;

	'AVR-CDC to ATtiny2313 - 16Mhz - max 38400 Baud with DTR on PB5')
        echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt2313 -U flash:w:./hex_files/avrcdc/cdc2313-16.hex 
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -pt2313 -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
	;;

	'AdaBoot Bootloader to ATmega328P - 19200 Baud')
        echo "Using a $PRGRM to burn $ans"	
	echo "Setting FUSE bits"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p m328p -e -u -U lock:w:0x3f:m -U efuse:w:0x05:m -U hfuse:w:0xDA:m -U lfuse:w:0xFF:m
		if [ $? == 0 ]
  			then
			echo "Burning HEX file"
			./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p m328p -U flash:w:./hex_files/adaboot/AdaBoot_328_19200baudBoot.hex -U lock:w:0x0f:m
			else
			echo "Could not set fuse bits.  Exiting" ; exit 1
		fi 
	;;


 
        'VUSBtiny to ATTiny45')
        echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p t45 -e -V -U flash:w:./hex_files/vusbtiny/vusbtiny.hex
		if [ $? == 0 ]
			then
			RESET=$(zenity --question --text "Are you sure you want disable the RESET pin?")
						if [ $? == 0 ]
						then
						./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p t45 -V -U lfuse:w:0xe1:m -U hfuse:w:0x5d:m -U efuse:w:0xff:m
						else
						echo "RESET pin disable has been cancelled"
						fi
			else
			echo "Something went wrong - not going to disable RESET!.  Exiting" ; exit 1
		fi         
        ;;

        'VUSBtiny to ATTiny85')
        echo "Using a $PRGRM to burn $ans"
	echo "Burning HEX file"
	./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p t85 -e -V -U flash:w:./hex_files/vusbtiny/vusbtiny.hex
		if [ $? == 0 ]
			then
			RESET=$(zenity --question --text "Are you sure you want disable the RESET pin?")
						if [ $? == 0 ]
						then
						./avrdude/avrdude -C ./avrdude/avrdude.conf -c $PROGRAMMER -p t85 -V -U lfuse:w:0xe1:m -U hfuse:w:0x5d:m -U efuse:w:0xff:m
						else
						echo "RESET pin disable has been cancelled"
						fi
			else
			echo "Something went wrong - not going to disable RESET!.  Exiting" ; exit 1
		fi         
	;;



esac
