#!/bin/bash

# This script checks upstream versions of components
# and compares them to the versions in the Dockerfile.

# Switch between the different options, cloudflared, uptimekuma, and baseimage
CLOUDFLARED_NEW_VERSION=false
UPTIME_KUMA_NEW_VERSION=false
BASEIMAGE_NEW_VERSION=false

GITHUB_TOKEN=$(cat ~/.githubRegistryPAT)

# Check to make sure there was an input provided
if [ -z "$1" ]; then
    echo "Please provide an action: describe, current-version, latest-version, or check-update"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Please provide a version to check: cloudflared, uptimekuma, or baseimage"
    exit 1
fi

# Check to make sure the input is valid
if [ "$2" != "all" ] && [ "$2" != "cloudflared" ] && [ "$2" != "uptimekuma" ] && [ "$2" != "baseimage" ]; then
    echo "Please provide a valid version to check: cloudflared, uptimekuma, or baseimage"
    exit 1
fi

CLOUDFLARED_VERSION="$(curl -sSL -H 'User-Agent: kenmoini' -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r .tag_name)"
UPTIME_KUMA_VERSION="$(curl -sSL -H 'User-Agent: kenmoini' -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/louislam/uptime-kuma/releases/latest | jq -r .tag_name)"
BASEIMAGE_VERSION="$(curl -sSL https://registry.access.redhat.com/v2/ubi8/nodejs-16/tags/list | jq -r '.tags[]' | sort -V | grep -vE 'latest|source|\.' | tail -1)"

# Read in the current versions from the Dockerfile
CLOUDFLARED_CURRENT="$(grep -oP 'ARG CLOUDFLARED_VERSION=\K(.*)' Dockerfile)"
UPTIME_KUMA_CURRENT="$(grep -oP 'ARG UPTIME_KUMA_VERSION=\K(.*)' Dockerfile)"
BASEIMAGE_CURRENT="$(grep -oP 'registry.access.redhat.com/ubi8/nodejs-16:\K(.*)' Dockerfile | cut -d ' ' -f 1)"

# Switch beteween the different options
case $2 in

  cloudflared)
    if [ "$1" == "describe" ]; then
      echo "Cloudflared"
      echo "----------------"
      echo "Current version: $CLOUDFLARED_CURRENT"
      echo "Latest version: $CLOUDFLARED_VERSION"
      if [ "$CLOUDFLARED_CURRENT" != "$CLOUDFLARED_VERSION" ]; then
        echo "=== Cloudflared update available!"
      fi
    fi
    if [ "$1" == "current-version" ]; then
      echo $CLOUDFLARED_CURRENT
    fi
    if [ "$1" == "latest-version" ]; then
      echo $CLOUDFLARED_VERSION
    fi
    if [ "$1" == "check-update" ]; then
      if [ "$CLOUDFLARED_CURRENT" != "$CLOUDFLARED_VERSION" ]; then
        echo "true"
      else
        echo "false"
      fi
    fi
    ;;
  uptimekuma)
    if [ "$1" == "describe" ]; then
      echo "Uptime Kuma"
      echo "----------------"
      echo "Current version: $UPTIME_KUMA_CURRENT"
      echo "Latest version: $UPTIME_KUMA_VERSION"
      if [ "$UPTIME_KUMA_CURRENT" != "$UPTIME_KUMA_VERSION" ]; then
        echo "=== Uptime Kuma update available!"
      fi
    fi
    if [ "$1" == "current-version" ]; then
      echo $UPTIME_KUMA_CURRENT
    fi
    if [ "$1" == "latest-version" ]; then
      echo $UPTIME_KUMA_VERSION
    fi
    if [ "$1" == "check-update" ]; then
      if [ "$UPTIME_KUMA_CURRENT" != "$UPTIME_KUMA_VERSION" ]; then
        echo "true"
      else
        echo "false"
      fi
    fi
    ;;
  baseimage)
    if [ "$1" == "describe" ]; then
      echo "Baseimage"
      echo "----------------"
      echo "Current version: $BASEIMAGE_CURRENT"
      echo "Latest version: $BASEIMAGE_VERSION"
      if [ "$BASEIMAGE_CURRENT" != "$BASEIMAGE_VERSION" ]; then
        echo "=== Baseimage update available!"
      fi
    fi
    if [ "$1" == "current-version" ]; then
      echo $BASEIMAGE_CURRENT
    fi
    if [ "$1" == "latest-version" ]; then
      echo $BASEIMAGE_VERSION
    fi
    if [ "$1" == "check-update" ]; then
      if [ "$BASEIMAGE_CURRENT" != "$BASEIMAGE_VERSION" ]; then
        echo "true"
      else
        echo "false"
      fi
    fi
    ;;
  all)
    if [ "$1" == "describe" ]; then
      echo "Cloudflared"
      echo "----------------"
      echo "Current version: $CLOUDFLARED_CURRENT"
      echo "Latest version: $CLOUDFLARED_VERSION"
      if [ "$CLOUDFLARED_CURRENT" != "$CLOUDFLARED_VERSION" ]; then
        echo "=== Cloudflared update available!"
      fi
      echo ""
      echo "Uptime Kuma"
      echo "----------------"
      echo "Current version: $UPTIME_KUMA_CURRENT"
      echo "Latest version: $UPTIME_KUMA_VERSION"
      if [ "$UPTIME_KUMA_CURRENT" != "$UPTIME_KUMA_VERSION" ]; then
        echo "=== Uptime Kuma update available!"
      fi
      echo ""
      echo "Baseimage"
      echo "----------------"
      echo "Current version: $BASEIMAGE_CURRENT"
      echo "Latest version: $BASEIMAGE_VERSION"
      if [ "$BASEIMAGE_CURRENT" != "$BASEIMAGE_VERSION" ]; then
        echo "=== Baseimage update available!"
      fi
      echo ""
    fi
    if [ "$1" == "current-version" ]; then
      echo "cloudflared: ${CLOUDFLARED_CURRENT}"
      echo "uptimekuma: ${UPTIME_KUMA_CURRENT}"
      echo "baseimage: ${BASEIMAGE_CURRENT}"
    fi
    if [ "$1" == "latest-version" ]; then
      echo "cloudflared: ${CLOUDFLARED_VERSION}"
      echo "uptimekuma: ${UPTIME_KUMA_VERSION}"
      echo "baseimage: ${BASEIMAGE_VERSION}"
    fi
    if [ "$1" == "check-update" ]; then
      if [ "$CLOUDFLARED_CURRENT" != "$CLOUDFLARED_VERSION" ]; then
        echo "cloudflared: true"
      else
        echo "cloudflared: false"
      fi
      if [ "$UPTIME_KUMA_CURRENT" != "$UPTIME_KUMA_VERSION" ]; then
        echo "uptimekuma: true"
      else
        echo "uptimekuma: false"
      fi
      if [ "$BASEIMAGE_CURRENT" != "$BASEIMAGE_VERSION" ]; then
        echo "baseimage: true"
      else
        echo "baseimage: false"
      fi
    fi
    ;;

esac
