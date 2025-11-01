import "./style.css";
import createLomModule from "../build/lom.js";

const lomModule = await createLomModule();

const lom_init = lomModule.cwrap("lom_init", null, []);
const lom_run = lomModule.cwrap("lom_run", "string", ["string"]);
const lom_close = lomModule.cwrap("lom_close", null, []);

lom_init();

document.getElementById("run").onclick = () => {
  const code = document.getElementById("code").value;
  const out = lom_run(code);
  document.getElementById("output").textContent = out ?? "(no output)";
};

window.addEventListener("beforeunload", lom_close);
