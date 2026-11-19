// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {InvoiceRegistry} from "./InvoiceRegistry.sol";

/// @title AgentVault
/// @notice Scoped spending vaults for AI agents on QDay Aevum Testnet.
/// @dev An owner deposits tUSD8 and grants an agent a *session*: a bounded, revocable
/// permission to spend, with a total cap, a per-payment cap, an expiry timestamp, and a
/// payee allowlist. The agent pays merchant invoices through the vault; every payment
/// emits a verifiable receipt event, giving the owner a complete on-chain audit trail.
///
/// SKELETON — full implementation lands in the 9–11 Dec 2026 build window.
/// See ../CONCEPT.md (repo root of the prep workspace) for the full specification.
contract AgentVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The stablecoin this vault holds (tUSD8 on Aevum Testnet, 6 decimals).
    IERC20 public immutable TOKEN;

    /// @notice The invoice registry whose invoices this vault can settle.
    InvoiceRegistry public immutable REGISTRY;

    /// @notice A bounded spending permission granted by an owner to one agent.
    struct Session {
        address owner; // owner who granted (and may revoke) the session
        address agent; // the only address allowed to spend under this session
        uint256 totalCap; // maximum cumulative spend, ever
        uint256 perPaymentCap; // maximum single payment
        uint256 spent; // cumulative spend so far
        uint48 expiry; // session dies automatically at this timestamp
        bool revoked; // owner killed the session early
    }

    /// @notice owner => deposited tUSD8 balance available to their sessions.
    mapping(address owner => uint256 balance) public balances;

    /// @notice sessionId => Session. sessionId = keccak256(owner, agent, nonce).
    mapping(bytes32 sessionId => Session) public sessions;

    /// @notice sessionId => payee => allowlisted.
    mapping(bytes32 sessionId => mapping(address payee => bool)) public allowlisted;

    /// @notice Per-owner nonce for session id derivation.
    mapping(address owner => uint256 nonce) public nonces;

    event Deposited(address indexed owner, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event SessionGranted(
        bytes32 indexed sessionId,
        address indexed owner,
        address indexed agent,
        uint256 totalCap,
        uint256 perPaymentCap,
        uint48 expiry
    );
    event SessionRevoked(bytes32 indexed sessionId, address indexed owner);
    event PaymentSettled(
        bytes32 indexed sessionId,
        uint256 indexed invoiceId,
        address indexed payee,
        uint256 amount
    );

    error NotImplemented();
    error ZeroAmount();
    error ZeroAddress();
    error InsufficientBalance();
    error SessionNotFound();
    error NotSessionAgent();
    error NotSessionOwner();
    error SessionRevoked();
    error SessionExpired();
    error PayeeNotAllowlisted();
    error ExceedsPerPaymentCap();
    error ExceedsTotalCap();
    error InvoiceNotPayable();

    constructor(IERC20 token_, InvoiceRegistry registry_) {
        if (address(token_) == address(0) || address(registry_) == address(0)) revert ZeroAddress();
        TOKEN = token_;
        REGISTRY = registry_;
    }

    /// @notice Deposit tUSD8 into the caller's vault balance.
    /// @dev Caller must approve the vault first. TODO: implement (transferFrom + effects).
    function deposit(uint256 amount) external nonReentrant {
        amount; // silence unused warning until implemented
        revert NotImplemented();
    }

    /// @notice Withdraw unspent tUSD8 from the caller's vault balance.
    /// @dev TODO: implement (checks-effects-interactions, safeTransfer).
    function withdraw(uint256 amount) external nonReentrant {
        amount;
        revert NotImplemented();
    }

    /// @notice Grant an agent a bounded spending session.
    /// @param agent The agent address allowed to spend.
    /// @param totalCap Maximum cumulative spend under this session.
    /// @param perPaymentCap Maximum single payment under this session.
    /// @param expiry Unix timestamp after which the session is dead.
    /// @param payees Payee allowlist (e.g. merchant / invoice contract addresses).
    /// @return sessionId keccak256(owner, agent, nonce).
    /// @dev TODO: implement (validate inputs, store session + allowlist, emit event).
    function grantSession(
        address agent,
        uint256 totalCap,
        uint256 perPaymentCap,
        uint48 expiry,
        address[] calldata payees
    ) external returns (bytes32 sessionId) {
        agent;
        totalCap;
        perPaymentCap;
        expiry;
        payees;
        revert NotImplemented();
    }

    /// @notice Revoke a session instantly. Only the granting owner.
    /// @dev TODO: implement (ownership check, set revoked, emit event).
    function revokeSession(bytes32 sessionId) external {
        sessionId;
        revert NotImplemented();
    }

    /// @notice Pay an invoice through a session. Only the session's agent may call.
    /// @dev Validation order (see CONCEPT.md §3): session exists, not revoked, not
    /// expired; caller is the agent; invoice UNPAID and not past due; payee allowlisted;
    /// amount <= per-payment cap; spent + amount <= total cap. Then mark PAID, update
    /// spent + owner balance, transfer tUSD8 to the payee, emit PaymentSettled.
    /// TODO: implement.
    function payInvoice(bytes32 sessionId, uint256 invoiceId) external nonReentrant {
        sessionId;
        invoiceId;
        revert NotImplemented();
    }

    // ---- Views ----

    /// @notice Read a full session.
    function getSession(bytes32 sessionId) external view returns (Session memory) {
        return sessions[sessionId];
    }

    /// @notice Cumulative spend under a session.
    function spentOf(bytes32 sessionId) external view returns (uint256) {
        return sessions[sessionId].spent;
    }

    /// @notice Whether a session can currently spend (exists, not revoked, not expired).
    function isSessionActive(bytes32 sessionId) external view returns (bool) {
        Session storage s = sessions[sessionId];
        return s.agent != address(0) && !s.revoked && block.timestamp <= s.expiry;
    }
}
