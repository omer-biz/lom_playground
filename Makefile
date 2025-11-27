BUILD_DIR = build

all: $(BUILD_DIR)/hermes.js $(BUILD_DIR)/hermes.wasm

$(BUILD_DIR)/hermes.js $(BUILD_DIR)/hermes.wasm:
	emcmake cmake -S . -B $(BUILD_DIR)
	cmake --build $(BUILD_DIR)
	cp ./vendor/hermes-parser/lua/init.lua ./public/

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean

