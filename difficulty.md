# Difficulty

Target: exactly one of Nova, Orion and Vega solves it, more than 0% and at most 25% of the time, with the other two at 0%. Nova runs average more than 400k sequence length.

## Why it is hard

- Three separate caches decide what a request gets, and none of them is visible in a single code path:
  - the parsed-document LRU (keyed by source text);
  - the validation-error LRU;
  - compiled queries, from fixed `jit: n` on the request path and adaptive `jit: {...}` from a background queue that compiles on later ticks.
- Runtime changes skip the caches:
  - `defineResolvers` mutates field resolvers in place, but a compiled query captured the old functions;
  - `extendSchema` replaces the schema without clearing the validation-error LRU, so a query rejected before the extension stays rejected (base: 400 instead of the fresh-server 200);
  - only `replaceSchema` clears anything today, and resolvers defined after it still miss queries compiled against the new schema.
- The obvious "clear everything on every change" also runs during plugin start-up (`defineResolvers` is how the initial resolvers are installed). An existing test pins the adaptive compiler being cleared exactly once, on close. So clearing has to be limited to caches that are actually in use.
- The tests compare four servers fed the same request and change sequence: a reference with `cache: false`, the default cache, `jit: 1` and adaptive JIT. Every response, status code included, must match the reference.

## Scope

- Solution: `index.js` (cache clearing on `extendSchema`/`defineResolvers`, shared with `replaceSchema`) and docs.
- Tests: 3 tests, all of which fail on the base commit and pass with the fix. The existing 422 tests still pass.
- The repo's 100% coverage gate already fails on base in this environment (graphql 17-only tests are skipped).

## Upstream status

- Stale compiled resolvers and stale validation errors after runtime changes are not reported upstream. No upstream implementation to port.
