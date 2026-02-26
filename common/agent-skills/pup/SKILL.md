---
name: pup
description: Use pup to query Datadog metrics and logs -- search, query, aggregate, list, and analyze observability data from the command line.
---

## Purpose

Use this skill when you need to query Datadog for observability data: searching logs, querying time-series metrics, aggregating log statistics, listing available metrics, or inspecting metric metadata. `pup` is a CLI wrapper around Datadog APIs.

## When to use what

### Metrics

- `pup metrics query`: Query time-series metric data with aggregation, filtering, and grouping. Primary command for metric analysis.
- `pup metrics search`: Same query syntax as `query` but uses the simpler v1 API. Use when you don't need v2 timeseries formula semantics.
- `pup metrics list`: Discover available metric names. Use with `--filter` to narrow by pattern.
- `pup metrics metadata get`: Read metadata (description, unit, type) for a specific metric.
- `pup metrics tags list`: List available tags for a specific metric.

### Logs

- `pup logs query`: Query logs using the v2 API (recommended). Supports timezone and flexible sorting.
- `pup logs search`: Search logs using the v1 API. Simpler but less capable than `query`.
- `pup logs list`: List logs with basic filtering. Lightest-weight log retrieval.
- `pup logs aggregate`: Statistical analysis on logs -- count, avg, percentile, cardinality, grouped by field.

## Core concepts

- **Output format**: Use `-o table` for human-readable output, `-o json` for machine-readable. Default is `json`.
- **Time ranges**: `--from` and `--to` accept relative values (`1h`, `30m`, `7d`, `1w`, `1M`) or absolute unix timestamps. `--to` defaults to `now`.
- **Metric query syntax**: `<aggregation>:<metric_name>{<filter>} [by {<group>}]`
  - Aggregations: `avg`, `sum`, `min`, `max`, `count`
  - Filters: tag key-value pairs like `{env:prod}`, `{host:web-*}`, or `{*}` for all
  - Grouping: `by {service}`, `by {host,env}`
- **Log query syntax**: Uses Datadog search syntax
  - By field: `status:error`, `service:web-app`, `host:i-*`
  - By attribute: `@http.status_code:500`, `@user.id:12345`
  - Boolean: `AND`, `OR`, `NOT`, negation with `-status:info`
  - Phrase: `"exact phrase"`
  - Wildcard: `host:i-*`

## Recommended workflow

### Investigating a metric

1. Discover metrics: `pup metrics list --filter="<pattern>"` to find relevant metric names.
2. Inspect metadata: `pup metrics metadata get <metric>` to understand unit and type.
3. Check tags: `pup metrics tags list <metric>` to see available dimensions.
4. Query data: `pup metrics query --query="avg:<metric>{<filter>} by {<group>}" --from="1h"`

### Investigating logs

1. Start broad: `pup logs search --query="status:error" --from="1h" --limit=10` to see recent errors.
2. Narrow down: Add filters like `service:X AND @http.status_code:500`.
3. Aggregate for patterns: `pup logs aggregate --query="status:error" --from="1h" --compute="count" --group-by="service"` to find which services are failing.
4. Deep dive: `pup logs query --query="service:failing-svc AND status:error" --from="1h" --limit=100` for full log details.

## Important tips

- Prefer `-o json` when processing output programmatically; use `-o table` when presenting to users.
- For log searches, `--limit` defaults to 50 (max 1000 for search, configurable for query/list).
- Metric queries return time-series arrays with timestamps -- the data points are in the `series` field of the JSON output.
- Log aggregate `--compute` supports: `count`, `avg(@field)`, `sum(@field)`, `min(@field)`, `max(@field)`, `cardinality(@field)`, `percentile(@field, N)`.
- Use `--group-by` with aggregate to break down results by any log field or attribute.
- Time ranges are relative to now: `1h` means "1 hour ago to now", `7d` means "7 days ago to now".
