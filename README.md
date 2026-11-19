# AgentPay — Scoped Spending Vaults for AI Agents

> **Aevum Builder Challenge #1** (QDay / DoraHacks) · Track: Native AI Assistants ·
> Prize pool $1,500 USDT · Submit by **11 Dec 2026, 16:00 HKT (08:00 UTC / 15:00 WIB)**

Let AI agents pay — with caps, expiry, allowlists, and instant revocation. Guardrailed
agent spending on QDay Aevum Testnet, settled in tUSD8.

**Status: preparation skeleton (19 Nov 2026).** Concept, research, and project structure
are ready; the full build happens 9–11 Dec 2026 (after the Agent ID Hackathon closes).
Contracts are interface-complete stubs — function bodies land in the build window.
See [`CONCEPT.md`](../CONCEPT.md) (prep workspace) for the full specification.

## The problem

AI agents need to pay for APIs, data, and services — but handing an agent a funded wallet
is unlimited liability. One compromised key, one prompt injection, one runaway loop, and
the balance is gone.

## The solution

An owner deposits tUSD8 into an on-chain vault and grants an agent a **session**: a bounded,
revocable permission to spend, with a total cap, a per-payment cap, an expiry timestamp,
and a payee allowlist. The agent pays merchant invoices through the vault; every payment
emits a verifiable receipt event — a complete on-chain audit trail. The owner can revoke a
session instantly and withdraw unspent funds at any time.

**One end-to-end flow:** owner funds vault → grants agent a session ($50 total / $20 per
payment / 24 h / merchant allowlisted) → merchant issues invoice #7 for $12.50 → agent
pays → invoice marked PAID with a tx hash → owner reviews the receipt → owner revokes the
session.

## Architecture

```
Owner ──deposit/grant/revoke──▶ AgentVault ──tUSD8──▶ payee
Merchant ──create invoice──▶ InvoiceRegistry (UNPAID → PAID)
Demo agent ──payInvoice(session, invoice)──▶ AgentVault (checks caps/expiry/allowlist)
Dashboard ──reads events──▶ audit trail (PaymentSettled receipts + explorer links)
```

| Component | Path | Description |
|---|---|---|
| `AgentVault` | `src/AgentVault.sol` | Vault balances, sessions (agent, caps, expiry, allowlist), `payInvoice` |
| `InvoiceRegistry` | `src/InvoiceRegistry.sol` | Invoices (amount, payee, ref, due), lifecycle UNPAID → PAID / CANCELLED / REFUNDED |
| `MockTUSD8` | `src/mocks/MockTUSD8.sol` | Test-only 6-decimal ERC-20 for the Foundry suite |
| Demo agent | `agent/` | TypeScript + viem scripted agent (happy path + 5 negative cases) |
| Dashboard | `app/` | Vite + React + wagmi: fund · grant/revoke · invoices · audit trail |

## Network — QDay Aevum Testnet

| Item | Value |
|---|---|
| Chain ID | 44005 |
| RPC | https://rpc-test.qday.info |
| Explorer | https://explorer-test.qday.info (Blockscout) |
| Gas token | tQDAY — faucet: https://faucet.qday.info/en |
| tUSD8 (6 decimals) | `0x456569838f1d43009A91ebA4263147Afd7233483` |

## Quick start

```bash
git clone https://github.com/darendrarp/aevum-agentpay.git
cd aevum-agentpay
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts
forge build
forge test                    # contract test suite (no testnet needed)
```

Testnet deploy (build window, testnet-only key):

```bash
cp .env.example .env          # set PRIVATE_KEY (testnet only!)
forge script script/Deploy.s.sol --rpc-url https://rpc-test.qday.info --broadcast
forge verify-contract --chain-id 44005 --verifier blockscout \
  --verifier-url https://explorer-test.qday.info/api <ADDRESS> src/AgentVault.sol:AgentVault
```

## Project layout

```
agentpay/
├── src/                    # Solidity contracts (Foundry)
│   ├── AgentVault.sol
│   ├── InvoiceRegistry.sol
│   └── mocks/MockTUSD8.sol
├── test/                   # Foundry tests
├── script/Deploy.s.sol     # Testnet deploy script
├── agent/                  # Demo agent (TypeScript + viem) — build window
├── app/                    # Dashboard (Vite + React + wagmi) — build window
├── docs/ARCHITECTURE.md    # Architecture notes
└── foundry.toml
```

## Documentation

- **Concept (problem, solution, demo flow, build plan):** `../CONCEPT.md` in the prep
  workspace (will move to `docs/` at build time).
- **Research (deadline verification, network params, judging criteria, gaps):**
  `../RESEARCH.md`.
- **Submission draft:** `../SUBMISSION_DRAFT.md`.
- **Architecture notes:** `docs/ARCHITECTURE.md`.

## Known limitations (skeleton stage)

- Contract function bodies are `NotImplemented` stubs — implemented 9–11 Dec.
  `forge build` / `forge test` verification runs with the full implementation.
- Dependencies (`lib/`) are not vendored in this repo — install with Forge (see above).
- Vault ↔ registry constructor circularity is an open TODO (see `script/Deploy.s.sol`).
- QDay domains were unreachable from the prep VM on 19 Nov 2026 — connectivity must be
  re-checked on build day 0; deploy may need to run from another machine.
- tUSD8 acquisition path (faucet/portal) to be confirmed on build day 0.
- No QDay SDK dependency by design — the SDK ships Q1 2027. Build uses Foundry + viem only.

## License

MIT. See `LICENSE`.
