"""CLI entry point for Resume.

Invoke via `python -m resume` or the installed `resume` console script.
"""

from __future__ import annotations

import sys


def main(argv: list[str] | None = None) -> int:
    """Program entry. Return process exit code."""
    args = list(sys.argv[1:] if argv is None else argv)

    if not args or args[0] in {"-h", "--help"}:
        print("Resume — TODO: implement CLI")
        print("")
        print("Usage:")
        print("  resume [command] [args...]")
        return 0

    # TODO: dispatch on args[0]
    print(f"TODO: implement command {args[0]!r}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
