import { STRATEGIES } from "../../../config/strategies";
import { EvmNetworkId } from "../../../config/networks";

const BOT_URL = process.env.NEXT_PUBLIC_BOT_URL || "http://localhost:4000";

export interface ScannerStatus {
  network: EvmNetworkId;
  strategyId: string;
  scanning: boolean;
  lastCheck?: number;
  lastTx?: string;
  lastProfit?: string;
}

export interface BotLog {
  ts: number;
  network: EvmNetworkId;
  strategyId: string;
  message: string;
  txHash?: string;
  profit?: string;
}

export async function fetchStatus(): Promise<ScannerStatus[]> {
  const res = await fetch(`${BOT_URL}/status`);
  if (!res.ok) throw new Error("Status fetch failed");
  return res.json();
}

export async function fetchLogs(): Promise<BotLog[]> {
  const res = await fetch(`${BOT_URL}/logs`);
  if (!res.ok) throw new Error("Logs fetch failed");
  return res.json();
}

export async function startScan(network: EvmNetworkId, strategyId: string) {
  await fetch(`${BOT_URL}/start`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ network, strategyId }),
  });
}

export async function stopScan(network: EvmNetworkId, strategyId: string) {
  await fetch(`${BOT_URL}/stop`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ network, strategyId }),
  });
}

export const strategiesById = STRATEGIES.reduce<Record<string, string>>((acc, s) => {
  acc[s.id] = s.label;
  return acc;
}, {});