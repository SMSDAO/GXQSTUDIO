import { JsonRpcProvider } from "ethers";
import { NETWORKS, EvmNetworkId } from "../../config/networks";

const cursors: Record<EvmNetworkId, number> = {
  ethereum: 0,
  polygon: 0,
  base: 0,
};

export function getRotatingProvider(network: EvmNetworkId): JsonRpcProvider {
  const cfg = NETWORKS[network];
  if (!cfg.rpcs.length) throw new Error(`No RPCs for ${network}`);
  for (let i = 0; i < cfg.rpcs.length; i++) {
    const idx = (cursors[network] + i) % cfg.rpcs.length;
    try {
      const provider = new JsonRpcProvider(cfg.rpcs[idx], cfg.chainId);
      cursors[network] = idx + 1;
      return provider;
    } catch {
      continue;
    }
  }
  throw new Error(`All RPCs failed for ${network}`);
}