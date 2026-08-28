# mapctl

A fast macOS CLI for Apple Maps — search places, geocode addresses, route trips, and build Maps links, with output that scripts and agents can parse.

`mapctl` is a thin wrapper over Apple's public MapKit APIs, the same services that back Maps.app. There is no API key, no account, and no permission prompt: MapKit's search, geocoding, and directions services are available to any process on the machine. The only requirement is a network connection.

It is modeled on [`calctl`](../calctl), and shares its structure: a `MapCore` library that owns the Apple framework and exposes plain `Codable` value types, and a thin executable that parses arguments and renders output.

## Install

```bash
git clone <repo> mapctl && cd mapctl
make build
cp bin/mapctl /usr/local/bin/
```

`make build` produces an ad-hoc codesigned release binary in `bin/`.

## Requirements

- macOS 26 or newer
- Swift 6.2 toolchain (Xcode 26 or the matching Command Line Tools)

`mapctl` targets macOS 26 so it can use MapKit's current geocoding APIs (`MKGeocodingRequest`, `MKAddress`, `MKAddressRepresentations`). The `CLGeocoder` and `MKPlacemark` APIs they replace are deprecated as of the macOS 26 SDK.

## Quick Start

```bash
mapctl "blue bottle coffee"                       # bare text is a search
mapctl search coffee --near Cupertino --radius 2km
mapctl geocode "1 Apple Park Way, Cupertino CA"
mapctl reverse 37.3349,-122.0090
mapctl directions "San Francisco" "Palo Alto"
mapctl eta home work --mode transit
mapctl link "Golden Gate Bridge"
mapctl categories
mapctl doctor
```

## Commands

| Command | Description |
| --- | --- |
| `search <query>` | Search for places by name or category |
| `geocode <address>` | Turn a street address into coordinates |
| `reverse <lat,lon>` | Turn coordinates into an address |
| `directions <from> <to>` | Calculate a route between two places |
| `eta <from> <to>` | Estimate travel time, including transit |
| `link [query]` | Print an Apple Maps URL for a place or a trip |
| `categories` | List the categories accepted by `--category` |
| `doctor` | Diagnose setup and connectivity |
| `completion` | Generate zsh or bash completion |

Aliases: `find`/`poi` → `search`, `geo` → `geocode`, `rev` → `reverse`, `route`/`dir` → `directions`, `url` → `link`, `cats` → `categories`.

A bare first argument is treated as a search, so `mapctl "ferry building"` works. The flip side is that a mistyped command searches for the typo instead of reporting an unknown command.

## Searching

```
$ mapctl search coffee --near 37.3349,-122.0090 --radius 2km --limit 2
[1] Philz Coffee  (cafe)
    19439 Stevens Creek Blvd, Cupertino, CA  95014, United States
    37.324319,-122.010522
    +1 (408) 200-4856
    https://www.philzcoffee.com
[2] Nirvana Soul  (cafe)
    19700 Vallco Pkwy, Cupertino, CA  95014, United States
    37.325370,-122.012790
```

`--near` takes a place name or a `lat,lon` pair and focuses the search; without it the search is worldwide. `--radius` accepts `500m`, `2km`, `1.5mi`, or `3000ft`, and requires `--near`. `--category` takes comma-separated values from `mapctl categories`.

Use `geocode` for street addresses and `search` for business names — geocoding will not find "blue bottle coffee".

## Directions

```
$ mapctl directions "San Francisco" "Palo Alto" --no-steps
From: San Francisco
To:   Palo Alto

[1] US-101 S — 33 mi, 46 min
```

Each endpoint may be an address, a place name, or `lat,lon`, and the resolved names are echoed so you can see what was matched. `--mode` selects `driving`, `walking`, `cycling`, or `transit`; `--depart`/`--arrive` take absolute times and are mutually exclusive; `--alternates` asks for more than one route; `--avoid tolls,highways` expresses a preference.

## Output

Every command supports five formats:

| Format | Use |
| --- | --- |
| `standard` | Human-readable, numbered, with local units |
| `--format table` | Tab-separated with a header row |
| `--plain` | Tab-separated, no header, stable field order |
| `-j`, `--json` | Every field, ISO-8601 dates, sorted keys |
| `-q`, `--quiet` | A count, or travel time in seconds for `eta` |

Explicit flags beat `--format`. Data goes to stdout, errors to stderr, exit `0` on success and `1` on any error.

## Links

```
$ mapctl link "Golden Gate Bridge"
https://maps.apple.com/?q=Golden%20Gate%20Bridge

$ mapctl link --from SFO --to "Palo Alto" --mode walking
https://maps.apple.com/?saddr=SFO&daddr=Palo%20Alto&dirflg=w
```

Link building needs no network unless you pass `--resolve`, which looks the place up first so the URL points at an exact pin.

## MapKit Limits

Things the framework does not offer, so `mapctl` cannot either:

- **No transit routes.** MapKit returns transit *travel times* but never transit *routes*, so `directions --mode transit` is refused with a pointer to `eta`. This is a documented MapKit constraint, not a `mapctl` gap.
- **No offline mode.** Every command needs the network.
- **Rate limiting.** Apple throttles repeated lookups; bulk work needs pacing.
- **No place details.** Business hours, reviews, menus, and photos are not exposed. A place carries name, address, coordinate, phone, URL, category, and time zone.
- **Result counts are MapKit's call.** `--limit` trims the returned list; it cannot ask for more.
- **Cycling links degrade.** Apple Maps URLs have no cycling parameter, so `link --mode cycling` emits a driving link.

## Development

```bash
make format   # swift format in-place
make lint     # swift format lint + swiftlint --strict + shellcheck
make test     # swift test with coverage
make check    # lint + test + 90% coverage gate on MapCore
make build    # release build into bin/ (codesigned)
make mapctl ARGS="search coffee"   # clean rebuild + run
```

`pnpm install` is optional; `pnpm test`, `pnpm check`, and `pnpm build` mirror the Makefile targets.

Tests use swift-testing and never construct a MapKit type — all logic worth testing lives in pure functions in `MapCore`. The three files that do touch MapKit (`MapService`, `MapServiceDirections`, `MapKitConversions`) are excluded from the coverage gate.

## License

MIT. See [LICENSE](LICENSE).
