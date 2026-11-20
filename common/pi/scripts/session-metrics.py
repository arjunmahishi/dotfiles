#!/usr/bin/env python3
"""Print a PR-ready summary of time and logged model costs for a Pi session."""

import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from decimal import Decimal
from pathlib import Path


def session_path(session_id):
    if session_id is None:
        if path := os.environ.get('PI_SESSION_FILE'):
            return Path(path)
        raise ValueError('No active Pi session file; pass an exact session ID.')
    if not session_id or not all(c.isascii() and (c.isalnum() or c == '-') for c in session_id):
        raise ValueError('Pass an exact session ID, not a path.')
    root = Path(os.environ.get('PI_CODING_AGENT_DIR') or '~/.pi/agent').expanduser()
    matches = list((root / 'sessions').rglob(f'*_{session_id}.jsonl'))
    if len(matches) != 1:
        raise ValueError(f'Expected one session file for {session_id}; found {len(matches)}.')
    return matches[0]


def duration(value):
    minutes, seconds = divmod((value + timedelta(milliseconds=500)) // timedelta(seconds=1), 60)
    return f'{minutes}m {seconds:02d}s'


def summarize(entries):
    if not entries or entries[0]['type'] != 'session':
        raise ValueError('Missing Pi session header.')
    # Follow the newest entry's ancestry, not messages from abandoned branches.
    by_id = {entry['id']: entry for entry in entries[1:]}
    branch = []
    entry = entries[-1] if by_id else None
    while entry is not None:
        branch.append(entry)
        parent = entry['parentId']
        entry = by_id.pop(parent) if parent is not None else None

    previous = datetime.fromisoformat(entries[0]['timestamp'])
    elapsed = {False: timedelta(), True: timedelta()}
    # shortcut: elapsed gaps include pauses; use lifecycle events if active time is needed.
    active = False
    costs = defaultdict(Decimal)
    for entry in reversed(branch):
        if entry['type'] != 'message':
            continue
        message = entry['message']
        role = message['role']
        if role not in ('user', 'assistant', 'toolResult'):
            continue
        timestamp = datetime.fromisoformat(entry['timestamp'])
        if timestamp < previous:
            raise ValueError('Session timestamps are out of order.')
        elapsed[active] += timestamp - previous
        previous = timestamp
        if role == 'user':
            active = True
        elif role == 'assistant':
            costs[message['model']] += message['usage']['cost']['total']
            active = message.get('stopReason') == 'toolUse' or any(
                block['type'] == 'toolCall' for block in message['content']
            )

    split = ', '.join(f'{model}: ${cost:.2f}' for model, cost in sorted(costs.items())) or 'no model calls'
    return (f'Human time: {duration(elapsed[False])} · Agent time: {duration(elapsed[True])}'
            f' · Total cost: ${sum(costs.values()):.2f} ({split})')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group()
    source.add_argument('session_id', nargs='?', help='exact Pi session ID (default: $PI_SESSION_FILE)')
    source.add_argument('--session-file', type=Path, help='path to a Pi session log')
    args = parser.parse_args()
    try:
        with (args.session_file or session_path(args.session_id)).open(encoding='utf-8') as log:
            print(summarize([json.loads(line, parse_float=Decimal) for line in log if line.strip()]))
    except (OSError, ValueError, KeyError) as error:
        sys.exit(f'session-metrics: {error}')


if __name__ == '__main__':
    main()
