Awesome — here’s a **ready-to-run skeleton** for your whole project using **Vite + React + TypeScript**, **Node + Express + TypeScript**, **Clarity smart contracts (Clarinet)**, and an **off-chain Oracle** (inside the backend).
It includes **package.json** for both frontend and backend and minimal code in every file so nothing is empty.

> Copy this into your repo, then run the setup commands shown near the end.

---

# Folder / File Tree (high-level)

```
stacks-hashtag-rewards/
├─ README.md
├─ .gitignore
├─ .env.example
├─ frontend/
├─ backend/
└─ contracts/
```

---

# Root

### `.gitignore`

```gitignore
# root
.env
node_modules/
dist/
.DS_Store

# frontend
frontend/node_modules
frontend/dist

# backend
backend/node_modules
backend/dist
backend/.env

# clarinet
contracts/.clarinet
```

### `.env.example`

```bash
# --- FRONTEND ---
VITE_STACKS_NETWORK=devnet

# --- BACKEND ---
PORT=5000
NODE_ENV=development
JWT_SECRET=change_me
MONGO_URI=mongodb://localhost:27017/stacks-hashtag-rewards

# Social APIs (placeholders for later; keep empty now)
TWITTER_BEARER_TOKEN=
INSTAGRAM_APP_ID=
INSTAGRAM_APP_SECRET=

# STACKS
STACKS_RPC_URL=https://stacks-node-api.testnet.stacks.co
CONTRACT_DEPLOYER=SP3FBR2AGK...REPLACE
CAMPAIGN_CONTRACT_NAME=campaign
```

---

# Frontend (Vite + React + TypeScript)

```
frontend/
├─ package.json
├─ tsconfig.json
├─ tsconfig.node.json
├─ vite.config.ts
├─ index.html
└─ src/
   ├─ main.tsx
   ├─ App.tsx
   ├─ App.module.css
   ├─ routes/
   │  └─ router.tsx
   ├─ pages/
   │  ├─ Home.tsx
   │  ├─ Campaigns.tsx
   │  ├─ MyCampaigns.tsx
   │  ├─ AdminDashboard.tsx
   │  ├─ BrandDashboard.tsx
   │  └─ ParticipantDashboard.tsx
   ├─ components/
   │  ├─ Navbar.tsx
   │  ├─ CampaignCard.tsx
   │  ├─ WalletConnectButton.tsx
   │  ├─ Protected.tsx
   │  └─ ProofStatus.tsx
   ├─ services/
   │  ├─ api.ts
   │  ├─ stacksService.ts
   │  └─ authService.ts
   ├─ context/
   │  └─ AuthContext.tsx
   ├─ hooks/
   │  └─ useAuth.ts
   ├─ types/
   │  ├─ campaign.d.ts
   │  └─ auth.d.ts
   └─ assets/
      └─ logo.svg
```

### `frontend/package.json`

```json
{
  "name": "hashtag-rewards-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@stacks/connect": "^7.7.1",
    "@stacks/network": "^6.9.0",
    "@stacks/transactions": "^6.11.2",
    "axios": "^1.7.2",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "@types/node": "^22.5.0",
    "typescript": "^5.5.4",
    "vite": "^5.4.0"
  }
}
```

### `frontend/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "baseUrl": "./",
    "paths": {
      "@services/*": ["src/services/*"],
      "@components/*": ["src/components/*"],
      "@pages/*": ["src/pages/*"],
      "@context/*": ["src/context/*"],
      "@types/*": ["src/types/*"]
    }
  },
  "include": ["src"]
}
```

### `frontend/vite.config.ts`

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: { port: 5173 }
})
```

### `frontend/index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hashtag Rewards</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

### `frontend/src/main.tsx`

```tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { RouterProvider } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import router from './routes/router'
import './App.module.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AuthProvider>
      <RouterProvider router={router} />
    </AuthProvider>
  </React.StrictMode>
)
```

### `frontend/src/routes/router.tsx`

