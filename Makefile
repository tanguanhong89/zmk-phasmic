LOCAL_BUILD_DIR ?= $(CURDIR)/.local-build
LOCAL_PYTHON ?= /usr/bin/python3
GNUARMEMB_TOOLCHAIN_PATH ?= /Applications/ArmGNUToolchain/13.3.rel1/arm-none-eabi

.PHONY: build build_local

build:
	git add boards/* .github/workflows/build.yml build.yaml config/west.yml Makefile
	git commit -m "update boards"
	git push

build_local:
	@set -eu; \
	mkdir -p "$(LOCAL_BUILD_DIR)/config"; \
	cp -R "$(CURDIR)/config/." "$(LOCAL_BUILD_DIR)/config/"; \
	cd "$(LOCAL_BUILD_DIR)"; \
	if [ ! -x env/bin/west ]; then \
	    "$(LOCAL_PYTHON)" -m venv env; \
	    env/bin/python -m pip install west 'cmake<4' ninja; \
	fi; \
	export PATH="$$PWD/env/bin:$$PATH"; \
	if [ ! -d .west ]; then west init -l config; fi; \
	west update --fetch-opt=--filter=tree:0; \
	python -m pip install -q -r zephyr/scripts/requirements-base.txt; \
	ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb \
	GNUARMEMB_TOOLCHAIN_PATH="$(GNUARMEMB_TOOLCHAIN_PATH)" \
	    west build -p always -s zmk/app -d left -b nice_nano_v2 -- \
	        -DSHIELD=phasmic_left -DZMK_CONFIG="$$PWD/config" \
	        -DZMK_EXTRA_MODULES="$(CURDIR)" \
	        -DZephyr_DIR="$$PWD/zephyr/share/zephyr-package/cmake" \
	        -DUSER_CACHE_DIR="$$PWD/cache"; \
	mkdir -p "$(CURDIR)/firmwares/local"; \
	cp left/zephyr/zmk.uf2 "$(CURDIR)/firmwares/local/phasmic_left-nice_nano_v2-zmk.uf2"; \
	printf 'Firmware: %s\n' "$(CURDIR)/firmwares/local/phasmic_left-nice_nano_v2-zmk.uf2"
