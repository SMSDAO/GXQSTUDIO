import { BrowserProvider, Contract, JsonRpcSigner, ethers } from "ethers";
import { NETWORKS, EvmNetworkId } from "../../../config/networks";

const ABI = [
  "function setAdminFeeBps(uint16 newBps)",
  "function setPaused(bool _paused)",
  "function paused() view returns (bool)",
  "function adminFeeBps() view returns (uint16)",
];

export async function getSigner(): Promise<JsonRpcSigner> {
  if (!window.ethereum) throw new Error("No injected provider");
  const provider = new BrowserProvider(window.ethereum as any);
  await provider.send("eth_requestAccounts", []);
  return await provider.getSigner();
}

export function getExecutorContract(network: EvmNetworkId, signer: JsonRpcSigner) {
  const addr = NETWORKS[network].defaultContracts.arbExecutor;
  if (!addr) throw new Error("arbExecutor not set for network");
  return new Contract(addr, ABI, signer);
}

export async function setAdminFee(network: EvmNetworkId, bps: number) {
  const signer = await getSigner();
  const c = getExecutorContract(network, signer);
  const tx = await c.setAdminFeeBps(bps);
  return tx.wait();
}

export async function setPaused(network: EvmNetworkId, paused: boolean) {
  const signer = await getSigner();
  const c = getExecutorContract(network, signer);
  const tx = await c.setPaused(paused);
  return tx.wait();
}

export async function fetchFeeState(network: EvmNetworkId) {
  const signer = await getSigner();
  const c = getExecutorContract(network, signer);
  const [fee, paused] = await Promise.all([c.adminFeeBps(), c.paused()]);
  return { fee: Number(fee), paused };
}