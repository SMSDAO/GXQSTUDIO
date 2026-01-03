import express from "express";
import cors from "cors";
import { getLogs, getStatus, startScanner, stopScanner } from "./scanner";
import { EvmNetworkId } from "../../config/networks";

export function startHttpServer(port = 4000) {
  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get("/status", (_req, res) => res.json(getStatus()));
  app.get("/logs", (_req, res) => res.json(getLogs()));

  app.post("/start", (req, res) => {
    const { network, strategyId } = req.body;
    startScanner(network as EvmNetworkId, strategyId);
    res.json({ ok: true });
  });

  app.post("/stop", (req, res) => {
    const { network, strategyId } = req.body;
    stopScanner(network as EvmNetworkId, strategyId);
    res.json({ ok: true });
  });

  const server = app.listen(port, () => {
    console.log(`Bot HTTP API on :${port}`);
  });
  return server;
}