#!/bin/bash

echo "This script is meant for use in GitHub actions"
echo ""

function build() {
    flatpak-builder --force-clean build-dir --install-deps-from=flathub --repo=repo ../flatpak/com.github.nocrypt.migu.yaml
}

function install() {
    flatpak-builder --user --install --force-clean build-dir --install-deps-from=flathub --repo=repo ../flatpak/com.github.nocrypt.migu.yaml
}

function bundle() {
    flatpak build-bundle repo dist/com.github.nocrypt.migu.flatpak com.github.nocrypt.migu
}

case "$1" in
    --build)
        build
        ;;
    --install)
        install
        ;;
    --bundle)
        bundle
        ;;
    *)
        echo "Usage: $0 {--build|--install|--bundle}"
        exit 1
        ;;
esac
