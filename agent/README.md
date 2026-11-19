# Demo agent (TypeScript + viem) — build window 9–11 Dec 2026

A scripted agent that performs the submission demo task: *"Pay invoice #7 for API usage,
then report."*

Planned behaviour (`demo.ts`):
1. Read its session from `AgentVault` (caps, expiry, spent, allowlist).
2. Read invoice #7 from `InvoiceRegistry`.
3. Validate locally: amount ≤ per-payment cap, spent + amount ≤ total cap, payee
   allowlisted, session not expired, invoice UNPAID and not past due.
4. Send `payInvoice(sessionId, 7)`, wait for receipt, print the explorer link.
5. Run the five negative cases (each expected to revert with a named error) and log them:
   over-cap payment, expired session, non-allowlisted payee, double-pay, revoked session.

No LLM call is required — the agent is the *spender* and its decisions are rule-based and
auditable. An LLM-driven variant (parse a natural-language task into a payment instruction)
is a stretch goal.

Setup (build window):

```bash
cd agent
npm install
cp ../.env.example ../.env   # set AGENT_PRIVATE_KEY (testnet only!)
npm run demo
```
