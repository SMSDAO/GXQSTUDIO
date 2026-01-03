import { Contract, JsonRpcProvider, ethers } from "ethers";

const ROUTER_ABI = ["function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory)"];

export async function quoteExactOut(
  provider: JsonRpcProvider,
  router: string,
  amountIn: bigint,
  path: string[]
): Promise<bigint | null> {
  try {
    const c = new Contract(router, ROUTER_ABI, provider);
    const out = await c.getAmountsOut(amountIn, path);
    return out[out.length - 1] as bigint;
  } catch (err) {
    console.error("quote failed", err);
    return null;
  }
}

export async function dexToDexProfit(
  provider: JsonRpcProvider,
  routerBuy: string,
  routerSell: string,
  amountIn: bigint,
  pathBuy: string[],
  pathSell: string[]
): Promise<bigint> {
  const buyOut = await quoteExactOut(provider, routerBuy, amountIn, pathBuy);
  if (!buyOut) return 0n;
  const sellOut = await quoteExactOut(provider, routerSell, buyOut, pathSell);
  if (!sellOut) return 0n;
  return sellOut - amountIn;
}