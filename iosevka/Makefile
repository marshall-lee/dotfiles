DIST := dist
JOBS ?= 4
FONT_DIR ?= $(if $(filter Darwin,$(shell uname)),$(HOME)/Library/Fonts,$(HOME)/.local/share/fonts)

.PHONY: build download install clean

build:
	rm -rf $(DIST)
	docker buildx build --build-arg JOBS=$(JOBS) --output type=local,dest=$(DIST) .

# Fetches the fonts from the newest iosevka-* GitHub release instead of building.
download:
	rm -rf $(DIST)
	gh release download --pattern '*.ttf' --dir $(DIST) \
	  $$(gh release list --json tagName --jq '[.[] | select(.tagName | startswith("iosevka-"))][0].tagName')

install:
	mkdir -p $(FONT_DIR)
	cp $(DIST)/*.ttf $(FONT_DIR)/

clean:
	rm -rf $(DIST)
