import {
  createBot,
  createProvider,
  createFlow,
  addKeyword,
  EVENTS,
} from "@builderbot/bot";
import { MemoryDB as Database } from "@builderbot/bot";
import { BaileysProvider as Provider } from "@builderbot/provider-baileys";

const PORT = process.env.PORT ?? 3008;

const welcomeFlow = addKeyword<Provider, Database>(EVENTS.WELCOME).addAnswer(
  `🙌 Hola este es un chatbot solo para verificar cuentas no hay mas interación`
);

const main = async () => {
  const adapterFlow = createFlow([welcomeFlow]);

  const adapterProvider = createProvider(Provider, {
    version: [2, 3000, 1030817285] as any,
  });
  const adapterDB = new Database();

  const { handleCtx, httpServer } = await createBot({
    flow: adapterFlow,
    provider: adapterProvider,
    database: adapterDB,
  });

  adapterProvider.server.post(
    "/v1/messages",
    handleCtx(async (bot, req, res) => {
      const { number, message, urlMedia } = req.body;
      await bot.sendMessage(number, message, { media: urlMedia ?? null });
      return res.end("sended");
    })
  );

  httpServer(+PORT);
};

main();
