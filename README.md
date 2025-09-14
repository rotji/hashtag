# 🚀 Web3 Campaign Rewards Application

## 📌 Overview

This project is a Web3 application built on **Stacks**, the Bitcoin Layer 2 blockchain. It allows brands to create marketing campaigns where users can earn rewards (fungible tokens) for mentioning the brand on social media. The system is designed to be driven by a trusted off-chain oracle that verifies social media mentions and triggers the on-chain reward mechanism.

The application consists of a **Vite/React/TypeScript frontend** for user interaction and a set of **Clarity smart contracts** that govern the core logic of campaigns, rewards, and user roles.

## 🎯 Key Features

*   **🔗 On-Chain Campaign Management**: Brands can create campaigns, define budgets, and specify rewards directly on the blockchain.
*   **✨ Fungible Token Rewards**: Users earn a custom fungible token for their participation, which can be claimed and transferred.
*   **🤖 Oracle-Driven Rewards (Conceptual)**: The system is designed for a trusted off-chain oracle to verify user actions and trigger on-chain rewards. The contracts to support this are included, but the off-chain oracle itself is not part of this repository.
*   **🎭 Role-Based Access Control**: The system uses a `user-roles` contract to manage permissions for different types of users (e.g., brands, participants).
*   ** frontend-facing dApp**: A simple and clean user interface built with React and TypeScript for interacting with the Stacks blockchain.

---

## 🏗 Architecture

The project consists of two main parts:

### **Frontend (Vite + React + TS + Stacks.js)**

*   Handles all user interactions, such as connecting a Stacks wallet, viewing campaigns, and claiming rewards.
*   Uses **Stacks.js** to communicate with the Stacks blockchain for signing transactions and calling smart contract functions.

### **Smart Contracts (Clarity)**

*   **`campaign.clar`**: The core contract for creating and managing brand campaigns. It handles the campaign budget, reward distribution, and active status.
*   **`oracle-registry.clar`**: A simple registry to manage a list of trusted oracle principals. This contract is designed to be used by an off-chain oracle to trigger reward distributions.
*   **`user-roles.clar`**: A contract to assign roles (e.g., "brand", "participant") to user principals, enabling permissioned actions within the system.

---

## 🔧 Tech Stack

*   **Frontend**: Vite, React, TypeScript
*   **Blockchain**: Stacks.js, Clarity Smart Contracts
*   **Styling**: CSS

---

## 🚀 Getting Started

### **Prerequisites**

*   [Node.js and npm](https://nodejs.org/en/)
*   [Stacks CLI](https://docs.stacks.co/get-started/command-line-interface)
*   A Stacks-compatible wallet (e.g., Hiro Wallet)

### **1. Install Frontend Dependencies**

Navigate to the `frontend/my-app` directory and install the required npm packages:

```bash
cd frontend/my-app
npm install
```

### **2. Run the Frontend**

Once the dependencies are installed, you can start the development server:

```bash
npm run dev
```

The application will be available at `http://localhost:5173`.

### **3. Deploy Clarity Smart Contracts**

The Clarity smart contracts are located in the `backend/contracts/contracts` directory. You will need to use the Stacks CLI to deploy them to the testnet or a local devnet.

Refer to the [Stacks documentation](https://docs.stacks.co/get-started/smart-contracts) for detailed instructions on how to deploy Clarity contracts.

---

## 🤝 Contribution

We welcome contributions from **Stacks developers, blockchain enthusiasts, and Web3 builders**.
Fork the repository, create a new branch, make your changes, and submit a pull request.

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