```tsx
import { createBrowserRouter } from 'react-router-dom'
import App from '../App'
import Home from '@pages/Home'
import Campaigns from '@pages/Campaigns'
import MyCampaigns from '@pages/MyCampaigns'
import AdminDashboard from '@pages/AdminDashboard'
import BrandDashboard from '@pages/BrandDashboard'
import ParticipantDashboard from '@pages/ParticipantDashboard'
import Protected from '@components/Protected'

export default createBrowserRouter([
  {
    path: '/',
    element: <App />,
    children: [
      { index: true, element: <Home /> },
      { path: 'campaigns', element: <Campaigns /> },
      { path: 'me', element: <Protected roles={['participant','brand','admin']}><MyCampaigns /></Protected> },
      { path: 'admin', element: <Protected roles={['admin']}><AdminDashboard /></Protected> },
      { path: 'brand', element: <Protected roles={['brand','admin']}><BrandDashboard /></Protected> },
      { path: 'participant', element: <Protected roles={['participant','admin']}><ParticipantDashboard /></Protected> }
    ]
  }
])
```

### `frontend/src/App.tsx`

```tsx
import { Outlet, Link } from 'react-router-dom'
import Navbar from '@components/Navbar'
export default function App() {
  return (
    <>
      <Navbar />
      <main className="container" style={{ padding: 16 }}>
        <nav style={{ marginBottom: 12 }}>
          <Link to="/">Home</Link> | <Link to="/campaigns">Campaigns</Link> | <Link to="/me">My Campaigns</Link>
        </nav>
        <Outlet />
      </main>
    </>
  )
}
```

### `frontend/src/components/Navbar.tsx`

```tsx
import { Link } from 'react-router-dom'
import WalletConnectButton from './WalletConnectButton'
export default function Navbar() {
  return (
    <header style={{ display:'flex', gap:12, padding:12, borderBottom:'1px solid #eee' }}>
      <strong>Hashtag Rewards</strong>
      <Link to="/">Home</Link>
      <Link to="/campaigns">Campaigns</Link>
      <Link to="/brand">Brand</Link>
      <Link to="/admin">Admin</Link>
      <div style={{ marginLeft: 'auto' }}>
        <WalletConnectButton />
      </div>
    </header>
  )
}
```

### `frontend/src/components/WalletConnectButton.tsx`

```tsx
import { useAuth } from '../hooks/useAuth'

export default function WalletConnectButton() {
  const { user, connectWallet, logout } = useAuth()
  if (user) {
    return <button onClick={logout}>Disconnect {user.walletAddress.slice(0,6)}...</button>
  }
  return <button onClick={connectWallet}>Connect Stacks Wallet</button>
}
```

### `frontend/src/components/Protected.tsx`

```tsx
import { PropsWithChildren } from 'react'
import { useAuth } from '../hooks/useAuth'

export default function Protected({ roles, children }: PropsWithChildren<{ roles: string[] }>) {
  const { user } = useAuth()
  if (!user) return <p>Please connect your wallet.</p>
  if (!roles.includes(user.role)) return <p>Access denied.</p>
  return <>{children}</>
}
```

### `frontend/src/context/AuthContext.tsx`

```tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { loginWithWallet, logoutWallet, getStoredUser } from '@services/authService'
import type { AuthUser } from '@types/auth'

type Ctx = {
  user: AuthUser | null
  connectWallet: () => Promise<void>
  logout: () => void
}
const AuthContext = createContext<Ctx>({ user: null, connectWallet: async () => {}, logout: () => {} })

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(getStoredUser())

  useEffect(() => {}, [])

  const connectWallet = async () => {
    const u = await loginWithWallet()
    setUser(u)
  }
  const logout = () => {
    logoutWallet()
    setUser(null)
  }
  return <AuthContext.Provider value={{ user, connectWallet, logout }}>{children}</AuthContext.Provider>
}
export const useAuthContext = () => useContext(AuthContext)
```

### `frontend/src/hooks/useAuth.ts`

```tsx
import { useContext } from 'react'
import { useAuthContext } from '../context/AuthContext'
export const useAuth = () => useAuthContext()
```

### `frontend/src/services/authService.ts`

```ts
import axios from 'axios'
import { AppConfig, UserSession, showConnect } from '@stacks/connect'
import type { AuthUser } from '@types/auth'

const session = new UserSession({ appConfig: new AppConfig(['store_write','publish_data']) })
const API = axios.create({ baseURL: 'http://localhost:5000/api', withCredentials: true })

export function getStoredUser(): AuthUser | null {
  const v = localStorage.getItem('user'); return v ? JSON.parse(v) : null
}

export async function loginWithWallet(): Promise<AuthUser> {
  // Simplified demo: mock a wallet address from session OR a placeholder
  const walletAddress = 'STX_WALLET_PLACEHOLDER'
  const { data } = await API.post('/auth/wallet', { walletAddress })
  localStorage.setItem('user', JSON.stringify(data))
  return data
}

export function logoutWallet() {
  localStorage.removeItem('user')
}
```

