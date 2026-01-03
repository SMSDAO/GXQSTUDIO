export type EvmNetworkId = "ethereum" | "polygon" | "base";

export interface EvmNetworkConfig {
  chainId: number;
  name: string;
  explorerUrl: string;
  rpcs: string[];
  defaultContracts: {
    flashLoanProvider?: string;
    router1?: string;
    router2?: string;
    arbExecutor?: string;
  };
}

const alch = process.env.ALCHEMY_KEY || "";
const infura = process.env.INFURA_KEY || "";

export const NETWORKS: Record<EvmNetworkId, EvmNetworkConfig> = {
  ethereum: {
    chainId: 1,
    name: "Ethereum",
    explorerUrl: "https://etherscan.io",
    rpcs: [
      process.env.ETHEREUM_RPC || (alch && `https://eth-mainnet.g.alchemy.com/v2/${alch}`) || "",
      (infura && `https://mainnet.infura.io/v3/${infura}`) || "",
      "https://rpc.ankr.com/eth",
      "https://cloudflare-eth.com",
    ].filter(Boolean),
    defaultContracts: {
      flashLoanProvider: "",
      router1: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
      router2: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
      arbExecutor: "",
    },
  },
  polygon: {
    chainId: 137,
    name: "Polygon",
    explorerUrl: "https://polygonscan.com",
    rpcs: [
      process.env.POLYGON_RPC || (alch && `https://polygon-mainnet.g.alchemy.com/v2/${alch}`) || "",
      "https://polygon-rpc.com",
      "https://rpc-mainnet.matic.quiknode.pro",
      "https://polygon-bor.publicnode.com",
    ].filter(Boolean),
    defaultContracts: {
      flashLoanProvider: "",
      router1: "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff",
      router2: "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
      arbExecutor: "",
    },
  },
  base: {
    chainId: 8453,
    name: "Base",
    explorerUrl: "https://basescan.org",
    rpcs: [
      process.env.BASE_RPC || (alch && `https://base-mainnet.g.alchemy.com/v2/${alch}`) || "",
      "https://mainnet.base.org",
      "https://base.publicnode.com",
    ].filter(Boolean),
    defaultContracts: {
      flashLoanProvider: "",
      router1: "0x327Df1E6de05895d2ab08513aaDD9313Fe505d86",
      router2: "0x4758A1Ff90F79c1b9e46a02c6cde9c8F60F427a9",
      arbExecutor: "",
    },
  },
};