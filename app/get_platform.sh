#!/bin/bash

ARCH=$(uname -m)

if [[ $ARCH = "x86_64" ]]; then
  PLATFORM="amd64"
elif [[ $ARCH = "aarch64" || $ARCH = "arm64" ]]; then
  PLATFORM="arm64"
else
  >&2 echo "Error: Unsupported platform"
  exit 255
fi

echo $PLATFORM
