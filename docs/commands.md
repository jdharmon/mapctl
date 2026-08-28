---
title: Commands
description: "Full mapctl command and option reference."
---

Run `mapctl <command> --help` for the generated version of any of this.

## Global flags

Every command accepts:

| Flag | Effect |
| --- | --- |
| `-j`, `--json` | Machine-readable JSON |
| `--plain` | Stable tab-separated lines |
| `--format <standard\|table\|plain\|json\|quiet>` | Explicit format |
| `-q`, `--quiet` | Minimal output, usually a count |
| `-h`, `--help` | Command help |
| `-V`, `--version` | Print the version (root only) |

Explicit flags win over `--format`.

## Location options

`search` and `geocode` accept:

| Option | Effect |
| --- | --- |
| `-n`, `--near <place>` | Bias results toward a place name or `lat,lon` |
| `-r`, `--radius <distance>` | Radius around `--near`; requires it. Default `10km` |

`--radius` accepts a bare number (metres), or a value with a unit: `500m`, `2km`, `1.5mi`, `3000ft`, `100yd`.

## Travel options

`directions` and `eta` accept:

| Option | Effect |
| --- | --- |
| `-m`, `--mode <mode>` | `driving` (default), `walking`, `cycling`, `transit` |
| `--depart <time>` | Departure time |
| `--arrive <time>` | Desired arrival time |

`--depart` and `--arrive` are mutually exclusive. Times are absolute: `2026-09-01T09:00:00Z`, `2026-09-01T09:00`, `2026-09-01 09:00`, `2026-09-01`, or `now`. Relative phrases are not accepted.

## search

```
mapctl search <query> [options]
```

Searches Apple Maps for places matching free text.

| Option | Effect |
| --- | --- |
| `-c`, `--category <list>` | Comma-separated categories from `mapctl categories` |
| `-t`, `--types <list>` | `address`, `poi`, or `both` (default) |
| `--limit <n>` | Trim the returned list |

```bash
mapctl search "blue bottle coffee"
mapctl search coffee --near 37.3349,-122.0090 --radius 2km
mapctl search pharmacy --near Cupertino --category pharmacy --json
mapctl search "main street" --types address --limit 5
```

A bare first argument is an implicit search: `mapctl "ferry building"` is `mapctl search "ferry building"`.

## geocode

```
mapctl geocode <address> [options]
```

Turns a street address into coordinates. Use `search` for business and landmark names.

| Option | Effect |
| --- | --- |
| `--limit <n>` | Trim the returned list |

```bash
mapctl geocode "1 Apple Park Way, Cupertino CA"
mapctl geocode "221B Baker Street" --json
```

## reverse

```
mapctl reverse <lat,lon> [options]
```

Turns coordinates into an address. Latitude must be in -90...90 and longitude in -180...180. The separator may be a comma, a slash, or a space.

```bash
mapctl reverse 37.3349,-122.0090
mapctl reverse "51.5007 -0.1246" --json
```

## directions

```
mapctl directions <from> <to> [options]
```

Calculates a route. Each endpoint may be an address, a place name, or `lat,lon`; the resolved names appear in the output.

| Option | Effect |
| --- | --- |
| `--avoid <list>` | `tolls`, `highways`, or both — a preference, not a guarantee |
| `--alternates` | Request more than one route |
| `--no-steps` | Omit turn-by-turn steps |

```bash
mapctl directions "San Francisco" "Palo Alto"
mapctl directions 37.3349,-122.0090 SFO --alternates --no-steps
mapctl directions home work --avoid tolls,highways --json
```

`--mode transit` is refused: MapKit returns transit times but never transit routes. Use `eta` or `link`.

## eta

```
mapctl eta <from> <to> [options]
```

Estimates travel time without computing a full route. Unlike `directions`, this supports `--mode transit`.

```bash
mapctl eta "San Francisco" "Palo Alto"
mapctl eta home work --mode transit
mapctl eta home work --arrive "2026-09-01 09:00" --quiet   # seconds
```

## link

```
mapctl link [query] [options]
```

Prints an Apple Maps URL. With `--from` and `--to` it prints a directions link instead of a place link.

| Option | Effect |
| --- | --- |
| `--from <place>` | Trip origin |
| `--to <place>` | Trip destination |
| `-m`, `--mode <mode>` | Travel mode for a trip link |
| `--resolve` | Look the place up first so the link pins an exact coordinate |

```bash
mapctl link "Golden Gate Bridge"
mapctl link "Blue Bottle Coffee" --resolve
mapctl link 37.3349,-122.0090
mapctl link --from SFO --to "Palo Alto" --mode walking
```

Without `--resolve` and without a coordinate, `link` makes no network call. Apple Maps URLs have no cycling mode, so `--mode cycling` emits a driving link and notes it on stderr.

## categories

```
mapctl categories [options]
```

Lists the point-of-interest categories accepted by `search --category`.

```bash
mapctl categories
mapctl categories --json
```

## doctor

```
mapctl doctor [options]
```

Reports version, executable path, shell, locale, measurement system, and whether Apple's map services answer. `--for-agent` adds usage notes aimed at automated callers.

```bash
mapctl doctor
mapctl doctor --for-agent --json
```

## completion

```
mapctl completion [zsh|bash]
```

Prints a completion script. Defaults to zsh.

## Exit codes

`0` on success, `1` on any error. Errors go to stderr; data goes to stdout.
