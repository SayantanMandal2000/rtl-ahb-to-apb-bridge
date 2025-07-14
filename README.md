# rtl-ahb-to-apb-bridge
# 🔗 RTL AHB-to-APB Bridge (Verilog)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Language: Verilog](https://img.shields.io/badge/language-Verilog-yellow.svg)
![Build: Simulated](https://img.shields.io/badge/build-simulated-green)
![Waveform: Vivado](https://img.shields.io/badge/waveform-GTKwave-blue)
![FSM: Implemented](https://img.shields.io/badge/FSM-Implemented-red)

A synthesizable RTL design in Verilog that implements a protocol bridge between the AMBA AHB-Lite and APB buses using a finite state machine (FSM). This bridge facilitates communication between high-speed AHB masters and low-power APB peripherals in SoC environments.

---

## 📚 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [AHB ↔ APB Protocol Mapping](#-ahb--apb-protocol-mapping)
- [Finite State Machine](#-finite-state-machine)
- [Usage](#-usage)
- [Simulation & Testbench](#-simulation--testbench)
- [File Structure](#-file-structure)
- [License](#-license)
- [Author](#-author)

---

## 📖 Overview

In modern SoCs, high-speed components typically communicate over the AHB/AXI bus, while simpler peripheral devices are connected via the APB bus. This project implements a bridge to interface between these two domains.

The AHB-to-APB bridge receives read/write requests from an AHB-Lite master and converts them into APB-compliant operations. This includes:

- Transaction detection (`htrans`, `hselapb`)
- Address and data buffering
- Control signal generation (`psel`, `penable`, `pwrite`)
- Flow control with `hready`

---

## ✨ Key Features

- ✅ Fully synthesizable Verilog RTL
- 🔁 Supports pipelined back-to-back AHB transactions
- 📥 Handles read/write direction with protocol-safe timing
- 🧠 FSM-based design for clear operation sequencing
- 🧪 Ready for simulation and waveform debugging

---

## 🔄 AHB ↔ APB Protocol Mapping

| AHB Signal   | Description            | APB Signal   | Description                      |
|--------------|------------------------|--------------|----------------------------------|
| `haddr`      | Address bus            | `paddr`      | APB Address                      |
| `hwdata`     | Write data             | `pwdata`     | APB Write Data                   |
| `hrdata`     | Read data              | `prdata`     | APB Read Data                    |
| `hwrite`     | Read/Write control     | `pwrite`     | APB Write Enable                 |
| `htrans`     | Transfer type          | `psel`       | Slave Select                     |
| `hready`     | Ready to proceed       | `penable`    | Enable for second APB phase      |

---

## 🔁 Finite State Machine

The FSM transitions between the following states:

