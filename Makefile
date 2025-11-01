LUA_DIR = vendor/lua
LOM_DIR = vendor/lom
BUILD_DIR = build/
OUT_JS = $(BUILD_DIR)/lom.js
OUT_WASM = $(BUILD_DIR)/lom.wasm

LUA_SRCS = $(filter-out $(LUA_DIR)/onelua.c, $(wildcard $(LUA_DIR)/*.c))
LOM_SRCS = $(wildcard $(LOM_DIR)/src/*.c)

CFLAGS = -O3 -I$(LUA_DIR) -I$(LOM_DIR)/include
EMFLAGS = -s WASM=1 \
          -s MODULARIZE=1 \
          -s EXPORT_ES6=1 \
          -s EXPORTED_FUNCTIONS='["_lom_init","_lom_run","_lom_close"]' \
          -s EXPORTED_RUNTIME_METHODS='["cwrap"]'

all: $(OUT_JS)

$(OUT_JS): $(LUA_SRCS) $(LOM_SRCS)
	@mkdir -p "${BUILD_DIR}"
	emcc $(CFLAGS) $(LUA_SRCS) $(LOM_SRCS) $(EMFLAGS) -o $(OUT_JS)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
