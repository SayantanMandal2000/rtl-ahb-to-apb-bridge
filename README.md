# 🔗 RTL AHB-to-APB Bridge 
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

## 🔌 AHB to APB Bridge Interface – Functional Overview

The AHB-to-APB Bridge is implemented as an **AHB slave**, designed to initiate APB transfers when addressed by a master. It plays a critical role in interfacing the high-performance **AHB (Advanced High-performance Bus)** with the low-power **APB (Advanced Peripheral Bus)** in ARM-based SoCs.

### ⚙️ How It Works

When a valid AHB transfer occurs:
- The bridge latches the address, control, and write data from the AHB.
- It asserts the required APB control signals (`psel`, `penable`, `pwrite`) and drives the APB transfer.
- APB peripherals respond during the **enable phase**, and read data is returned to the AHB along with the `hready` response.

#### ⏱️ Timing Behavior
- **APB Read** takes 3 HCLK cycles (Setup → Enable → Data).
- **APB Write** takes 2 HCLK cycles (Setup → Enable).
- Transfers are word-aligned (32-bit); byte-level access is **not supported**.
- Since APB peripherals are only **strobed during access**, no dedicated `pclk` is needed — contributing to **ultra-low power operation**.

---

## 🔍 Importance of the Bridge

- The bridge is essential to **translate between high-bandwidth pipelined AHB operations and non-pipelined, low-power APB operations**.
- **Wait states are inserted** to accommodate APB's single-access nature.
- It ensures **reliable and synchronized data transfer** between AHB masters and APB slaves without data corruption or protocol violation.

This AHB2APB design:
- Buffers **address, control, and write data** from the AHB.
- Drives the **APB peripheral control logic**.
- Latches **read data and response signals** for the AHB.

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

The AHB-to-APB bridge is controlled by a finite state machine (FSM) that ensures correct sequencing of protocol-specific control signals and data flow.

The FSM manages transitions for both **read** and **write** operations, including pipelined transactions (`WRITE_P`, `WENABLE_P`). It observes the AHB control signals (`hwrite`, `htrans`, `hselapb`, `valid`) and responds by activating the appropriate APB signals (`psel`, `penable`, `pwrite`).

📌 **FSM States:**
- `IDLE` – Wait for a valid AHB transfer
- `READ` – Issue APB address phase for read
- `RENABLE` – Complete APB read and return `hrdata`
- `W_WAIT` – Buffer write address and data from AHB
- `WRITE` – Start non-pipelined APB write
- `WRITE_P` – Start pipelined APB write
- `WENABLE` – Complete non-pipelined APB write
- `WENABLE_P` – Complete pipelined APB write

📷 **FSM State Transition Diagram:**

 ![FSM Diagram](https://github.com/SayantanMandal2000/rtl-ahb-to-apb-bridge/blob/main/sim/AHB2APB_FSM.png)

 💡 This diagram shows:
- Transitions between states based on combinations of `valid` and `hwrite`
- Proper handling of pipelined AHB write requests
- Clean return paths back to `IDLE` or new valid states

This FSM structure ensures **deadlock-free**, **cycle-efficient**, and **protocol-compliant** operation.

---

## ⏱️ Waveform Preview

The waveform below shows the **complete read and write transfer cycles**. It captures the interaction between AHB control signals (`hwrite`, `htrans`, `hselapb`, etc.) and APB signals (`psel`, `penable`, `pwrite`, etc.). Transitions in `present_state`, address/data flow (`haddr`, `pwdata`, `hrdata`), and handshaking (`hready`) are clearly visible.

![AHB to APB Bridge Waveform](https://github.com/SayantanMandal2000/rtl-ahb-to-apb-bridge/blob/main/sim/AHB2APB_Waveform.png)

- Captured using Xilinx Vivado
- ✅ Read and write transfers are correctly synchronized using FSM state transitions, and `hrdata` shows valid output when `penable` is asserted.

---

## 🧰 RTL Schematic

The following schematic is auto-generated by the synthesis tool. It shows the **combinational and sequential blocks**, `MUX`, `LATCH`, and `ROM` representations for FSM transitions, state storage, and control signal generation.

📐 **RTL Structural Diagram:**

![RTL Bridge Schematic](https://github.com/SayantanMandal2000/rtl-ahb-to-apb-bridge/blob/main/sim/AHB2APB_RTL.png)

🔎 This diagram validates that:
- FSM logic is centralized and feeds all APB control signals.
- `haddr_temp` and `hwdata_temp` are latched before use.
- The bridge logic follows strict protocol sequencing.
