#!/usr/bin/env python3
"""Show the current OpenRouter credit balance in the macOS menu bar."""

from __future__ import annotations

import json
import sys
import threading
from decimal import Decimal, InvalidOperation
from pathlib import Path
from urllib.request import Request, urlopen

import rumps
from AppKit import (
    NSApplication,
    NSApplicationActivationPolicyAccessory,
    NSColor,
    NSForegroundColorAttributeName,
)
from Foundation import NSAttributedString
from PyObjCTools import AppHelper


API_URL = "https://openrouter.ai/api/v1/credits"
TOKEN_PATH = Path.home() / "tokens" / "openrouter"
REFRESH_INTERVAL_SECONDS = 5 * 60
REQUEST_TIMEOUT_SECONDS = 10
BLACK = NSColor.blackColor()


def read_api_token(path: Path = TOKEN_PATH) -> str:
    """Read and validate the OpenRouter API token."""
    try:
        token = path.read_text(encoding="utf-8").strip()
    except OSError as error:
        raise RuntimeError(f"could not read OpenRouter token from {path}") from error

    if not token:
        raise RuntimeError(f"OpenRouter token file is empty: {path}")

    return token


def _decimal_value(value: object, field: str) -> Decimal:
    if value is None or isinstance(value, bool):
        raise ValueError(f"OpenRouter response field {field!r} is not a number")

    try:
        return Decimal(str(value))
    except (InvalidOperation, TypeError, ValueError) as error:
        raise ValueError(f"OpenRouter response field {field!r} is not a number") from error


def fetch_balance(token: str) -> Decimal:
    """Fetch the remaining OpenRouter credits."""
    request = Request(
        API_URL,
        headers={
            "Accept": "application/json",
            "Authorization": f"Bearer {token}",
        },
    )

    with urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:
        payload = json.load(response, parse_float=Decimal)

    try:
        data = payload["data"]
        total_credits = _decimal_value(data["total_credits"], "total_credits")
        total_usage = _decimal_value(data["total_usage"], "total_usage")
    except (KeyError, TypeError) as error:
        raise ValueError("OpenRouter response did not contain credit totals") from error

    return total_credits - total_usage


def format_balance(balance: Decimal) -> str:
    return f"${balance:.2f}"


class BalanceApp(rumps.App):
    def __init__(self) -> None:
        super().__init__("OpenRouter", title="...", menu=["Refresh"])
        self._refresh_lock = threading.Lock()
        self._refresh_in_progress = False

    @rumps.clicked("Refresh")
    def refresh(self, _sender: object) -> None:
        self._start_refresh()

    @rumps.timer(REFRESH_INTERVAL_SECONDS)
    def refresh_timer(self, _timer: object) -> None:
        self._start_refresh()

    def run(self, **options: object) -> None:
        rumps.events.before_start.register(self._refresh_on_start)
        NSApplication.sharedApplication().setActivationPolicy_(
            NSApplicationActivationPolicyAccessory
        )
        super().run(**options)

    def _refresh_on_start(self) -> None:
        self._start_refresh()

    def _start_refresh(self) -> None:
        with self._refresh_lock:
            if self._refresh_in_progress:
                return
            self._refresh_in_progress = True

        threading.Thread(target=self._refresh_in_background, daemon=True).start()

    def _refresh_in_background(self) -> None:
        try:
            balance = fetch_balance(read_api_token())
        except Exception as error:
            print(f"OpenRouter balance refresh failed: {error}", file=sys.stderr)
            AppHelper.callAfter(self._show_error)
        else:
            AppHelper.callAfter(self._show_balance, balance)
        finally:
            with self._refresh_lock:
                self._refresh_in_progress = False

    def _show_balance(self, balance: Decimal) -> None:
        self._set_status(format_balance(balance))

    def _show_error(self) -> None:
        self._set_status("ERR")

    def _set_status(self, title: str) -> None:
        self.title = title
        attributed_title = NSAttributedString.alloc().initWithString_attributes_(
            title,
            {NSForegroundColorAttributeName: BLACK},
        )
        self._nsapp.nsstatusitem.button().setAttributedTitle_(attributed_title)


if __name__ == "__main__":
    BalanceApp().run()