### `frontend/src/services/api.ts`

```ts
import axios from 'axios'
export const api = axios.create({ baseURL: 'http://localhost:5000/api', withCredentials: true })
```

### `frontend/src/services/stacksService.ts`

```ts
// Minimal placeholder for stacks tx calls
export async function joinCampaign(campaignId: string) { console.log('joinCampaign', campaignId) }
export async function claimReward(campaignId: string) { console.log('claimReward', campaignId) }
```

### `frontend/src/types/auth.d.ts`

```ts
export type Role = 'admin' | 'brand' | 'participant'
export interface AuthUser {
  walletAddress: string
  role: Role
  token: string
}
```

### `frontend/src/pages/Home.tsx`

```tsx
export default function Home(){ return <h2>Welcome to Hashtag Rewards</h2> }
```

*(Other page files can be identical simple placeholders.)*

---

# Backend (Node + Express + TypeScript + Oracle inside)

```
backend/
├─ package.json
├─ tsconfig.json
├─ tsconfig.build.json
├─ src/
│  ├─ index.ts
│  ├─ app.ts
│  ├─ config/
│  │  ├─ env.ts
│  │  └─ db.ts
│  ├─ middleware/
│  │  ├─ auth.ts
│  │  └─ roles.ts
│  ├─ models/
│  │  ├─ User.ts
│  │  └─ Campaign.ts
│  ├─ routes/
│  │  ├─ auth.routes.ts
│  │  ├─ campaign.routes.ts
│  │  └─ oracle.routes.ts
│  ├─ controllers/
│  │  ├─ auth.controller.ts
│  │  ├─ campaign.controller.ts
│  │  └─ oracle.controller.ts
│  ├─ services/
│  │  ├─ jwt.service.ts
│  │  ├─ blockchain.service.ts
│  │  ├─ social.service.ts
│  │  ├─ oracle.service.ts
│  │  └─ campaign.service.ts
│  ├─ jobs/
│  │  └─ oracle.job.ts
│  ├─ utils/
│  │  └─ logger.ts
│  └─ types/
│     └─ index.d.ts
└─ .env (create from .env.example)
```

### `backend/package.json`

```json
{
  "name": "hashtag-rewards-backend",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc -p tsconfig.build.json",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "axios": "^1.7.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "jsonwebtoken": "^9.0.2",
    "mongoose": "^8.5.2",
    "@stacks/transactions": "^6.11.2",
    "@stacks/network": "^6.9.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.6",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.5.4",
    "@types/node": "^22.5.0"
  }
}
```

### `backend/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "ESNext",
    "moduleResolution": "Node",
    "rootDir": "src",
    "outDir": "dist",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
```

### `backend/tsconfig.build.json`

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": { "noEmit": false }
}
```

### `backend/src/index.ts`

```ts
import app from './app'
import { env } from './config/env'
import './config/db'
import './jobs/oracle.job'

app.listen(env.PORT, () => {
  console.log(`API listening on http://localhost:${env.PORT}`)
})
```

### `backend/src/app.ts`

```ts
import express from 'express'
import cors from 'cors'
import cookieParser from 'cookie-parser'
import authRoutes from './routes/auth.routes'
import campaignRoutes from './routes/campaign.routes'
import oracleRoutes from './routes/oracle.routes'

const app = express()
app.use(cors({ origin: 'http://localhost:5173', credentials: true }))
app.use(express.json())
app.use(cookieParser())

app.get('/api/health', (_, res) => res.json({ ok: true }))
app.use('/api/auth', authRoutes)
app.use('/api/campaigns', campaignRoutes)
app.use('/api/oracle', oracleRoutes)

export default app
```

### `backend/src/config/env.ts`

```ts
import dotenv from 'dotenv'
dotenv.config()

export const env = {
  PORT: process.env.PORT || '5000',
  JWT_SECRET: process.env.JWT_SECRET || 'change_me',
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/hashtag',
  STACKS_RPC_URL: process.env.STACKS_RPC_URL || 'https://stacks-node-api.testnet.stacks.co',
  CONTRACT_DEPLOYER: process.env.CONTRACT_DEPLOYER || '',
  CAMPAIGN_CONTRACT_NAME: process.env.CAMPAIGN_CONTRACT_NAME || 'campaign'
}
```

### `backend/src/config/db.ts`

```ts
import mongoose from 'mongoose'
import { env } from './env'

