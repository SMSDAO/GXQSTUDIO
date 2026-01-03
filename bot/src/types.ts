import { EvmNetworkId } from "../../config/networks";

export interface ScannerState {
  scanning: boolean;
  lastCheck?: number;
  lastTx?: string;
  lastProfit?: string;
}

export interface LogEntry {
  ts: number;
  network: EvmNetworkId;
  strategyId: string;
  message: string;
  txHash?: string;
  profit?: string;
}