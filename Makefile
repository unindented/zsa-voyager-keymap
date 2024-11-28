# Your keyboard model. Can be one of:
# voyager | moonlander | ergodox_ez | ergodox_ez/stm32/glow | planck_ez | planck_ez/glow
MY_KEYBOARD ?= voyager
# Your keymap ID. Can be found in the URL of your layout in Oryx:
# https://configure.zsa.io/voyager/layouts/<MY_KEYMAP>/latest
MY_KEYMAP ?= v9REb

# -----------------------------------------------------------------------------

GRAPHQL_URL = https://oryx.zsa.io/graphql
SOURCE_URL = https://oryx.zsa.io/source
QMK_GIT_URL = https://github.com/zsa/qmk_firmware.git

GRAPHQL_DIR = graphql
KMDRAWER_DIR = kmdrawer
QMK_DIR = qmk_firmware
SOURCE_DIR = src
BUILD_DIR = build

GRAPHQL_QUERY_FILE = $(GRAPHQL_DIR)/layout.graphql
GRAPHQL_QUERY_FORMAT = '{"query": $$query, "variables":{"hashId": $$hashId, "geometry": $$geometry, "revisionId": $$revisionId}}'
GRAPHQL_QUERY_BODY = $(shell jq --null-input --compact-output --arg query '$(shell cat "$(GRAPHQL_QUERY_FILE)")' --arg hashId '$(MY_KEYMAP)' --arg geometry '$(MY_KEYBOARD)' --arg revisionId 'latest' $(GRAPHQL_QUERY_FORMAT))

KMDRAWER_CONFIG_FILE = $(KMDRAWER_DIR)/config.yml

REV_META_JSON = $(BUILD_DIR)/rev_meta.json
BUILT_KEYBOARD_JSON = $(BUILD_DIR)/keyboard.json
BUILT_KEYMAP_BIN = $(BUILD_DIR)/keymap.bin
BUILT_KEYMAP_JSON = $(BUILD_DIR)/keymap.json
BUILT_KEYMAP_YML = $(BUILD_DIR)/keymap.yml
BUILT_KEYMAP_SVG = $(BUILD_DIR)/keymap.svg

REV_META_TITLE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.title' '$(REV_META_JSON)' || echo 'Default')
REV_META_FIRMWARE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.qmkVersion' '$(REV_META_JSON)' | xargs printf '%.0f' || echo '24')
REV_META_HASH = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.hashId' '$(REV_META_JSON)' || echo 'default')
REV_META_MESSAGE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.title' '$(REV_META_JSON)' || echo 'latest changes via Oryx')

QMK_DOCKER_IMAGE = qmk
QMK_MAKE_PREFIX = $(shell [ '$(REV_META_FIRMWARE)' -ge 24 ] && echo 'zsa/' || echo '')
QMK_MAKE_KEYBOARD = $(QMK_MAKE_PREFIX)$(MY_KEYBOARD)
QMK_MAKE_TARGET = $(QMK_MAKE_KEYBOARD):$(MY_KEYMAP)
QMK_MAKE_TARGET_NORMALIZED = $(shell echo '$(QMK_MAKE_TARGET)' | sed 's/[^a-zA-Z0-9]/_/g')
QMK_KEYBOARDS_PATH = $(shell [ '$(REV_META_FIRMWARE)' -ge 24 ] && echo 'keyboards/zsa' || echo 'keyboards')
QMK_KEYBOARD_DIR = $(QMK_DIR)/$(QMK_KEYBOARDS_PATH)/$(MY_KEYBOARD)
QMK_KEYMAP_DIR = $(QMK_KEYBOARD_DIR)/keymaps/$(MY_KEYMAP)

# -----------------------------------------------------------------------------

.PHONY: all
all: $(BUILT_KEYMAP_BIN) $(BUILT_KEYMAP_JSON) $(BUILT_KEYMAP_SVG)

.PHONY: clean
clean:
	rm -f '$(BUILD_DIR)'/*

.PHONY: echo-env
echo-env: $(REV_META_JSON)
	echo my_keyboard = "$(MY_KEYBOARD)"
	echo my_keymap = "$(MY_KEYMAP)"
	echo rev_meta_title = "$(shell echo $(REV_META_TITLE) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')"
	echo rev_meta_firmware = "$(REV_META_FIRMWARE)"
	echo rev_meta_hash = "$(REV_META_HASH)"
	echo rev_meta_message = "$(REV_META_MESSAGE)"
	echo timestamp = "$(shell date +'%Y%m%d%H%M%S')"

.PHONY: commit-build-dir
commit-build-dir:
	git add '$(BUILD_DIR)'
	git commit -m 'feat: update keymap diagram' \
		&& git push \
		|| echo 'No changes'

.PHONY: build-qmk-image
build-qmk-image:
	docker build --tag '$(QMK_DOCKER_IMAGE)' .

$(REV_META_JSON):
	curl --location --no-progress-meter \
		--header "Content-Type: application/json" \
		--header "Accept: application/json" \
		--data '$(GRAPHQL_QUERY_BODY)' \
		'$(GRAPHQL_URL)' \
		| jq '.data.layout' > '$(REV_META_JSON)'

$(BUILT_KEYMAP_BIN) $(BUILT_KEYMAP_JSON) $(BUILT_KEYBOARD_JSON) &: $(REV_META_JSON)
	$(MAKE) build-qmk-image
	docker run --volume ./'$(BUILD_DIR)':/root/'$(BUILD_DIR)' --volume ./'$(KMDRAWER_DIR)':/root/'$(KMDRAWER_DIR)' --volume ./'$(SOURCE_DIR)':/root/'$(SOURCE_DIR)' --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		git clone --branch 'firmware$(REV_META_FIRMWARE)' --single-branch --recursive '$(QMK_GIT_URL)' '$(QMK_DIR)' \
			&& cp '$(QMK_KEYBOARD_DIR)/keyboard.json' '$(BUILT_KEYBOARD_JSON)' \
			&& rm -rf '$(QMK_KEYMAP_DIR)' \
			&& cp -r '$(SOURCE_DIR)' '$(QMK_KEYMAP_DIR)' \
			&& cd '$(QMK_DIR)' \
			&& qmk setup -y -b firmware$(REV_META_FIRMWARE) zsa/qmk_firmware \
			&& qmk compile -km '$(MY_KEYMAP)' -kb '$(QMK_MAKE_KEYBOARD)' \
			&& mv '$(QMK_MAKE_TARGET_NORMALIZED).bin' '../$(BUILT_KEYMAP_BIN)' \
			&& qmk c2json -km '$(MY_KEYMAP)' -kb '$(QMK_MAKE_KEYBOARD)' --no-cpp -o '../$(BUILT_KEYMAP_JSON)' \
	"

$(BUILT_KEYMAP_YML) $(BUILT_KEYMAP_SVG) &: $(BUILT_KEYMAP_JSON)
	$(MAKE) build-qmk-image
	docker run --volume ./'$(BUILD_DIR)':/root/'$(BUILD_DIR)' --volume ./'$(KMDRAWER_DIR)':/root/'$(KMDRAWER_DIR)' --rm '$(QMK_DOCKER_IMAGE)' /bin/sh -c "\
		keymap parse -q '$(BUILT_KEYMAP_JSON)' -o '$(BUILT_KEYMAP_YML)' \
			&& keymap -c '$(KMDRAWER_CONFIG_FILE)' draw -j '$(BUILT_KEYBOARD_JSON)' '$(BUILT_KEYMAP_YML)' -o '$(BUILT_KEYMAP_SVG)' \
	"
