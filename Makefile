# Your layout geometry. Can be one of:
# voyager | moonlander | ergodox_ez | ergodox_ez/stm32/glow | planck_ez | planck_ez/glow
LAYOUT_GEOMETRY ?= voyager
# Your layout ID. Can be found in the URL of your layout in Oryx:
# https://configure.zsa.io/voyager/layouts/oZRmD/latest
LAYOUT_ID ?= oZRmD

# -----------------------------------------------------------------------------

GRAPHQL_URL = https://oryx.zsa.io/graphql
SOURCE_URL = https://oryx.zsa.io/source

GRAPHQL_DIR = graphql
KMDRAWER_DIR = kmdrawer
QMK_DIR = qmk_firmware
SOURCE_DIR = src
BUILD_DIR = build

CONFIG_H = $(SOURCE_DIR)/config.h
KEYMAP_C = $(SOURCE_DIR)/keymap.c
RULES_MK = $(SOURCE_DIR)/rules.mk
SOURCE_FILES = $(CONFIG_H) $(KEYMAP_C) $(RULES_MK)

LAYOUT_QUERY_FILE = $(GRAPHQL_DIR)/layout.graphql
LAYOUT_QUERY_FORMAT = '{"query": $$query, "variables":{"hashId": $$hashId, "geometry": $$geometry, "revisionId": $$revisionId}}'
LAYOUT_QUERY_BODY = $(shell jq --null-input --compact-output --arg query '$(shell cat "$(LAYOUT_QUERY_FILE)")' --arg hashId '$(LAYOUT_ID)' --arg geometry '$(LAYOUT_GEOMETRY)' --arg revisionId 'latest' $(LAYOUT_QUERY_FORMAT))

KMDRAWER_CONFIG_FILE = $(KMDRAWER_DIR)/config.yml

METADATA_JSON = $(BUILD_DIR)/metadata.json
SOURCE_ZIP = $(BUILD_DIR)/source.zip
BUILT_KEYMAP_BIN = $(BUILD_DIR)/keymap.bin
BUILT_KEYMAP_JSON = $(BUILD_DIR)/keymap.json
BUILT_KEYMAP_YML = $(BUILD_DIR)/keymap.yml
BUILT_KEYMAP_SVG = $(BUILD_DIR)/keymap.svg

METADATA_FIRMWARE = $(shell [ -e '$(METADATA_JSON)' ] && jq -r '.[0]' '$(METADATA_JSON)' | xargs printf '%.0f' || echo '24')
METADATA_HASH = $(shell [ -e '$(METADATA_JSON)' ] && jq -r '.[1]' '$(METADATA_JSON)' || echo 'default')
METADATA_MESSAGE = $(shell [ -e '$(METADATA_JSON)' ] && jq -r '.[2]' '$(METADATA_JSON)' || echo 'latest changes via Oryx')

QMK_DOCKER_IMAGE = qmk
QMK_MAKE_PREFIX = $(shell [ '$(METADATA_FIRMWARE)' -ge 24 ] && echo 'zsa/' || echo '')
QMK_MAKE_KEYBOARD = $(QMK_MAKE_PREFIX)$(LAYOUT_GEOMETRY)
QMK_MAKE_TARGET = $(QMK_MAKE_KEYBOARD):$(LAYOUT_ID)
QMK_MAKE_TARGET_NORMALIZED = $(shell echo '$(QMK_MAKE_TARGET)' | sed 's/[^a-zA-Z0-9]/_/g')
QMK_KEYBOARDS_PATH = $(shell [ '$(METADATA_FIRMWARE)' -ge 24 ] && echo 'keyboards/zsa' || echo 'keyboards')
QMK_KEYBOARD_DIR = $(QMK_DIR)/$(QMK_KEYBOARDS_PATH)/$(LAYOUT_GEOMETRY)
QMK_KEYMAP_DIR = $(QMK_KEYBOARD_DIR)/keymaps/$(LAYOUT_ID)
QMK_KEYMAP_FILE = $(QMK_KEYMAP_DIR)/keymap.c

