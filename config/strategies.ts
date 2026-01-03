import { EvmNetworkId } from "./networks";

export type ArbitrageStrategyId = "dexToDex" | "triangular";

export interface ArbitrageStrategyConfig {
  id: ArbitrageStrategyId;
  label: string;
  description: string;
  enabledByDefault: boolean;
  supportedNetworks: EvmNetworkId[];
  executorAddressByNetwork: Partial<Record<EvmNetworkId, string>>;
}

export const STRATEGIES: ArbitrageStrategyConfig[] = [
  {
    id: "dexToDex",
    label: "DEX → DEX",
    description: "Two-leg arbitrage between router1 and router2.",
    enabledByDefault: true,
    supportedNetworks: ["ethereum", "polygon", "base"],
    executorAddressByNetwork: { ethereum: "", polygon: "", base: "" },
  },
  {
    id: "triangular",
    label: "Triangular",
    description: "Three-pool triangular arbitrage within one chain.",
    enabledByDefault: false,
    supportedNetworks: ["ethereum", "polygon", "base"],
    executorAddressByNetwork: { ethereum: "", polygon: "", base: "" },
  },
];