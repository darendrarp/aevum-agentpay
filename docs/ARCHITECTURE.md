# Architecture notes

Full specification: `../CONCEPT.md` (prep workspace). This file records the decisions
that shape the code.

## Contracts

- **`AgentVault`** — holds owner tUSD8; owns sessions. `payInvoice` is the only function
  that moves funds out, and only to an invoice's payee. Validation order (gas-cheap
  checks first, state changes last): session exists → not revoked → not expired →
  caller is agent → invoice payable → payee allowlisted → per-payment cap → total cap.
  Then: mark PAID via the registry, update spent + balance, transfer, emit receipt.
- **`InvoiceRegistry`** — holds invoices. Only the vault may `settle`. No funds live here;
  refunds are decided at build time (push vs pull — see `InvoiceRegistry.sol` TODO).
- **No upgradeability, no admin keys** beyond the session owner's own revoke/withdraw.
  The owner cannot touch another owner's funds or sessions.

## Open design decision (resolve 9–10 Dec)

Vault ↔ registry circular constructor dependency: the vault needs the registry address
and the registry needs the vault address. Candidates: (A) two-step deploy, (B) factory
contract, (C) registry `VAULT` settable once by the deployer. Recommend (C) for
simplicity or (B) for cleanliness — decide during implementation; tests must cover the
chosen path.

## Security invariants (must hold in tests)

1. `spent(session)` never exceeds `totalCap(session)`.
2. No single payment exceeds `perPaymentCap(session)`.
3. Funds only leave the vault to an allowlisted payee of an active session, against a
   previously UNPAID invoice.
4. Each invoice is paid at most once.
5. An expired or revoked session can never spend.
6. An owner can always withdraw their unspent balance (no griefing via sessions).
7. No reentrancy: all external calls happen after state updates, plus `ReentrancyGuard`.

## Why no ERC-4337 / x402 / QDay SDK in v1

The QDay SDK ships Q1 2027 (not on npm); ERC-4337 bundler/paymaster and x402 facilitator
endpoints on Aevum are unconfirmed. The vault implements session semantics in plain
Solidity, so it works with any EOA agent today. Integrations are roadmap items, not
dependencies — see `CONCEPT.md` §5 stretch goals.