# -----------------------------------------------------------------------------

.PHONY: all
all: $(BUILT_KEYMAP_BIN) $(BUILT_KEYMAP_JSON) $(BUILT_KEYMAP_SVG)

.PHONY: clean
clean:
	rm -f '$(BUILD_DIR)'/*

.PHONY: unzip-source
unzip-source: $(METADATA_JSON) $(SOURCE_FILES)

# .PHONY: commit-changes
# commit-changes:
# 	git add .
# 	git commit -m '(oryx): $(METADATA_MESSAGE)'' || echo 'No layout change'
# 	git push

# .PHONY: merge-branches
# merge-branches:
# 	git fetch origin main
# 	git checkout -B main origin/main
# 	git merge -Xignore-all-space oryx
# 	git push

.PHONY: update-qmk-branch
update-qmk-branch: $(METADATA_JSON)
	cd '$(QMK_DIR)' && \
		git fetch origin 'firmware$(METADATA_FIRMWARE)' && \
		git checkout -B 'firmware$(METADATA_FIRMWARE)' 'origin/firmware$(METADATA_FIRMWARE)' && \
		git submodule update --init --recursive

.PHONY: build-qmk-docker-image
build-qmk-docker-image:
	docker build --quiet --tag '$(QMK_DOCKER_IMAGE)' .

$(METADATA_JSON):
	curl --location --no-progress-meter --json '$(LAYOUT_QUERY_BODY)' '$(GRAPHQL_URL)' | \
		jq '.data.layout.revision | [.qmkVersion, .hashId, .title]' > '$(METADATA_JSON)'

$(SOURCE_ZIP): $(METADATA_JSON)
	curl --location --no-progress-meter --output '$@' '$(SOURCE_URL)/$(METADATA_HASH)'

$(SOURCE_FILES): $(SOURCE_ZIP)
	unzip -j -o '$<' '*_source/$(@F)' -d '$(SOURCE_DIR)'

$(QMK_KEYMAP_FILE): $(METADATA_JSON)
	$(MAKE) update-qmk-branch build-qmk-docker-image
	rm -rf '$(QMK_KEYMAP_DIR)' && cp -r '$(SOURCE_DIR)' '$(QMK_KEYMAP_DIR)'

$(BUILT_KEYMAP_BIN): $(METADATA_JSON) $(QMK_KEYMAP_FILE)
	docker run --volume .:/root --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		cd '$(QMK_DIR)' && \
		qmk setup zsa/qmk_firmware -b firmware$(METADATA_FIRMWARE) -y && \
		make $(QMK_MAKE_TARGET) && \
		mv '$(QMK_MAKE_TARGET_NORMALIZED).bin' '../$(BUILT_KEYMAP_BIN)' \
	"

$(BUILT_KEYMAP_JSON): $(METADATA_JSON) $(QMK_KEYMAP_FILE)
	docker run --volume .:/root --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		cd '$(QMK_DIR)' && \
		qmk c2json --no-cpp -km '$(LAYOUT_ID)' -kb '$(QMK_MAKE_KEYBOARD)' -o '../$(BUILT_KEYMAP_JSON)' \
	"

$(BUILT_KEYMAP_YML): $(BUILT_KEYMAP_JSON)
	docker run --volume .:/root --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		keymap parse -q '$(BUILT_KEYMAP_JSON)' -o '$(BUILT_KEYMAP_YML)' \
	"

$(BUILT_KEYMAP_SVG): $(BUILT_KEYMAP_YML)
	docker run --volume .:/root --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		keymap -c '$(KMDRAWER_CONFIG_FILE)' draw -j '$(QMK_KEYBOARD_DIR)/keyboard.json' '$(BUILT_KEYMAP_YML)' -o '$(BUILT_KEYMAP_SVG)' \
	"
