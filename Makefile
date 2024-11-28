# Your keyboard model. Can be one of:
# voyager | moonlander | ergodox_ez | ergodox_ez/stm32/glow | planck_ez | planck_ez/glow
MY_KEYBOARD ?= voyager
# Your keymap ID. Can be found in the URL of your layout in Oryx:
# https://configure.zsa.io/voyager/layouts/<MY_KEYMAP>/latest
MY_KEYMAP ?= v9REb

# -----------------------------------------------------------------------------

GRAPHQL_URL = https://oryx.zsa.io/graphql
SOURCE_URL = https://oryx.zsa.io/source

GRAPHQL_DIR = graphql
SOURCE_DIR = src
BUILD_DIR = build

CONFIG_H = $(SOURCE_DIR)/config.h
KEYMAP_C = $(SOURCE_DIR)/keymap.c
RULES_MK = $(SOURCE_DIR)/rules.mk
SOURCE_FILES = $(CONFIG_H) $(KEYMAP_C) $(RULES_MK)

GRAPHQL_QUERY_FILE = $(GRAPHQL_DIR)/layout.graphql
GRAPHQL_QUERY_FORMAT = '{"query": $$query, "variables":{"hashId": $$hashId, "geometry": $$geometry, "revisionId": $$revisionId}}'
GRAPHQL_QUERY_BODY = $(shell jq --null-input --compact-output --arg query '$(shell cat "$(GRAPHQL_QUERY_FILE)")' --arg hashId '$(MY_KEYMAP)' --arg geometry '$(MY_KEYBOARD)' --arg revisionId 'latest' $(GRAPHQL_QUERY_FORMAT))

REV_META_JSON = $(BUILD_DIR)/rev_meta.json
REV_SOURCE_ZIP = $(BUILD_DIR)/rev_source.zip

REV_META_TITLE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.title' '$(REV_META_JSON)' || echo 'Default')
REV_META_FIRMWARE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.qmkVersion' '$(REV_META_JSON)' | xargs printf '%.0f' || echo '24')
REV_META_HASH = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.hashId' '$(REV_META_JSON)' || echo 'default')
REV_META_MESSAGE = $(shell [ -e '$(REV_META_JSON)' ] && jq -r '.revision.title' '$(REV_META_JSON)' || echo 'latest changes via Oryx')

BRANCH_ORYX = $(shell git rev-parse --abbrev-ref HEAD)
BRANCH_BUILD = $(subst -oryx,,$(BRANCH_ORYX))

# -----------------------------------------------------------------------------

.PHONY: all
all: $(SOURCE_FILES)

.PHONY: clean
clean:
	rm -f '$(SOURCE_DIR)'/* '$(BUILD_DIR)'/*

.PHONY: commit-source-dir
commit-source-dir: $(REV_META_JSON)
	git add '$(SOURCE_DIR)'
	git commit -m 'feat(oryx): $(REV_META_MESSAGE)' \
		&& git push

.PHONY: merge-into-build
merge-into-build:
	git fetch origin '$(BRANCH_BUILD)'
	git checkout -B '$(BRANCH_BUILD)' origin/'$(BRANCH_BUILD)'
	git merge --allow-unrelated-histories -Xignore-all-space '$(BRANCH_ORYX)' \
		&& git push

$(REV_META_JSON):
	curl --location --no-progress-meter \
		--header "Content-Type: application/json" \
		--header "Accept: application/json" \
		--data '$(GRAPHQL_QUERY_BODY)' \
		'$(GRAPHQL_URL)' \
		| jq '.data.layout' > '$(REV_META_JSON)'

$(REV_SOURCE_ZIP): $(REV_META_JSON)
	curl --location --no-progress-meter --output '$@' '$(SOURCE_URL)/$(REV_META_HASH)'

$(SOURCE_FILES): $(REV_SOURCE_ZIP)
	unzip -j -o '$<' '*_source/$(@F)' -d '$(SOURCE_DIR)'
