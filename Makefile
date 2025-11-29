BUILD_DIR = build

all: $(BUILD_DIR)/hermes.js $(BUILD_DIR)/hermes.wasm luasrc

$(BUILD_DIR)/hermes.js $(BUILD_DIR)/hermes.wasm:
	emcmake cmake -S . -B $(BUILD_DIR)
	cmake --build $(BUILD_DIR)

luasrc:
	cp -r ./vendor/hermes-parser/lua/* ./public/

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean

