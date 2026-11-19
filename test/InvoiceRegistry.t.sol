// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {InvoiceRegistry} from "../src/InvoiceRegistry.sol";

/// @notice Test skeleton for InvoiceRegistry. Full suite lands in the 9–11 Dec build.
/// Planned coverage:
///  - createInvoice: id sequence from 1, stored fields, event, zero-amount/zero-payee reverts
///  - cancelInvoice: issuer-only, UNPAID-only, status transition
///  - settle: vault-only, UNPAID-only, expiry check, status transition + event
///  - refundInvoice: payee-only, PAID-only, funds returned, status transition
///  - getInvoice: full struct read-back
contract InvoiceRegistryTest is Test {
    InvoiceRegistry internal registry;

    address internal vault = makeAddr("vault");
    address internal merchant = makeAddr("merchant");

    function setUp() public {
        registry = new InvoiceRegistry(vault);
    }

    function test_SkeletonCompiles() public view {
        assertEq(registry.VAULT(), vault);
        assertEq(registry.nextId(), 1);
    }

    // TODO(9–11 Dec): implement the full suite listed above.
}
