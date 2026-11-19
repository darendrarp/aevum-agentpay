// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {AgentVault} from "../src/AgentVault.sol";
import {InvoiceRegistry} from "../src/InvoiceRegistry.sol";
import {MockTUSD8} from "../src/mocks/MockTUSD8.sol";

/// @notice Test skeleton for AgentVault. Full suite lands in the 9–11 Dec build.
/// Planned coverage (see CONCEPT.md §3–§4):
///  - deposit/withdraw: balances, events, insufficient-balance revert
///  - grantSession: id derivation, allowlist storage, event, zero-address/zero-cap reverts
///  - revokeSession: owner-only, agent spend reverts after revoke
///  - payInvoice happy path: caps debited, invoice PAID, funds moved, receipt event
///  - payInvoice reverts: wrong caller, expired session, revoked session, over per-payment
///    cap, over total cap, payee not allowlisted, invoice already paid, invoice expired
///  - fuzz: spent never exceeds totalCap across arbitrary payment sequences
contract AgentVaultTest is Test {
    MockTUSD8 internal token;
    InvoiceRegistry internal registry;
    AgentVault internal vault;

    address internal owner = makeAddr("owner");
    address internal agent = makeAddr("agent");
    address internal merchant = makeAddr("merchant");

    function setUp() public {
        token = new MockTUSD8();
        // Registry needs the vault address; vault needs the registry address.
        // Deploy order is resolved at build time (registry with a placeholder vault,
        // or a factory). For the skeleton, deploy vault first with a temp registry.
        registry = new InvoiceRegistry(address(this));
        vault = new AgentVault(token, registry);
        token.mint(owner, 1_000_000e6);
    }

    function test_SkeletonCompiles() public view {
        assertEq(address(vault.TOKEN()), address(token));
        assertEq(address(vault.REGISTRY()), address(registry));
    }

    // TODO(9–11 Dec): implement the full suite listed above.
}
