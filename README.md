 earn rewards through hashtags on social media for mentioning brands running campaign, mentioned brand name and get a points. 
This project is about everyday people promoting brands running campaigns and earning rewards. Simply mention or hashtag a brand on social media, get points, and turn those points into cash. The more you mention, the more you earn — making everyone a potential influencer.


Here’s an **extensive `README.md`** for the project, written in a way that explains everything clearly for potential contributors, Stacks Ascend reviewers, or partners:

---

# 🚀 Hybrid Web3 Bitcoin Layer 2 Application (Stacks.js + Clarity + Node/Express + Vite React TS)

## 📌 Overview

This project is a **hybrid Web3 application** built on **Stacks**, the Bitcoin Layer 2 blockchain.
It combines **on-chain smart contract logic written in Clarity** with **off-chain business logic and services** powered by **Node.js/Express (TypeScript)**, integrating with a **Vite React TypeScript** frontend.

The application is designed for **real-world, scalable, user-centric scenarios** where **most user actions—whether on-chain or off-chain—are tightly integrated with blockchain transactions**. This approach meets the **Stacks Ascend programme's requirement for extensive use of Stacks.js and Clarity**.

---

## 🎯 Key Features

* **🔗 Extensive Blockchain Integration**

  * All major actions (even off-chain) trigger an **on-chain confirmation** or interaction with the Clarity smart contract.
  * Extensive use of **Stacks.js** for transaction signing, account management, and smart contract calls.

* **⚡ Hybrid On-chain + Off-chain Architecture**

  * **On-chain**: Immutable smart contract logic, user asset tracking, transaction verifications.
  * **Off-chain**: Scalable business logic, data indexing, user profiles, analytics, notifications.
  * **Off-chain Oracle** integrated into Node backend to securely pass data to/from the blockchain.

* **🛡️ Security**

  * **Authentication**: Secure JWT-based authentication (backend) + Stacks wallet authentication (frontend).
  * **Authorization & Roles**: Role-based access control (Admin, User, Moderator, etc.).
  * Every user can **only access their own account data** unless granted higher privileges.

* **🌐 Modern Web App**

  * **Frontend**: Vite + React + TypeScript for speed and maintainability.
  * **Backend**: Node.js + Express + TypeScript for type safety and scalability.
  * **Blockchain**: Stacks blockchain for on-chain storage and verification.
  * **Clarity**: Smart contracts controlling core blockchain logic.

---

## 🏗 Architecture

### **Frontend (Vite React TS + Stacks.js)**

* Handles **UI/UX** for all user interactions.
* Connects directly to Stacks wallets for signing transactions.
* Displays **real-time blockchain data** from smart contracts.
* Makes API calls to the Node backend for off-chain operations.

### **Backend (Node + Express + TypeScript)**

* Handles **off-chain business logic**, database management, and authentication.
* Integrates an **Off-chain Oracle Service** to bridge blockchain and off-chain world.
* Stores user profiles, metadata, and logs in a database (MongoDB/PostgreSQL).

### **Smart Contracts (Clarity)**

* Immutable blockchain logic for core features.
* Enforces ownership, asset management, and transaction rules.
* Validates off-chain data via oracle submissions.

---

## 📂 Project Structure

The project evolves in **three stages**:

**Basic**

* Minimal frontend (Vite React TS) with wallet connection via Stacks.js.
* Backend API boilerplate with Express and TypeScript.
* Basic Clarity smart contract deployment.

**Medium**

* Authentication & Authorization system (JWT + Stacks wallet auth).
* Role-based access control.
* Initial Oracle integration for off-chain → on-chain communication.

**Complex**

* Full feature set:

  * Real-time updates via WebSockets.
  * Advanced Clarity contract logic.
  * Oracle automation and off-chain job scheduling.
  * Secure blockchain data indexing service.

---

## 🔧 Tech Stack

* **Frontend**: Vite, React, TypeScript, CSS Modules
* **Backend**: Node.js, Express, TypeScript
* **Blockchain**: Stacks.js, Clarity Smart Contracts
* **Database**: MongoDB / PostgreSQL
* **Authentication**: JWT + Stacks Wallet
* **Security**: Role-Based Access Control (RBAC)
* **Off-chain Oracle**: Integrated with backend to sync blockchain & database

---

## 📜 How It Works

1. User connects wallet via frontend (Stacks.js).
2. User performs an action (e.g., update profile, send message, join group).
3. Action is processed **off-chain** in Node backend **and** triggers **on-chain smart contract interaction**.
4. Oracle service ensures data integrity between on-chain and off-chain storage.
5. Blockchain confirms the transaction; frontend updates UI in real-time.

---

## 🚀 Getting Started

### **1. Install Frontend**

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install @stacks/connect @stacks/transactions @stacks/network
```

### **2. Install Backend**

```bash
mkdir backend && cd backend
npm init -y
npm install express typescript ts-node-dev @types/express
```

### **3. Clarity Smart Contracts**

* Install Stacks CLI:

```bash
npm install -g @stacks/cli
```

* Deploy contracts via Stacks testnet.

---

## 🔮 Future Enhancements

* Decentralized identity (DID) integration.
* On-chain governance voting.
* Multi-signature transaction support.
* Mobile-friendly dApp interface.

---

## 🤝 Contribution

We welcome contributions from **Stacks developers, blockchain enthusiasts, and Web3 builders**.
Fork, create a branch, make your changes, and submit a pull request.

---

## 📜 License

MIT License – Free to use, modify, and distribute.

---


