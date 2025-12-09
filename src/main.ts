import createHermesModule from "../build/hermes.js";
import { Elm } from "./Main.elm";
import { readEffect, handleEffect } from "./effect.js";

let app = Elm.Main.init({
  flags: {
    parser_code: localStorage.getItem("parser_code"),
    _input: localStorage.getItem("_input")
  }
});

const hermesModule = await createHermesModule({
  print: app.ports.hermesStdOut.send,
  printErr: app.ports.hermesStdErr.send,
});


// mount lua part of the parser at "parser/init.lua"
hermesModule.FS.mkdir("parser");
const response_init_lua = await fetch("parser/init.lua");
if (response_init_lua.body != null) {
  hermesModule.FS.writeFile("parser/init.lua", await response_init_lua.text());
}

const response_effect_lua = await fetch("effect.lua");
if (response_effect_lua.body != null) {
  hermesModule.FS.writeFile("effect.lua", await response_effect_lua.text());
}

const hermes_init = hermesModule.cwrap("hermes_init", null, []);
const hermes_run = hermesModule.cwrap("hermes_run", "number", ["string", "string"]);
const hermes_close = hermesModule.cwrap("hermes_close", null, []);

hermes_init();
app.ports.runLuaCode.subscribe(function (model: { code: string, input: string }) {
  const effectPtr = hermes_run(model.code, model.input);
  const effect = readEffect(hermesModule, effectPtr);
  handleEffect(effect);
});

app.ports.localStorageSetItem.subscribe(function (pair: { name: string, value: string }) {
  localStorage.setItem(pair.name, pair.value);
});


const editorPane = document.getElementById("editorPane");
const rightPane = document.getElementById("rightPane");

const inputPane = document.getElementById("inputPane");

function calcNewHorSize(e: any) {
  const totalHeight = inputPane?.parentElement?.clientHeight ?? 0;

  const headerSize = editorPane?.parentElement?.getBoundingClientRect()?.top ?? 0;
  const newInputPaneHeight = (e.clientY - headerSize) / totalHeight;

  if (newInputPaneHeight != Infinity) {
    app.ports.draggedHorizontal.send(newInputPaneHeight);
  }
}

function calcNewVerSize(e: any) {
  const totalWidth = rightPane?.parentElement?.clientWidth;
  const newPaneSize = (e.clientX / (totalWidth ?? 0))

  if (newPaneSize != Infinity) {
    app.ports.draggedVertical.send(newPaneSize);
  }
}

app.ports.listenDrag.subscribe(function (orient: string) {
  if (orient == "horizontal") {
    window.addEventListener("mousemove", calcNewHorSize);
  }

  if (orient == "vertical") {
    window.addEventListener("mousemove", calcNewVerSize);
  }
});


app.ports.stopDrag.subscribe(function (orient: string) {
  if (orient == "horizontal") {
    window.removeEventListener("mousemove", calcNewHorSize);
  }

  if (orient == "vertical") {
    window.removeEventListener("mousemove", calcNewVerSize);
  }
});

window.addEventListener("beforeunload", hermes_close);
