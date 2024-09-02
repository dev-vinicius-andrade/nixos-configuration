#!/bin/sh
nix eval -f $1 \
    --extra-experimental-features 'nix-command flakes' \
    --apply 'x : x {pkgs = import <nixpkgs> {};}' \
    --json | nix run nixpks#jq -- .
