import createLomModule from "../build/lom.js";
import { Elm } from "./Main.elm";

let app = Elm.Main.init();

const lomModule = await createLomModule({
    print: app.ports.lomStdOut.send,
    printErr: app.ports.lomStdErr.send,
});

// mount lua part of the parser at "parser/init.lua"
lomModule.FS.mkdir("parser");
const response = await fetch("/init.lua");
if (response.body != null) {
    lomModule.FS.writeFile("parser/init.lua", await response.text());
}

const lom_init = lomModule.cwrap("lom_init", null, []);
const lom_run = lomModule.cwrap("lom_run", "string", ["string", "string"]);
const lom_close = lomModule.cwrap("lom_close", null, []);

lom_init();
app.ports.runLuaCode.subscribe(function (model: { code: string, input: string }) {
    lom_run(model.code, model.input);
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

window.addEventListener("beforeunload", lom_close);
