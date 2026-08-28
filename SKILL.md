---
name: apple-maps
description: "Use mapctl to search Apple Maps on macOS 26+, geocode and reverse-geocode addresses, calculate driving/walking/cycling routes and transit ETAs, and generate Apple Maps links, with stable JSON output for scripting."
---

# Apple Maps

Use `mapctl` for Apple Maps lookups on macOS. It calls Apple's public MapKit APIs, so results match what Maps.app shows. No API key, no account, and no permission prompt are involved — only a network connection.

## Prerequisites

- macOS 26+
- `mapctl` installed and available on `PATH`
- A working network connection; MapKit has no offline mode

## Use This Skill When

- The user wants to find a place, business, or address
- The user asks how far apart two places are, or how long a trip takes
- The user wants coordinates for an address, or an address for coordinates
- The user wants a shareable Apple Maps link

## Do Not Use This Skill When

- The user wants a calendar event or their schedule — use `calctl`
- The user wants turn-by-turn navigation started on a device; `mapctl link` produces a URL they can open, nothing more
- The user wants business hours, reviews, menus, or photos; MapKit does not expose them

## Command Model

| Command | Use it for |
| --- | --- |
| `search <query>` | Finding places by name or category |
| `geocode <address>` | Address to coordinates |
| `reverse <lat,lon>` | Coordinates to address |
| `directions <from> <to>` | Routes with turn-by-turn steps |
| `eta <from> <to>` | Travel time only, including transit |
| `link [query]` | An Apple Maps URL |
| `categories` | The valid `--category` values |
| `doctor` | Environment and connectivity check |

A bare first argument is treated as a search: `mapctl "blue bottle coffee"` is the same as `mapctl search "blue bottle coffee"`. Because any word is a valid query, a mistyped command name searches for the typo rather than reporting an error.

## Helpful Aliases

`find`/`poi` → `search`, `geo` → `geocode`, `rev` → `reverse`, `route`/`dir` → `directions`, `url` → `link`, `cats` → `categories`.

## Output And Flags

- Prefer `--json` whenever another step consumes the output. It is the only format that carries every field.
- `--plain` gives stable tab-separated lines with no header, for `cut` and `awk`.
- `--quiet` gives a count for lists, and travel time in seconds for `eta`.
- Explicit `--json`/`--plain`/`--quiet` win over `--format`.
- Data goes to stdout, errors to stderr. Exit code is `0` on success and `1` on any error.

## Searching

- Pass `--near` to focus a search; without it the search is worldwide and favours famous places. `--near` takes a place name or a `lat,lon` pair.
- `--radius` accepts `500m`, `2km`, `1.5mi`, `3000ft`; a bare number is metres. It requires `--near`.
- `--category` takes comma-separated values from `mapctl categories`. Do not guess category names — list them first.
- `--types address|poi|both` narrows what kind of result comes back.
- MapKit decides how many results to return; `--limit` only trims that list further.

## Geocoding

- Use `geocode` for street addresses and `search` for business or landmark names. `geocode` will not find "blue bottle coffee"; `search` will.
- `reverse` requires a valid `lat,lon` pair: latitude in -90...90, longitude in -180...180.

## Directions And ETA

- Endpoints may each be an address, a place name, or `lat,lon`. Both are resolved before routing, and the resolved names appear in the output — check them if a result looks wrong.
- `--mode` accepts `driving`, `walking`, `cycling`, `transit`. Driving is the default.
- **`directions --mode transit` always fails.** MapKit returns transit travel times but never transit routes. Use `eta --mode transit`, or `link` to hand the user a URL.
- `--depart` and `--arrive` take absolute times (`2026-09-01T09:00`, `2026-09-01 09:00`, or `now`). They are mutually exclusive. Relative phrasing like "tomorrow" is not accepted.
- `--alternates` asks for more than one route; `--avoid tolls,highways` expresses a preference, not a guarantee.
- `--no-steps` drops turn-by-turn text when only the totals matter.

## Links

- `mapctl link "<place>"` builds a URL from the text without a network call. Add `--resolve` to look the place up first so the link points at an exact pin.
- `mapctl link --from A --to B --mode walking` builds a directions URL. Both endpoints are required.
- Apple Maps URLs have no cycling mode; `--mode cycling` produces a driving link and says so on stderr.

## Limits

- Every command needs the network. Failures are network or throttling failures, never permission failures.
- Back-to-back lookups can trip Apple's rate limiting. Space out bulk work and expect a throttling error if you do not.
- MapKit exposes name, address, coordinate, phone, URL, category, and time zone for a place — nothing else.

## Response Discipline

- Report the resolved place names, not just the user's input, so the user can see what was matched.
- State distances and times in the units the command printed; do not silently convert.
- If a search returns nothing, say so and suggest narrowing with `--near` rather than inventing a result.
- Never fabricate coordinates, addresses, or travel times. If a command fails, report the failure.
