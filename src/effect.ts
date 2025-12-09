
type Effect = {
  kind: string,
  content: string,
  path: string,
  message: string,
  mode: string,
  url: string,
}

export function readEffect(w_module, ptr) {
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

export function handleEffect(effect: Effect) {
  switch (effect.kind) {
    case "network":
      const _response = fetch(effect.url, {
        method: effect.mode,
        body: effect.content,
      })
      break;
    case "file":
      const blob = new Blob([effect.content], { type: 'text/plain' });
      const url = URL.createObjectURL(blob);

      const a = document.createElement('a');
      a.href = url
      a.download = effect.path;

      document.body.appendChild(a);
      a.click();

      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      break;
    case "error":
      console.error("error:", effect.message);
      break;
    default:
      console.log("unknow effect occured");
  }
}
