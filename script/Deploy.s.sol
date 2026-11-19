// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {AgentVault} from "../src/AgentVault.sol";
import {InvoiceRegistry} from "../src/InvoiceRegistry.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Deploy AgentVault + InvoiceRegistry to QDay Aevum Testnet (chain ID 44005).
/// @dev SKELETON — deploy flow is finalized in the 9–11 Dec build (deploy-order problem:
/// the vault needs the registry address and the registry needs the vault address; resolve
/// with a two-step deploy or a factory — see the TODO below).
///
/// Usage (testnet only, TESTNET-ONLY key):
///   cp .env.example .env   # set PRIVATE_KEY (testnet-only, never mainnet funds)
///   forge script script/Deploy.s.sol --rpc-url https://rpc-test.qday.info --broadcast
///
/// Verify on Blockscout:
///   forge verify-contract --chain-id 44005 --verifier blockscout \
///     --verifier-url https://explorer-test.qday.info/api <ADDRESS> src/AgentVault.sol:AgentVault
contract Deploy is Script {
    /// @notice tUSD8 on Aevum Testnet (QDay Wiki token list). Re-verify on-chain
    /// (name/symbol/decimals) before deploying — see RESEARCH.md §2.
    address internal constant TUSD8 = 0x456569838f1d43009A91ebA4263147Afd7233483;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // TODO(9–11 Dec): resolve the circular constructor dependency.
        // Option A: deploy registry with deployer as vault, deploy vault, then
        //   re-deploy registry with the real vault (cheap on testnet).
        // Option B: add a minimal factory that deploys both and wires them.
        // Option C: make InvoiceRegistry.VAULT settable once by the deployer.
        InvoiceRegistry registry = new InvoiceRegistry(msg.sender);
        AgentVault vault = new AgentVault(IERC20(TUSD8), registry);

        vm.stopBroadcast();

        console.log("InvoiceRegistry:", address(registry));
        console.log("AgentVault:     ", address(vault));
        console.log("tUSD8:          ", TUSD8);
    }
}
