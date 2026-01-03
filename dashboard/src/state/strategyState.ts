import { ArbitrageStrategyId } from "../../../config/strategies";
import { EvmNetworkId } from "../../../config/networks";

class StrategyStateStore {
  private state: Record<EvmNetworkId, Record<ArbitrageStrategyId, boolean>> = {
    ethereum: { dexToDex: true, triangular: false },
    polygon: { dexToDex: true, triangular: false },
    base: { dexToDex: true, triangular: false },
  };

  isEnabled(net: EvmNetworkId, id: ArbitrageStrategyId) {
    return this.state[net]?.[id] ?? false;
  }

  toggle(net: EvmNetworkId, id: ArbitrageStrategyId) {
    const current = this.isEnabled(net, id);
    this.state[net][id] = !current;
  }
}

export const strategyStateStore = new StrategyStateStore();