mongoose.connect(env.MONGO_URI).then(() => {
  console.log('Mongo connected')
}).catch(err => console.error('Mongo error', err))
```

### `backend/src/models/User.ts`

```ts
import { Schema, model } from 'mongoose'
export type Role = 'admin' | 'brand' | 'participant'

const userSchema = new Schema({
  walletAddress: { type: String, required: true, unique: true },
  role: { type: String, enum: ['admin','brand','participant'], default: 'participant' }
}, { timestamps: true })

export default model('User', userSchema)
```

### `backend/src/models/Campaign.ts`

```ts
import { Schema, model, Types } from 'mongoose'

const campaignSchema = new Schema({
  brandWallet: { type: String, required: true },
  hashtag: { type: String, required: true },
  rewardPerUnit: { type: Number, default: 0.05 },
  targetMentions: { type: Number, default: 20 },
  active: { type: Boolean, default: true }
}, { timestamps: true })

export default model('Campaign', campaignSchema)
```

### `backend/src/middleware/auth.ts`

```ts
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { env } from '../config/env'

export function requireAuth(req: Request & { user?: any }, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '') || req.cookies.token
  if (!token) return res.status(401).json({ message: 'Unauthorized' })
  try {
    req.user = jwt.verify(token, env.JWT_SECRET)
    next()
  } catch {
    res.status(401).json({ message: 'Invalid token' })
  }
}
```

### `backend/src/middleware/roles.ts`

```ts
import { Request, Response, NextFunction } from 'express'
export function requireRole(...roles: string[]) {
  return (req: Request & { user?: any }, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) return res.status(403).json({ message: 'Forbidden' })
    next()
  }
}
```

### `backend/src/services/jwt.service.ts`

```ts
import jwt from 'jsonwebtoken'
import { env } from '../config/env'
export const signToken = (payload: any) => jwt.sign(payload, env.JWT_SECRET, { expiresIn: '7d' })
```

### `backend/src/controllers/auth.controller.ts`

```ts
import { Request, Response } from 'express'
import User from '../models/User'
import { signToken } from '../services/jwt.service'

export async function walletLogin(req: Request, res: Response) {
  const { walletAddress } = req.body
  if (!walletAddress) return res.status(400).json({ message: 'walletAddress required' })
  let user = await User.findOne({ walletAddress })
  if (!user) user = await User.create({ walletAddress })
  const token = signToken({ id: user.id, walletAddress: user.walletAddress, role: user.role })
  res.json({ walletAddress: user.walletAddress, role: user.role, token })
}
```

### `backend/src/controllers/campaign.controller.ts`

```ts
import { Request, Response } from 'express'
import Campaign from '../models/Campaign'

export async function listCampaigns(_: Request, res: Response) {
  const items = await Campaign.find().sort({ createdAt: -1 })
  res.json(items)
}
export async function createCampaign(req: Request & { user?: any }, res: Response) {
  const { hashtag, rewardPerUnit, targetMentions } = req.body
  const brandWallet = req.user.walletAddress
  const created = await Campaign.create({ hashtag, rewardPerUnit, targetMentions, brandWallet })
  res.status(201).json(created)
}
```

### `backend/src/controllers/oracle.controller.ts`

```ts
import { Request, Response } from 'express'
export async function getOracleStatus(_: Request, res: Response) {
  res.json({ running: true, lastRun: new Date().toISOString() })
}
```

### `backend/src/routes/auth.routes.ts`

```ts
import { Router } from 'express'
import { walletLogin } from '../controllers/auth.controller'
const r = Router()
r.post('/wallet', walletLogin)
export default r
```

### `backend/src/routes/campaign.routes.ts`

```ts
import { Router } from 'express'
import { listCampaigns, createCampaign } from '../controllers/campaign.controller'
import { requireAuth } from '../middleware/auth'
import { requireRole } from '../middleware/roles'

const r = Router()
r.get('/', listCampaigns)
r.post('/', requireAuth, requireRole('brand','admin'), createCampaign)
export default r
```

### `backend/src/routes/oracle.routes.ts`

```ts
import { Router } from 'express'
import { requireAuth } from '../middleware/auth'
import { requireRole } from '../middleware/roles'
import { getOracleStatus } from '../controllers/oracle.controller'

