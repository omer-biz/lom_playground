import createLomModule from "../build/lom.js";
import { Elm } from "./Main.elm";

let app = Elm.Main.init();

const lomModule = await createLomModule({
    print: app.ports.lomStdOut.send,
    printErr: app.ports.lomStdErr.send,
});

const lom_init = lomModule.cwrap("lom_init", null, []);
const lom_run = lomModule.cwrap("lom_run", "string", ["string"]);
const lom_close = lomModule.cwrap("lom_close", null, []);

lom_init();
app.ports.runLuaCode.subscribe(lom_run);
window.addEventListener("beforeunload", lom_close);
