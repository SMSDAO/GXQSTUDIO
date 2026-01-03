import { Wallet, ethers } from "ethers";
import { NETWORKS, EvmNetworkId } from "../../config/networks";
import { STRATEGIES } from "../../config/strategies";
import { getRotatingProvider } from "./providerFactory";
import { dexToDexProfit } from "./pricing";
import { LogEntry, ScannerState } from "./types";

const state: Record<EvmNetworkId, Record<string, ScannerState>> = {
  ethereum: {},
  polygon: {},
  base: {},
};

const logs: LogEntry[] = [];

const MIN_EXPECTED_PROFIT = ethers.parseEther(process.env.MIN_EXPECTED_PROFIT || "0.001");
const MAX_CAPITAL = ethers.parseEther(process.env.MAX_CAPITAL_PER_TRADE || "1");
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

function pushLog(entry: LogEntry) {
  logs.push(entry);
  if (logs.length > 200) logs.shift();
}

async function executeFlashArb(
  network: EvmNetworkId,
  strategyId: string,
  wallet: Wallet,
  profit: bigint
) {
  const netCfg = NETWORKS[network];
  const strategy = STRATEGIES.find((s) => s.id === strategyId);
  if (!strategy) return;
  const executor = strategy.executorAddressByNetwork[network];
  if (!executor) return;

  const iface = new ethers.Interface([
    "function executeFlashArb(address flashLoanProvider,address asset,uint256 amount,bytes32 strategyId,address routerBuy,address routerSell,address[] pathBuy,address[] pathSell,uint256 minProfit)",
  ]);

  const data = iface.encodeFunctionData("executeFlashArb", [
    netCfg.defaultContracts.flashLoanProvider,
    ethers.ZeroAddress, // replace with asset address per strategy
    MAX_CAPITAL,
    ethers.id(strategyId),
    netCfg.defaultContracts.router1,
    netCfg.defaultContracts.router2,
    [ethers.ZeroAddress, ethers.ZeroAddress],
    [ethers.ZeroAddress, ethers.ZeroAddress],
    MIN_EXPECTED_PROFIT,
  ]);

  const tx = await wallet.sendTransaction({ to: executor, data, gasLimit: 1_200_000n });
  pushLog({
    ts: Date.now(),
    network,
    strategyId,
    message: `Submitted tx ${tx.hash}`,
    txHash: tx.hash,
    profit: profit.toString(),
  });
  await tx.wait();
}

export function getLogs() {
  return logs;
}

export function getStatus(): { network: EvmNetworkId; strategyId: string; scanning: boolean; lastCheck?: number; lastTx?: string; lastProfit?: string }[] {
  const arr: any[] = [];
  for (const net of Object.keys(state) as EvmNetworkId[]) {
    for (const s of Object.keys(state[net])) {
      const st = state[net][s];
      arr.push({ network: net, strategyId: s, ...st });
    }
  }
  return arr;
}

export function startScanner(network: EvmNetworkId, strategyId: string) {
  state[network][strategyId] = state[network][strategyId] || { scanning: false };
  if (state[network][strategyId].scanning) return;
  state[network][strategyId].scanning = true;
  loop(network, strategyId);
}

export function stopScanner(network: EvmNetworkId, strategyId: string) {
  if (state[network][strategyId]) state[network][strategyId].scanning = false;
}

async function loop(network: EvmNetworkId, strategyId: string) {
  const provider = getRotatingProvider(network);
  const wallet = PRIVATE_KEY ? new Wallet(PRIVATE_KEY, provider) : null;

  while (state[network][strategyId]?.scanning) {
    state[network][strategyId].lastCheck = Date.now();
    try {
      const netCfg = NETWORKS[network];
      const profit = await dexToDexProfit(
        provider,
        netCfg.defaultContracts.router1!,
        netCfg.defaultContracts.router2!,
        MAX_CAPITAL,
        [ethers.ZeroAddress, ethers.ZeroAddress],
        [ethers.ZeroAddress, ethers.ZeroAddress]
      );

      if (profit > MIN_EXPECTED_PROFIT) {
        state[network][strategyId].lastProfit = profit.toString();
        if (wallet) {
          await executeFlashArb(network, strategyId, wallet, profit);
          state[network][strategyId].lastTx = "sent";
        } else {
          pushLog({ ts: Date.now(), network, strategyId, message: `Simulated profit ${profit.toString()}` });
        }
      }
    } catch (err: any) {
      pushLog({ ts: Date.now(), network, strategyId, message: `Error: ${err.message}` });
    }
    await new Promise((res) => setTimeout(res, Number(process.env.SCAN_INTERVAL_MS || "15000")));
  }
}