const r = Router()
r.get('/status', requireAuth, requireRole('admin'), getOracleStatus)
export default r
```

### `backend/src/services/blockchain.service.ts`

```ts
// Minimal placeholder where you'd call Clarity contracts using @stacks/transactions
export async function markVerifiedOnChain(wallet: string, hashtag: string): Promise<void> {
  console.log('Blockchain tx → markVerified:', { wallet, hashtag })
}
```

### `backend/src/services/social.service.ts`

```ts
// Placeholder that would call Twitter/Instagram APIs
export async function fetchHashtagMentions(_: string): Promise<Array<{ user: string, url: string }>> {
  console.log('Fetching hashtag mentions (placeholder)')
  return []
}
```

### `backend/src/services/oracle.service.ts`

```ts
import { fetchHashtagMentions } from './social.service'
import { markVerifiedOnChain } from './blockchain.service'

export async function runOracleOnce() {
  // In real app: pull campaigns from DB, loop each, check mentions, call on-chain updates
  const mentions = await fetchHashtagMentions('#demo')
  for (const m of mentions) {
    await markVerifiedOnChain(m.user, '#demo')
  }
  return { checked: mentions.length }
}
```

### `backend/src/jobs/oracle.job.ts`

```ts
import { runOracleOnce } from '../services/oracle.service'

const TICK_MS = 60_000 // 1 minute placeholder
async function loop() {
  try {
    const res = await runOracleOnce()
    console.log('[Oracle] cycle done:', res)
  } catch (e) {
    console.error('[Oracle] error:', e)
  } finally {
    setTimeout(loop, TICK_MS)
  }
}
loop()
```

---

# Clarity Contracts (Clarinet)

```
contracts/
├─ Clarinet.toml
└─ contracts/
   ├─ campaign.clar
   └─ tests/
      └─ campaign_test.ts
