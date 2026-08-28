---
title: Limits
description: "What MapKit does and does not expose, and how mapctl behaves at each boundary."
---

`mapctl` is a thin wrapper over MapKit. Everything below is a property of the framework, not of the tool.

## No permissions, but no offline mode

MapKit's search, geocoding, and directions services need no entitlement, no API key, and no TCC authorization — which is why `mapctl` has no `status` or `authorize` command. What they do need is the network. Every lookup is a live request, and there is no cache to fall back on.

When the network is unavailable, commands exit `1` with:

```
Could not reach Apple's map services. MapKit has no offline mode, so every
mapctl lookup needs a working network connection.
```

Run `mapctl doctor` to check connectivity; it geocodes a known address as a probe.

## Transit routes do not exist

`MKDirectionsTransportType` documents transit as *"Only supported for ETA calculations."* MapKit will return a transit travel time, but never a transit route with steps.

`mapctl` refuses the impossible request up front rather than failing somewhere inside MapKit:

```
$ mapctl directions "San Francisco" "Palo Alto" --mode transit
MapKit does not return transit routes. Use `mapctl eta` for a transit travel
time, or `mapctl link` to open the trip in Maps.
```

`mapctl eta --mode transit` works, and so does `mapctl link --from ... --to ... --mode transit`.

## Rate limiting

Apple throttles repeated lookups from one machine. This surfaces as `MKError.loadingThrottled`, which `mapctl` reports as:

```
Apple's map services are throttling this machine. Wait a few seconds and try
again; batching many lookups back to back triggers this.
```

Pace bulk work. There is no documented quota to plan against.

## Result counts are MapKit's decision

`MKLocalSearch` returns as many results as it considers relevant — sometimes one, sometimes several dozen. `--limit` trims that list client-side; it cannot ask for more. If a search feels too broad, narrow it with `--near`, `--radius`, `--category`, or `--types` rather than reaching for `--limit`.

## Places carry only what MapKit models

A place exposes name, coordinate, full and short address, city, region and region code, phone number, URL, point-of-interest category, and time zone. Business hours, ratings, reviews, menus, price levels, and photos are not part of MapKit's public API and are not available through any flag.

## Address components are coarse

macOS 26 replaced `CLPlacemark` with `MKAddress` and `MKAddressRepresentations`. These give formatted address strings plus city, region, and region code — but not the separate street, house-number, and postal-code fields the old API exposed. `--json` returns everything MapKit provides.

## Apple Maps URLs have no cycling mode

The documented `dirflg` parameter accepts driving, walking, and transit. `mapctl link --mode cycling` therefore emits a driving link and notes the substitution on stderr. Routing itself (`directions --mode cycling`) is unaffected — cycling routes work normally.

## Cycling and transit coverage varies by region

MapKit returns cycling routes and transit times only where Apple has the data. A `No route is available between those two places for that travel mode` error usually means regional coverage, not a malformed request.
