# INSTRUCTIONS for Nested Blockchain Solution

This README provides step-by-step instructions for compiling and running the components of your nested blockchain solution. Follow these steps carefully to ensure a successful setup and execution.

---

## Prerequisites

- Rust and Cargo installed on your system.
  - [Install Rust](https://www.rust-lang.org/tools/install)
- A terminal or command-line interface (CLI).


## Compilation Instructions

### 1. Compile the Relay Chain
Navigate to the root directory of your project and execute the following command:
```bash
cargo build --release --manifest-path=relay-chain/Cargo.toml
```

### 2. Compile the Provenance Parachain
Run the following command to compile the provenance parachain:
```bash
cargo build --release --manifest-path=provenance-parachain/Cargo.toml
```

### 3. Compile the Shipment Parachain
Compile the shipment parachain with the following command:
```bash
cargo build --release --manifest-path=shipment-parachain/Cargo.toml
```

Each of these commands will create executable files in the `target/release` directory of their respective projects.

---

## Execution Instructions

### Step 1: Start the Relay Chain
Run the relay chain executable:
```bash
./target/release/relay-chain --dev
```
Keep this terminal open as the relay chain needs to run continuously.

### Step 2: Start the Provenance Parachain
In a new terminal window, navigate to the `target/release` directory of the provenance parachain and execute:
```bash
./target/release/provenance-parachain --dev --parachain-id 200
```

### Step 3: Start the Shipment Parachain
Open another terminal window and navigate to the `target/release` directory of the shipment parachain. Then, execute:
```bash
./target/release/shipment-parachain --dev --parachain-id 201
```

---


## Note that you can automate the process
You can create a shell script to automate the compilation and execution of all components. Save the following content into a file named `run.sh`:
```bash
#!/bin/bash

# Compile
cargo build --release --manifest-path=relay-chain/Cargo.toml
cargo build --release --manifest-path=provenance-parachain/Cargo.toml
cargo build --release --manifest-path=shipment-parachain/Cargo.toml

# Run
gnome-terminal -- ./target/release/relay-chain --dev
sleep 2

gnome-terminal -- ./target/release/provenance-parachain --dev --parachain-id 200
sleep 2

gnome-terminal -- ./target/release/shipment-parachain --dev --parachain-id 201
```
Make the script executable:
```bash
chmod +x run.sh
```
Run it:
```bash
./run.sh
```



