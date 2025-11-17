import ace from "ace-builds/src-noconflict/ace";
import "ace-builds/src-noconflict/mode-lua";
import "ace-builds/src-noconflict/theme-monokai";

class LuaEditor extends HTMLElement {
    private _editor: ace.Ace.Editor | null = null;
    private _container: HTMLDivElement;

    constructor() {
        super();
        this._container = document.createElement("div");
        Object.assign(this._container.style, {
            width: "100%",
            height: "100%",
            position: "absolute",
            inset: "0",
        });
        this.appendChild(this._container);
    }

    static get observedAttributes() {
        return ["value"];
    }

    connectedCallback() {
        if (!this.style.position) this.style.position = "relative";
        if (!this.style.display) this.style.display = "block";

        this._editor = ace.edit(this._container, {
            mode: "ace/mode/lua",
            theme: "ace/theme/textmate",
            fontSize: 14,
            showPrintMargin: false,
            useSoftTabs: true,
            tabSize: 2,
            wrap: true,
        });

        const initVal = this.getAttribute("value") || "";
        console.log("init", initVal);

        this._editor.setValue(initVal, -1);

        this._editor.session.on("change", () => {
            this.value = this._editor.getValue();
            const event = new Event("editorChanged");
            this.dispatchEvent(event);
        });
    }

    disconnectedCallback() {
        this._editor?.destroy();
        this._editor = null
    }

    get value() {
        return this._editor ? this._editor.getValue() : "";
    }

    set value(v: string) {
        if (v === this._editor.getValue()) return;
        if (this._editor && this._editor.getValue() !== v) {
            this._editor.setValue(v, -1);
        }
    }
}

customElements.define("lua-editor", LuaEditor);

export default LuaEditor;