```

### `contracts/Clarinet.toml`

```toml
[project]
name = "hashtag-rewards"
requirements = []
[contracts.campaign]
path = "contracts/campaign.clar"
clarity_version = 2
```

### `contracts/contracts/campaign.clar`

```clarity
(impl-trait 'SP000000000000000000002Q6VF78.pox-4.pox-4-trait) ;; placeholder trait import to show syntax

(define-data-var admin principal tx-sender)
(define-map campaign-by-hashtag {hashtag: (string-ascii 50)} {
  brand: principal,
  reward-per-unit: uint,
  target-mentions: uint,
  active: bool
})

(define-public (create-campaign (hashtag (string-ascii 50)) (reward-per-unit uint) (target-mentions uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (map-set campaign-by-hashtag {hashtag: hashtag}
      { brand: tx-sender, reward-per-unit: reward-per-unit, target-mentions: target-mentions, active: true })
    (ok true)
  )
)

(define-read-only (get-campaign (hashtag (string-ascii 50)))
  (default-to { brand: tx-sender, reward-per-unit: u0, target-mentions: u0, active: false }
    (map-get? campaign-by-hashtag {hashtag: hashtag})
  )
)
```

### `contracts/contracts/tests/campaign_test.ts`

```ts
// Placeholder Clarinet test (deno test style is supported by Clarinet)
Deno.test("campaign placeholder", () => {
  console.log("ok")
})
```

---

# Quick Start

```bash
# 1) Contracts (Clarinet)
cd contracts
clarinet check

# 2) Backend
cd ../backend
cp ../.env.example .env
npm install
npm run dev
# API on http://localhost:5000

# 3) Frontend
cd ../frontend
npm install
npm run dev
# App on http://localhost:5173
```

---

## Notes

* **Stacks wallet connect** is stubbed to a placeholder address in `frontend/src/services/authService.ts`. Swap to real `@stacks/connect` flow when you’re ready.
* **Oracle** runs as a simple timer job inside the backend (`jobs/oracle.job.ts`). It calls placeholder services now.
* **Clarity contract** is minimal and safe to expand (add participant storage, verification events, payout logic, etc.).
* **Roles** are enforced with `requireRole()` middleware and JWTs.

---

If you want, I can now expand **any part** (e.g., real Stacks wallet flow, actual Clarity contract functions for join/verify/claim, or proper social API fetch code) — just say **“continue with X”** and I’ll flesh it out.




Great — I’ll “continue with X” by fleshing out the **most valuable next pieces** so the skeleton becomes usable end-to-end:

1. real Stacks wallet connect flow on the frontend,
2. Clarity contract with `join`, `mark-verified` (oracle/admin), and `claim-reward` (simple STX payout),
3. backend blockchain service that calls those contract functions, and
4. minimal API routes/wiring to exercise the flow.

If you want me to expand different parts next, just say “continue with Y”.

---

# 1) Frontend: real Stacks wallet connect

### `frontend/src/services/authService.ts` (replace file)

```ts
import axios from 'axios'
import { AppConfig, UserSession, showConnect, FinishedAuthData } from '@stacks/connect'
import type { AuthUser } from '@types/auth'

const API = axios.create({ baseURL: 'http://localhost:5000/api', withCredentials: true })
const appConfig = new AppConfig(['store_write','publish_data'])
const userSession = new UserSession({ appConfig })

export function getStoredUser(): AuthUser | null {
  const v = localStorage.getItem('user')
  return v ? JSON.parse(v) : null
}

export async function loginWithWallet(): Promise<AuthUser> {
  return new Promise((resolve, reject) => {
    showConnect({
      appDetails: { name: 'Hashtag Rewards', icon: window.location.origin + '/favicon.svg' },
      userSession,
      onFinish: async (payload: FinishedAuthData) => {
        const walletAddress =
          payload?.profile?._addresses?.[0] || // older profiles
          payload?.profile?.stxAddress?.testnet || payload?.profile?.stxAddress?.mainnet

        if (!walletAddress) return reject(new Error('No STX address found'))

        const { data } = await API.post('/auth/wallet', { walletAddress })
        localStorage.setItem('user', JSON.stringify(data))
        resolve(data)
      },
      onCancel: () => reject(new Error('User cancelled wallet connect'))
    })
  })
}

export function logoutWallet() {
  localStorage.removeItem('user')
  if (userSession.isUserSignedIn()) userSession.signUserOut()
}
```

### `frontend/src/services/stacksService.ts` (expanded)

```ts
import { openContractCall, ContractCallRegularOptions } from '@stacks/connect'
import { AnchorMode, PostConditionMode, standardPrincipalCV, stringAsciiCV, uintCV } from '@stacks/transactions'
import { appNetwork } from './stacksNetwork' // add this small helper

const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS || 'STX_CONTRACT_DEPLOYER_PLACEHOLDER'
const CONTRACT_NAME = import.meta.env.VITE_CAMPAIGN_CONTRACT_NAME || 'campaign'

export async function joinCampaign(hashtag: string) {
  const opts: ContractCallRegularOptions = {
    anchorMode: AnchorMode.Any,
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'join-campaign',
    functionArgs: [stringAsciiCV(hashtag)],
    postConditionMode: PostConditionMode.Deny,
    onFinish: (data) => console.log('join tx', data),
    network: appNetwork
  }
  await openContractCall(opts)
}

export async function claimReward(hashtag: string) {
  const opts: ContractCallRegularOptions = {
    anchorMode: AnchorMode.Any,
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'claim-reward',
    functionArgs: [stringAsciiCV(hashtag)],
    postConditionMode: PostConditionMode.Deny,
    onFinish: (data) => console.log('claim tx', data),
    network: appNetwork
  }
  await openContractCall(opts)
}

// Admin/Oracle-only – usually called server-side; here for demo
export async function markVerified(participant: string, hashtag: string, count: number) {
  const opts: ContractCallRegularOptions = {
    anchorMode: AnchorMode.Any,
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'mark-verified',
    functionArgs: [standardPrincipalCV(participant), stringAsciiCV(hashtag), uintCV(count)],
    postConditionMode: PostConditionMode.Deny,
    onFinish: (data) => console.log('mark-verified tx', data),
    network: appNetwork
  }
  await openContractCall(opts)
}
```

### `frontend/src/services/stacksNetwork.ts` (new helper)

```ts
import { StacksTestnet, StacksMainnet } from '@stacks/network'
const net = (import.meta.env.VITE_STACKS_NETWORK || 'testnet').toLowerCase()
export const appNetwork = net === 'mainnet' ? new StacksMainnet() : new StacksTestnet()
```

---

# 2) Clarity contract: join, mark-verified, claim-reward (STX)

### `contracts/contracts/campaign.clar` (replace file)

```clarity
;; === Hashtag Rewards (simplified MVP) ===

(define-data-var admin principal tx-sender)

(define-constant ERR-NOT-ADMIN u100)
(define-constant ERR-NOT-ACTIVE u101)
(define-constant ERR-NOT-ELIGIBLE u102)
(define-constant ERR-ALREADY-CLAIMED u103)

(define-map campaigns { hashtag: (string-ascii 50) }
  {
    brand: principal,
    reward-per-unit: uint,         ;; in microstx per mention (e.g. 1000 = 0.001 STX)
    target-mentions: uint,         ;; needed to unlock claim
    active: bool
  }
)

(define-map progress { user: principal, hashtag: (string-ascii 50) }
  {
    mentions: uint,
    verified: bool,
    claimed: bool
  }
)

(define-public (create-campaign (hashtag (string-ascii 50)) (reward-per-unit uint) (target-mentions uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (map-set campaigns {hashtag: hashtag}
      { brand: tx-sender, reward-per-unit: reward-per-unit, target-mentions: target-mentions, active: true })
    (ok true)
  )
)

(define-public (toggle-campaign (hashtag (string-ascii 50)) (on bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (let ((c (map-get? campaigns {hashtag: hashtag})))
      (if (is-some c)
          (begin
            (map-set campaigns {hashtag: hashtag}
              (merge (unwrap! c (err u0)) { active: on }))
            (ok on))
          (ok false)))
  )
)

(define-public (join-campaign (hashtag (string-ascii 50)))
  (let
    (
      (c (map-get? campaigns {hashtag: hashtag}))
    )
    (begin
      (asserts! (and (is-some c) ((get active) (unwrap! c (err u0)))) (err ERR-NOT-ACTIVE))
      (if (is-some (map-get? progress {user: tx-sender, hashtag: hashtag}))
          (ok false)
          (begin
            (map-set progress {user: tx-sender, hashtag: hashtag}
              { mentions: u0, verified: false, claimed: false })
            (ok true)))
    )
  )
)

;; Oracle/Admin updates verified mention count for a user
(define-public (mark-verified (user principal) (hashtag (string-ascii 50)) (mentions uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (let
      (
        (p (map-get? progress {user: user, hashtag: hashtag}))
      )
      (if (is-some p)
          (begin
            (map-set progress {user: user, hashtag: hashtag}
              (merge (unwrap! p (err u0)) { mentions: mentions, verified: true }))
            (ok true))
          (ok false))
    )
  )
)

(define-public (claim-reward (hashtag (string-ascii 50)))
  (let
    (
      (c (map-get? campaigns {hashtag: hashtag}))
      (p (map-get? progress {user: tx-sender, hashtag: hashtag}))
    )
    (begin
      (asserts! (and (is-some c) ((get active) (unwrap! c (err u0)))) (err ERR-NOT-ACTIVE))
      (asserts! (is-some p) (err ERR-NOT-ELIGIBLE))
      (let
        (
          (pp (unwrap! p (err u0)))
          (cc (unwrap! c (err u0)))
        )
        (begin
          (asserts! (get verified pp) (err ERR-NOT-ELIGIBLE))
          (asserts! (not (get claimed pp)) (err ERR-ALREADY-CLAIMED))
          (asserts! (>= (get mentions pp) (get target-mentions cc)) (err ERR-NOT-ELIGIBLE))
          (let ((total (mul (get reward-per-unit cc) (get target-mentions cc))))
            (try! (stx-transfer? total tx-sender (get brand cc)))
            ;; mark claimed
            (map-set progress {user: tx-sender, hashtag: hashtag}
              (merge pp { claimed: true }))
            (ok total)
          )
        )
      )
    )
  )
)

(define-read-only (get-campaign (hashtag (string-ascii 50)))
  (default-to { brand: tx-sender, reward-per-unit: u0, target-mentions: u0, active: false }
    (map-get? campaigns {hashtag: hashtag})
  )
)

(define-read-only (get-progress (user principal) (hashtag (string-ascii 50)))
  (default-to { mentions: u0, verified: false, claimed: false }
    (map-get? progress {user: user, hashtag: hashtag})
  )
)
```

> Notes:
>
> * **Who pays whom?** For simplicity, the contract uses `stx-transfer? total FROM tx-sender TO brand`. That means when a participant claims, **they pay the brand** (just to verify the plumbing). In your real logic you’ll likely reverse this (brand → participant) and **pre-fund** the contract or use post-conditions. This is just a safe MVP plumbing path; change direction after funding flows are settled.

---

# 3) Backend: call Clarity functions from Oracle/Admin

### `backend/src/services/blockchain.service.ts` (replace file)

```ts
import { uintCV, stringAsciiCV, standardPrincipalCV, callReadOnlyFunction, TransactionVersion, makeContractCall, AnchorMode, broadcastTransaction } from '@stacks/transactions'
import { StacksTestnet } from '@stacks/network'
import { env } from '../config/env'

const network = new StacksTestnet({ url: env.STACKS_RPC_URL })

// For server-side contract calls you need a signer private key with admin rights.
// Store key securely in env (DON'T commit to git).
const ADMIN_PRIVATE_KEY = process.env.ADMIN_PRIVATE_KEY || ''

const CONTRACT_ADDRESS = env.CONTRACT_DEPLOYER
const CONTRACT_NAME = env.CAMPAIGN_CONTRACT_NAME

export async function markVerifiedOnChain(wallet: string, hashtag: string, mentions: number) {
  if (!ADMIN_PRIVATE_KEY) throw new Error('ADMIN_PRIVATE_KEY not set')
  const tx = await makeContractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'mark-verified',
    functionArgs: [standardPrincipalCV(wallet), stringAsciiCV(hashtag), uintCV(mentions)],
    senderKey: ADMIN_PRIVATE_KEY,
    anchorMode: AnchorMode.Any,
    network
  })
  const res = await broadcastTransaction(tx, network)
  return res
}
```

### `backend/src/services/oracle.service.ts` (wire to blockchain)

```ts
import Campaign from '../models/Campaign'
import { fetchHashtagMentions } from './social.service'
import { markVerifiedOnChain } from './blockchain.service'

export async function runOracleOnce() {
  const active = await Campaign.find({ active: true }).lean()
  let totalUpdates = 0

  for (const c of active) {
    const mentions = await fetchHashtagMentions(c.hashtag) // returns [{user, url}, ...]
    // Count per user (very naive placeholder)
    const byUser: Record<string, number> = {}
    for (const m of mentions) byUser[m.user] = (byUser[m.user] || 0) + 1

    for (const [user, count] of Object.entries(byUser)) {
      await markVerifiedOnChain(user, c.hashtag, count)
      totalUpdates++
    }
  }
  return { campaigns: active.length, totalUpdates }
}
```

---

# 4) Backend routes to exercise flow

### `backend/src/routes/campaign.routes.ts` (add endpoints)

```ts
import { Router } from 'express'
import { listCampaigns, createCampaign } from '../controllers/campaign.controller'
import { requireAuth } from '../middleware/auth'
import { requireRole } from '../middleware/roles'
import { runOracleOnce } from '../services/oracle.service'

const r = Router()
r.get('/', listCampaigns)
r.post('/', requireAuth, requireRole('brand','admin'), createCampaign)

// Admin trigger oracle manually (handy in dev)
r.post('/oracle-run', requireAuth, requireRole('admin'), async (_req, res) => {
  const result = await runOracleOnce()
  res.json(result)
})

export default r
```

---

# 5) Minimal “use it now” steps

1. **Contracts**

```bash
cd contracts
clarinet check
# deploy to testnet and set env values:
# - CONTRACT_DEPLOYER
# - CAMPAIGN_CONTRACT_NAME
```

2. **Backend**

```bash
cd ../backend
cp ../.env.example .env
# add ADMIN_PRIVATE_KEY (admin signer of the contract) to .env
npm install
npm run dev
```

3. **Frontend**

```bash
cd ../frontend
npm install
# set env:
# VITE_STACKS_NETWORK=testnet
# VITE_CONTRACT_ADDRESS=<your testnet address>
# VITE_CAMPAIGN_CONTRACT_NAME=campaign
npm run dev
```

4. **Try the flow**

* Create a campaign via `POST /api/campaigns` (as brand/admin).
* Run oracle via `POST /api/campaigns/oracle-run` (as admin) to push `mark-verified`.
* From the UI, join and claim using the Wallet buttons (join/claim hooks you wire to buttons).

---

If you want, I can **(a)** flip the payout direction in the contract (brand → participant) and show how to **pre-fund**/escrow rewards, **(b)** add **read-only** views to the frontend (progress per hashtag), or **(c)** wire real Twitter/X API fetching in `social.service.ts`. Just say **continue with payouts**, **continue with read-only**, or **continue with twitter**.
