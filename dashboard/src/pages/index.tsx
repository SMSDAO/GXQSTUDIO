import { useEffect, useMemo, useState } from "react";
import { NETWORKS, EvmNetworkId } from "../../../config/networks";
import { STRATEGIES } from "../../../config/strategies";
import { useAuth } from "../contexts/AuthContext";
import { strategyStateStore } from "../state/strategyState";
import { JsonRpcProvider, formatEther } from "ethers";
import {
  BotLog,
  ScannerStatus,
  fetchLogs,
  fetchStatus,
  startScan,
  stopScan,
  strategiesById,
} from "../lib/botClient";
import { fetchFeeState, setAdminFee, setPaused } from "../lib/contractClient";

export default function Home() {
  const { role, toggleRole } = useAuth();
  const [providersUp, setProvidersUp] = useState<Record<string, boolean>>({});
  const [statuses, setStatuses] = useState<ScannerStatus[]>([]);
  const [logs, setLogs] = useState<BotLog[]>([]);
  const [adminFee, setAdminFeeState] = useState<number>(0);
  const [paused, setPausedState] = useState<boolean>(false);
  const [adminNet, setAdminNet] = useState<EvmNetworkId>("ethereum");

  useEffect(() => {
    (async () => {
      const statuses: Record<string, boolean> = {};
      for (const [id, net] of Object.entries(NETWORKS)) {
        const rpc = net.rpcs[0];
        if (!rpc) {
          statuses[id] = false;
          continue;
        }
        try {
          const p = new JsonRpcProvider(rpc, net.chainId);
          await p.getBlockNumber();
          statuses[id] = true;
        } catch {
          statuses[id] = false;
        }
      }
      setProvidersUp(statuses);
    })();
  }, []);

  useEffect(() => {
    const load = async () => {
      try {
        setStatuses(await fetchStatus());
        setLogs(await fetchLogs());
      } catch {
        /* ignore */
      }
    };
    load();
    const id = setInterval(load, 5000);
    return () => clearInterval(id);
  }, []);

  const strategies = useMemo(() => STRATEGIES, []);

  const handleStartStop = async (net: EvmNetworkId, id: string, enable: boolean) => {
    if (enable) await startScan(net, id);
    else await stopScan(net, id);
    setStatuses(await fetchStatus());
  };

  const loadAdminState = async (net: EvmNetworkId) => {
    try {
      const state = await fetchFeeState(net);
      setAdminFeeState(state.fee);
      setPausedState(state.paused);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    loadAdminState(adminNet);
  }, [adminNet]);

  return (
    <div className="app">
      <header className="header">
        <h1>GXQSTUDIO Arbitrage Dashboard</h1>
        <button onClick={toggleRole}>Mode: {role}</button>
      </header>

      <section>
        <h2>Networks</h2>
        <ul>
          {Object.entries(NETWORKS).map(([id, net]) => (
            <li key={id}>
              <strong>{net.name}</strong> — RPC {providersUp[id] ? "✅" : "❌"} — ChainId {net.chainId}
            </li>
          ))}
        </ul>
      </section>

      <section>
        <h2>Strategies</h2>
        <ul>
          {strategies.map((s) => (
            <li key={s.id}>
              <div className="card">
                <div>
                  <strong>{s.label}</strong> ({s.id}) — {s.description}
                </div>
                <div>Networks: {s.supportedNetworks.join(", ")}</div>
                <div className="row">
                  {s.supportedNetworks.map((net) => {
                    const enabled = strategyStateStore.isEnabled(net, s.id);
                    const scanning = statuses.some(
                      (st) => st.network === net && st.strategyId === s.id && st.scanning
                    );
                    return (
                      <div key={net} className="pill">
                        <div>{net}</div>
                        <div>Status: {scanning ? "Scanning" : enabled ? "Idle" : "Disabled"}</div>
                        <button
                          onClick={() => {
                            strategyStateStore.toggle(net, s.id);
                            handleStartStop(net, s.id, !enabled);
                          }}
                          className={enabled ? "btn on" : "btn off"}
                        >
                          {enabled ? "Stop" : "Start"}
                        </button>
                      </div>
                    );
                  })}
                </div>
              </div>
            </li>
          ))}
        </ul>
      </section>

      <section>
        <h2>Recent Logs</h2>
        <div className="card">
          {logs.slice(-10).reverse().map((l, i) => (
            <div key={i} className="log">
              <strong>{new Date(l.ts).toLocaleTimeString()}</strong> [{l.network}/{l.strategyId}] {l.message}
              {l.txHash && (
                <a href="#" style={{ marginLeft: 8 }}>
                  {l.txHash.slice(0, 10)}...
                </a>
              )}
              {l.profit && <span style={{ marginLeft: 8 }}>profit: {formatEther(l.profit)} ETH</span>}
            </div>
          ))}
        </div>
      </section>

      {role === "ADMIN" && (
        <section>
          <h2>Admin Panel</h2>
          <div className="card">
            <label>
              Network:
              <select value={adminNet} onChange={(e) => setAdminNet(e.target.value as EvmNetworkId)}>
                {Object.keys(NETWORKS).map((n) => (
                  <option key={n} value={n}>
                    {n}
                  </option>
                ))}
              </select>
            </label>
            <div>Current adminFeeBps: {adminFee}</div>
            <div>Paused: {paused ? "Yes" : "No"}</div>
            <div className="row">
              <input
                type="number"
                value={adminFee}
                onChange={(e) => setAdminFeeState(Number(e.target.value))}
                min={0}
                max={2000}
              />
              <button
                className="btn on"
                onClick={async () => {
                  await setAdminFee(adminNet, adminFee);
                  await loadAdminState(adminNet);
                }}
              >
                Set adminFeeBps
              </button>
            </div>
            <div className="row">
              <button
                className="btn off"
                onClick={async () => {
                  await setPaused(adminNet, !paused);
                  await loadAdminState(adminNet);
                }}
              >
                Toggle Pause
              </button>
            </div>
          </div>
        </section>
      )}
    </div>
  );
}