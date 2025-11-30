# Hermes Playground

An online playground for testing parser combinators written using
[hermes](https://github.com/omer-biz/hermes).

## Introduction

This playground compiles the Hermes project — along with Lua 5.4 — into
WebAssembly and interacts with it directly in the browser.  If your parsers work
here, they will work elsewhere too.

## How It Works

The interface consists of three panes:

1. **Right Pane** — Write your parser code in Lua here.
2. **Top Left Pane** — Enter the input string to be parsed. It is exposed to the
   Lua environment as `_INPUT`.
3. **Bottom Left Pane** — Displays the parser’s output, including anything
   printed via `print()` and any error messages.

## Setup & Installation

### Prerequisites

- `npm`
- `emscripten`
- `cmake`
- `make`

### Steps

First clone the repo.

``` shell
git clone https://github.com/omer-biz/hermes-playground.git
cd hermes-playground
```

Initialize submodules:

``` shell
git submodule update --init
```

Install JavaScript dependencies:

``` shell
npm install
```

Build the WASM module:

``` shell
make
```

Start the development server:

``` shell
npx vite
```
The app should now be accessible at (https://localhost:5173)[localhost:5173]
