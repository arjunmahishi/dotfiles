#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple


PRESET_ROOT = Path("/Library/Audio/Presets/Neural DSP/Archetype Tim Henson X")
DEFAULT_TEMPLATE = PRESET_ROOT / "Default.xml"
OUTPUT_DIR = PRESET_ROOT / "AI generated"
DB_PATH = Path(__file__).with_name("presets_db.json")


@dataclass
class ValueEntry:
    key: str
    len_pos: int
    value_start: int
    value_end: int
    value: str


def _is_key_char(byte: int) -> bool:
    return (
        48 <= byte <= 57
        or 65 <= byte <= 90
        or 97 <= byte <= 122
        or byte in (42, 45, 46, 95)
    )


def parse_value_entries(data: bytes) -> List[ValueEntry]:
    entries: List[ValueEntry] = []
    i = 0
    n = len(data)

    while i < n:
        key_start = i
        while i < n and _is_key_char(data[i]):
            i += 1

        if i == key_start or i >= n or data[i] != 0:
            i += 1
            continue

        key = data[key_start:i].decode("ascii", errors="ignore")
        if not key:
            i += 1
            continue

        if i + 3 >= n:
            break

        if data[i + 1] != 1 or data[i + 3] != 5:
            i += 1
            continue

        len_pos = i + 2
        value_start = i + 4
        value_end = data.find(b"\x00", value_start)
        if value_end < 0:
            break

        declared_len = data[len_pos]
        actual_len = (value_end - value_start) + 2
        if declared_len != actual_len:
            i += 1
            continue

        raw = data[value_start:value_end]
        try:
            value = raw.decode("ascii")
        except UnicodeDecodeError:
            i = value_end + 1
            continue

        entries.append(
            ValueEntry(
                key=key,
                len_pos=len_pos,
                value_start=value_start,
                value_end=value_end,
                value=value,
            )
        )
        i = value_end + 1

    return entries


def parse_params(data: bytes) -> Dict[str, str]:
    params: Dict[str, str] = {}
    for entry in parse_value_entries(data):
        params[entry.key] = entry.value
    return params


def apply_updates(data: bytes, updates: Dict[str, str]) -> bytes:
    entries = parse_value_entries(data)
    by_key: Dict[str, ValueEntry] = {e.key: e for e in entries}
    patches: List[Tuple[int, int, int, bytes]] = []

    for key, value in updates.items():
        entry = by_key.get(key)
        if not entry:
            continue

        encoded = value.encode("ascii")
        length_byte = len(encoded) + 2
        if length_byte > 255:
            raise ValueError(f"Value too long for key '{key}': {value}")

        patches.append((entry.value_start, entry.value_end, entry.len_pos, encoded))

    patched = data
    for start, end, len_pos, encoded in sorted(patches, key=lambda x: x[0], reverse=True):
        patched = patched[:len_pos] + bytes([len(encoded) + 2]) + patched[len_pos + 1 :]
        patched = patched[:start] + encoded + patched[end:]

    return patched


def _format_float(value: float) -> str:
    txt = f"{value:.6f}".rstrip("0").rstrip(".")
    if txt == "-0":
        return "0"
    return txt


