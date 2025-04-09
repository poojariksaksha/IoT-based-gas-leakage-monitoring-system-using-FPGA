# IoT-Based Gas Leakage Monitoring System using FPGA (VHDL)

This project is a **gas leakage detection and monitoring system** built on an **FPGA (Spartan-6)** using **VHDL**. It detects harmful gases (like LPG, CH₄, CO, etc.) and monitors temperature, then displays the readings on an LCD and sends real-time data to an IoT platform, **ThingSpeak**, for remote monitoring.

---

## Why This Project?

Gas leaks can cause **explosions**, **health hazards**, and **environmental harm**. Manual detection methods are often too late. This project provides:
- Early **warning signs**
- Real-time **IoT updates**
- Low-cost **digital automation**

---

## Project Summary

| Feature                         | Description                                                                |
|---------------------------------|--------------------------------------------------------------------------- |
| 👨‍💻 Platform                    | Spartan-6 FPGA (VHDL Programming)                                           |
| 🔌 Sensors                     | MQ-5 Gas Sensor, LM35 Temperature Sensor                                    |
| 🌐 IoT                         | ESP8266 WiFi Module connected to [ThingSpeak](https://thingspeak.com/)      |
| 🖥️ Output                     | 16x2 LCD Display and ThingSpeak Dashboard                                    |
| 💬 Communication Protocols     | SPI (ADC), UART (WiFi module)                                               |
| 📦 Modules                     | ADC, UART, LCD, Top-level IOT integration                                   |

---

## How It Works

### 1. **Sensing**
- **MQ-5** detects gases (LPG, H₂, CO, etc.)
- **LM35** measures temperature
- Both sensors provide **analog output**

### 2. **Data Conversion**
- Analog signals are converted to **digital** using **MCP3208 ADC**
- ADC is interfaced with FPGA using **SPI**

### 3. **Data Display**
- Values are displayed:
  - On a **16x2 LCD** (for local viewing)
  - On **ThingSpeak dashboard** (via WiFi)

### 4. **IoT Transmission**
- **ESP8266 WiFi module** uses **UART** to send data to ThingSpeak
- Each user has a **unique URL** for live monitoring

---

## Files and Modules

| File Name       | Description                              |
|-----------------|------------------------------------------|
| `vhdl/ADC.vhd`  | Converts analog gas/temperature values to digital |
| `vhdl/UART.vhd` | Sends sensor data to WiFi module over UART         |
| `vhdl/LCD.vhd`  | Displays gas & temp values on LCD display          |
| `vhdl/IOT.vhd`  | Integrates all modules, acts as the top-level      |

---

### Prerequisites
- Xilinx ISE or Vivado installed
- Spartan-6 FPGA board
- MQ-5, LM35, MCP3208, ESP8266, LCD

