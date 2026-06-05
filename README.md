# Line Following & Autonomous Parking Robot

This project is an autonomous Arduino-based robot developed for the IE3064 Embedded Systems Design module. The robot is designed to follow a marked line track and perform an autonomous parking sequence inside the correct parking bay.

The firmware was implemented fully in AVR Assembly language for the ATmega328P microcontroller on the Arduino Uno.

## Project Overview

The robot uses two TCRT5000 reflective sensors for line detection and an IR sensor for parking bay detection. Based on the sensor inputs, the firmware controls two DC motors through a TB6612FNG motor driver.

The system continuously performs line tracking, marker detection, parking-stage switching, lost-line timeout handling, and final parking execution using low-level register-based control.

## Key Features

* Real-time line following using two TCRT5000 IR sensors
* Autonomous parking sequence based on sensor-triggered detection
* AVR Assembly firmware for Arduino Uno / ATmega328P
* PWM-based motor speed control using hardware timers
* External interrupt handling for parking bay detection
* Marker-based mode switching
* Lost-line safety timeout
* State-based robot behavior control
* Timed movement sequence for parking execution

## Hardware Components

* Arduino Uno with ATmega328P
* TB6612FNG dual motor driver
* 2 × TCRT5000 line sensors
* IR flame sensor used as parking detection input
* 2 × DC motors
* 2 × 18650 batteries
* Robot chassis with wheels
* Custom wiring and battery connector

## Pin Mapping

| Arduino Pin | Function                    |
| ----------- | --------------------------- |
| D10         | PWMA                        |
| D9          | AIN2                        |
| D8          | AIN1                        |
| D7          | BIN1                        |
| D6          | BIN2                        |
| D5          | PWMB                        |
| A0          | Left line sensor            |
| A1          | Right line sensor           |
| D3          | IR parking interrupt sensor |

## Firmware Files

* `main.S` - Main AVR Assembly source file
* `main.hex` - Compiled HEX file for uploading to the ATmega328P

## Assembly Toolchain

This project can be assembled using the AVR-GCC toolchain.

### Linux / Ubuntu

```bash
sudo apt-get update
sudo apt-get install gcc-avr binutils-avr avr-libc
```

### Compile to ELF

```bash
avr-gcc -mmcu=atmega328p -Wall -Os -o main.elf firmware/src/main.S
```

### Generate HEX File

```bash
avr-objcopy -O ihex -R .eeprom main.elf firmware/build/main.hex
```

## Testing Summary

The robot successfully completed the following tests:

* Forward movement
* Straight line following
* Curved line following
* Marker detection and mode switching
* Lost-line timeout safety stop
* Parking interrupt detection
* Autonomous parking maneuver
* Full system run

## Learning Outcomes

This project improved my understanding of AVR Assembly programming, direct register manipulation, hardware PWM, external interrupts, sensor interfacing, timing-based decision making, and autonomous embedded system design.

## Project Status

Completed as part of the IE3064 Embedded Systems Design module.