def normalize_override_value(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if not math.isfinite(value):
            raise ValueError("Float values must be finite")
        return _format_float(value)
    if isinstance(value, str):
        if "\x00" in value:
            raise ValueError("String values cannot contain NUL characters")
        value.encode("ascii")
        return value
    raise ValueError(f"Unsupported value type: {type(value).__name__}")


def sanitize_name(name: str) -> str:
    clean = "".join(
        ch if (ch.isascii() and (ch.isalnum() or ch in ("-", "_"))) else "_"
        for ch in name.strip()
    )
    clean = clean.strip("_")
    return clean or "ai_preset"


def ensure_output_dir() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def load_stdin_overrides() -> Dict[str, object]:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError as error:
        raise ValueError(f"Invalid JSON on stdin: {error}") from error

    if not isinstance(payload, dict):
        raise ValueError("Stdin JSON must be an object of parameter overrides")

    return payload


def do_generate(name: str, template: str | None) -> int:
    template_path = Path(template) if template else DEFAULT_TEMPLATE
    if not template_path.exists():
        raise FileNotFoundError(f"Template does not exist: {template_path}")

    template_data = template_path.read_bytes()
    base_params = parse_params(template_data)
    if not base_params:
        raise RuntimeError(f"Could not parse parameters from template: {template_path}")

    overrides = load_stdin_overrides()
    normalized_overrides: Dict[str, str] = {}
    unknown_keys: List[str] = []
    for key, raw_value in overrides.items():
        if key not in base_params:
            unknown_keys.append(key)
            continue
        normalized_overrides[key] = normalize_override_value(raw_value)

    if unknown_keys:
        unknown_list = ", ".join(sorted(unknown_keys))
        raise ValueError(f"Unknown parameter key(s): {unknown_list}")

    merged_params = dict(base_params)
    merged_params.update(normalized_overrides)
    merged_params["name"] = sanitize_name(name)

    changed_values: Dict[str, str] = {}
    for key, value in merged_params.items():
        if base_params.get(key) != value:
            changed_values[key] = value

    output_name = sanitize_name(name)
    output_path = OUTPUT_DIR / f"{output_name}.xml"
    if output_path.exists():
        raise FileExistsError(f"Output already exists: {output_path}")

    ensure_output_dir()
    out_bytes = apply_updates(template_data, changed_values)
    output_path.write_bytes(out_bytes)

    print(f"Template: {template_path}")
    print(f"Output:   {output_path}")
    print(f"Updated:  {len(changed_values)} parameter(s)")
    if normalized_overrides:
        print("Overrides:")
        for key in sorted(normalized_overrides.keys()):
            print(f"- {key} = {normalized_overrides[key]}")
    return 0


def do_index() -> int:
    presets: List[Dict[str, object]] = []
    for path in sorted(PRESET_ROOT.rglob("*.xml")):
        if "AI generated" in path.parts:
            continue
        try:
            params = parse_params(path.read_bytes())
        except OSError:
            continue
        presets.append(
            {
                "path": str(path),
                "name": path.stem,
                "key_count": len(params),
                "keys": sorted(params.keys()),
            }
        )

    payload = {
        "preset_root": str(PRESET_ROOT),
        "count": len(presets),
        "presets": presets,
    }
    DB_PATH.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"Indexed {len(presets)} presets -> {DB_PATH}")
    return 0


def do_params(template: str | None) -> int:
    template_path = Path(template) if template else DEFAULT_TEMPLATE
    if not template_path.exists():
        raise FileNotFoundError(f"Template does not exist: {template_path}")

    params = parse_params(template_path.read_bytes())
    if not params:
        raise RuntimeError(f"Could not parse parameters from template: {template_path}")

    print(f"Template: {template_path}")
    print(f"Parameter count: {len(params)}")
    for key in sorted(params.keys()):
        print(key)
    return 0


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="tim_henson_skill.py",
        description="Generate Tim Henson X presets from template + JSON overrides on stdin.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    gen = sub.add_parser("generate", help="Generate a preset from JSON overrides on stdin")
    gen.add_argument("--name", required=True, help="Output preset name (without extension)")
    gen.add_argument("--template", default=None, help="Optional source template preset path")

    sub.add_parser("index", help="Build preset key index cache")

    params = sub.add_parser("params", help="Print all parameter keys from a template")
    params.add_argument("--template", default=None, help="Template path; defaults to Default.xml")

    return parser


def main() -> int:
    parser = build_arg_parser()
    args = parser.parse_args()

    try:
        if args.command == "generate":
            return do_generate(args.name, args.template)
        if args.command == "index":
            return do_index()
        if args.command == "params":
            return do_params(args.template)
    except (ValueError, FileNotFoundError, FileExistsError, OSError, RuntimeError, UnicodeError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 2

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
