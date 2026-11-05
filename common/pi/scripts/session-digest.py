#!/usr/bin/env python3
"""Digest Pi sessions for a project: tool/error stats plus every user message.

Usage: session-digest.py <project-cwd> <out-dir> [since YYYY-MM-DD]
Writes <out-dir>/users.txt and <out-dir>/errors.json; prints stats.
"""
import collections, glob, json, os, sys

cwd, out = os.path.abspath(sys.argv[1]), sys.argv[2]
since = sys.argv[3] if len(sys.argv) > 3 else ''
d = os.path.expanduser('~/.pi/agent/sessions/--' + cwd.strip('/').replace('/', '-') + '--')
files = sorted(f for f in glob.glob(d + '/*.jsonl') if os.path.basename(f)[:10] >= since)
if not files:
    sys.exit(f'no sessions in {d} since {since or "the beginning"}')
os.makedirs(out, exist_ok=True)

tools, errs, skills, bash = (collections.Counter() for _ in range(4))
errsamp = collections.defaultdict(list)
nusers = ntools = 0
with open(os.path.join(out, 'users.txt'), 'w') as w:
    for f in files:
        users, nt, ne = [], 0, 0
        for line in open(f):
            try:
                e = json.loads(line)
            except json.JSONDecodeError:
                continue
            if e.get('type') != 'message':
                continue
            m = e['message']
            c = m.get('content') or []
            if isinstance(c, str):
                c = [{'type': 'text', 'text': c}]
            role = m.get('role')
            if role == 'user':
                t = ' '.join(x.get('text', '') for x in c if x.get('type') == 'text').strip()
                if t:
                    users.append(t)
            elif role == 'assistant':
                for x in c:
                    if x.get('type') != 'toolCall':
                        continue
                    n, a = x.get('name'), x.get('arguments') or {}
                    tools[n] += 1; nt += 1
                    if n == 'bash' and a.get('command', '').split():
                        p = a['command'].split()
                        bash[' '.join(p[:2]) if p[0] in ('jj', 'git', 'gh', 'go', 'kubectl', 'tilt', 'make') else p[0]] += 1
                    if n == 'read' and a.get('path', '').endswith('SKILL.md'):
                        skills[a['path'].split('/')[-2]] += 1
            elif role == 'toolResult' and m.get('isError'):
                n = m.get('toolName'); errs[n] += 1; ne += 1
                errsamp[n].append(' '.join(x.get('text', '') for x in c if x.get('type') == 'text')[:200].replace('\n', ' '))
        nusers += len(users); ntools += nt
        w.write(f'\n===== {os.path.basename(f)[:-6]} | users={len(users)} tools={nt} errs={ne}\n')
        w.writelines(f'[{i}] {u[:700]}\n' for i, u in enumerate(users))
json.dump({k: v[:40] for k, v in errsamp.items()}, open(os.path.join(out, 'errors.json'), 'w'), indent=0)
print(f'sessions={len(files)} user_msgs={nusers} tool_calls={ntools} range={os.path.basename(files[0])[:10]}..{os.path.basename(files[-1])[:10]}')
for name, ctr in [('tools', tools), ('errors', errs), ('skills', skills), ('bash', bash)]:
    print(name, ctr.most_common(30))
