import createLomModule from "../build/lom.js";
import { Elm } from "./Main.elm";

const lomModule = await createLomModule();

const lom_init = lomModule.cwrap("lom_init", null, []);
const lom_run = lomModule.cwrap("lom_run", "string", ["string"]);
const lom_close = lomModule.cwrap("lom_close", null, []);

lom_init();

let app = Elm.Main.init();

app.ports.runLuaCode.subscribe(function (code) {
  lom_run(code);
});

window.addEventListener("beforeunload", lom_close);
