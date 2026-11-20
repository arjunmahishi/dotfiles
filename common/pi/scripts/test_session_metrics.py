import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


class SessionMetricsTest(unittest.TestCase):
    def test_branch_time_and_model_cost(self):
        def timestamp(second):
            return f'2026-01-01T00:00:{second:02d}.000Z'

        def assistant(model, cost, tool_call=False):
            return dict(role='assistant', model=model, usage={'cost': {'total': cost}},
                        content=[{'type': 'toolCall' if tool_call else 'text'}])

        user = {'role': 'user'}
        result = {'role': 'toolResult'}
        entries = [{'type': 'session', 'timestamp': timestamp(0)}]
        for index, (second, parent, message) in enumerate([
            (2, None, user),
            (4, 0, assistant('model-a', 0.004, tool_call=True)),
            (6, 1, result),
            (7, 2, user),  # Queued while the agent was still running.
            (8, 3, result),
            (10, 4, assistant('model-a', 0.004)),
            (13, 5, user),
            (16, 6, assistant('abandoned', 1)),
            (18, 6, assistant('model-b', 0.021)),
        ]):
            entries.append(dict(type='message', id=str(index), timestamp=timestamp(second),
                                parentId=None if parent is None else str(parent), message=message))

        script = Path(__file__).with_name('session-metrics.py')
        with tempfile.TemporaryDirectory() as directory:
            log = Path(directory) / 'sessions' / 'project' / 'timestamp_test-id.jsonl'
            log.parent.mkdir(parents=True)
            log.write_text('\n'.join(map(json.dumps, entries)), encoding='utf-8')
            env = dict(os.environ, PI_SESSION_FILE=str(log), PI_CODING_AGENT_DIR=directory)
            for args in ([], ['test-id'], ['--session-file', str(log)]):
                with self.subTest(args=args):
                    output = subprocess.check_output([sys.executable, str(script), *args], env=env, text=True)
                    self.assertEqual(
                        output.strip(),
                        'Human time: 0m 05s · Agent time: 0m 13s · Total cost: $0.03 '
                        '(model-a: $0.01, model-b: $0.02)',
                    )


if __name__ == '__main__':
    unittest.main()
