---
title: Overview
permalink: /
description: "mapctl is a fast macOS CLI for Apple Maps, built for terminals, scripts, and agents."
---

## Try it

```bash
mapctl "blue bottle coffee"                       # bare text is a search
mapctl search coffee --near Cupertino --radius 2km
mapctl search pharmacy --near 37.3349,-122.0090 --category pharmacy

mapctl geocode "1 Apple Park Way, Cupertino CA"
mapctl reverse 37.3349,-122.0090

mapctl directions "San Francisco" "Palo Alto"
mapctl eta home work --mode transit --quiet

mapctl link "Golden Gate Bridge"
mapctl doctor
```

## Why mapctl

- **No setup.** No API key, no account, no permission prompt — MapKit's services are available to any process on the Mac.
- **Same data as Maps.app.** It calls Apple's public MapKit APIs directly.
- **Built for pipes.** `--json` for structure, `--plain` for `cut` and `awk`, `--quiet` for a single number.
- **Honest about limits.** Where MapKit cannot do something, `mapctl` says so and points at what works.

## Where to go next

- [Commands](commands.md) — full command and option reference
- [Install](install.md) — building, signing, and shell completion
- [Limits](limits.md) — what MapKit does and does not expose

## Limits

`mapctl` needs a network connection, returns no transit routes (only transit ETAs), and exposes no business hours, reviews, or photos. See [Limits](limits.md) for the details.
