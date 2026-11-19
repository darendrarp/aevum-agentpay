# Dashboard (Vite + React + wagmi/RainbowKit) — build window 9–11 Dec 2026

One page, four panels:

1. **Vault** — balance + deposit / withdraw.
2. **Sessions** — grant form (agent, total cap, per-payment cap, expiry, allowlist) +
   revoke buttons + live session list.
3. **Invoices** — create form + list with status (UNPAID / PAID / CANCELLED / REFUNDED).
4. **Audit trail** — recent `PaymentSettled` / session events with explorer links.

Wallet connect via RainbowKit, chain locked to QDay Aevum Testnet (44005).

If time is short, this may be reduced to a read-only audit view + the scripted agent demo —
the challenge requires "a simple interface **or** script", so the scripts alone satisfy the
deliverable. The dashboard exists to win the UX (10) and Demo (10) points.

Setup (build window):

```bash
cd app
npm install
npm run dev     # local dev
npm run build   # deploy the build to Vercel for the submission link
```
