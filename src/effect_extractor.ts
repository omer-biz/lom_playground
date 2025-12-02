export default function readEffect(w_module, ptr) {
    const kind = w_module.HEAP32[ptr >> 2];

    const base = ptr + 4;
    if (kind === 0) { // Effect Error
        return {
            kind: 'error',
            message: w_module.UTF8ToString(w_module.HEAP32[base >> 2])
        };
    }

    if (kind === 1) { // Effect File
        return {
            kind: "file",
            mode: w_module.UTF8ToString(w_module.HEAP32[(base + 0) >> 2]),
            path: w_module.UTF8ToString(w_module.HEAP32[(base + 4) >> 2]),
            content: w_module.UTF8ToString(w_module.HEAP32[(base + 8) >> 2]),
        };
    }

    if (kind === 2) { // Effect Network
        return {
            kind: "network",
            mode: w_module.UTF8ToString(w_module.HEAP32[(base + 0) >> 2]),
            url: w_module.UTF8ToString(w_module.HEAP32[(base + 4) >> 2]),
            content: w_module.UTF8ToString(w_module.HEAP32[(base + 8) >> 2]),
            timeout: w_module.HEAP32[(base + 12) >> 2],
        };
    }

    return null;
}
