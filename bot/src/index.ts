import "dotenv/config";
import { STRATEGIES } from "../../config/strategies";
import { startScanner } from "./scanner";
import { startHttpServer } from "./server";

const ENABLE = {
  ethereum: process.env.ENABLE_ETHEREUM === "true",
  polygon: process.env.ENABLE_POLYGON === "true",
  base: process.env.ENABLE_BASE === "true",
};

function bootstrap() {
  for (const s of STRATEGIES) {
    for (const net of s.supportedNetworks) {
      if (ENABLE[net]) {
        startScanner(net, s.id);
      }
    }
  }
  startHttpServer(Number(process.env.BOT_PORT || 4000));
}

bootstrap();