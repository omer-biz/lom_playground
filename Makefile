BUILD_DIR = build

all: $(BUILD_DIR)/lom.js $(BUILD_DIR)/lom.wasm

$(BUILD_DIR)/lom.js $(BUILD_DIR)/lom.wasm:
	emcmake cmake -S . -B $(BUILD_DIR)
	cmake --build $(BUILD_DIR)
	cp ./vendor/lom/lua/init.lua ./public/

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean

