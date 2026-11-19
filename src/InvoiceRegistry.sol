// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title InvoiceRegistry
/// @notice Merchant invoices settled in tUSD8 through the AgentVault.
/// @dev A merchant (or service) creates an invoice — amount, payee, reference, due date.
/// Only the vault may mark an invoice PAID (via `settle`, called during `payInvoice`).
/// Lifecycle: UNPAID -> PAID | CANCELLED | REFUNDED. Each invoice is payable exactly once.
///
/// SKELETON — full implementation lands in the 9–11 Dec 2026 build window.
/// See ../CONCEPT.md for the full specification.
contract InvoiceRegistry {
    /// @notice The vault allowed to settle invoices. Set once at deploy.
    address public immutable VAULT;

    enum Status {
        UNPAID,
        PAID,
        CANCELLED,
        REFUNDED
    }

    struct Invoice {
        address issuer; // who created the invoice
        address payee; // who receives the payment
        uint256 amount; // exact tUSD8 amount (6 decimals)
        uint48 dueAt; // payment deadline (0 = no deadline)
        Status status;
        string ref; // human reference, e.g. "API usage — November"
    }

    /// @notice invoiceId => Invoice. Ids start at 1.
    mapping(uint256 id => Invoice) public invoices;

    /// @notice Next invoice id to assign.
    uint256 public nextId = 1;

    event InvoiceCreated(
        uint256 indexed invoiceId, address indexed issuer, address indexed payee, uint256 amount, string ref
    );
    event InvoicePaid(uint256 indexed invoiceId, address indexed payer, uint256 amount);
    event InvoiceCancelled(uint256 indexed invoiceId);
    event InvoiceRefunded(uint256 indexed invoiceId, uint256 amount);

    error NotImplemented();
    error ZeroAmount();
    error ZeroAddress();
    error NotVault();
    error NotIssuer();
    error NotPayee();
    error NotPayable();
    error InvoiceExpired();
    error NotRefundable();

    modifier onlyVault() {
        if (msg.sender != VAULT) revert NotVault();
        _;
    }

    constructor(address vault_) {
        if (vault_ == address(0)) revert ZeroAddress();
        VAULT = vault_;
    }

    /// @notice Create an invoice.
    /// @param payee Who receives the payment.
    /// @param amount Exact tUSD8 amount.
    /// @param dueAt Payment deadline (0 = no deadline).
    /// @param ref Human-readable reference.
    /// @return invoiceId The new invoice id.
    /// @dev TODO: implement (validate, store, emit event).
    function createInvoice(address payee, uint256 amount, uint48 dueAt, string calldata ref)
        external
        returns (uint256 invoiceId)
    {
        payee;
        amount;
        dueAt;
        ref;
        revert NotImplemented();
    }

    /// @notice Cancel an UNPAID invoice. Issuer only.
    /// @dev TODO: implement.
    function cancelInvoice(uint256 invoiceId) external {
        invoiceId;
        revert NotImplemented();
    }

    /// @notice Mark an invoice PAID. Vault only — called from AgentVault.payInvoice
    /// after all session checks pass.
    /// @dev TODO: implement (status + expiry checks, set PAID, emit event).
    function settle(uint256 invoiceId, address payer) external onlyVault {
        invoiceId;
        payer;
        revert NotImplemented();
    }

    /// @notice Refund a PAID invoice. Payee only; moves funds back to the payer.
    /// @dev TODO: implement at build time — decide push (payee must approve) vs pull
    /// pattern; see CONCEPT.md §3.
    function refundInvoice(uint256 invoiceId) external {
        invoiceId;
        revert NotImplemented();
    }

    /// @notice Read a full invoice.
    function getInvoice(uint256 invoiceId) external view returns (Invoice memory) {
        return invoices[invoiceId];
    }
}
