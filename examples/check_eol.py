#!/usr/bin/env python3
"""Exit 1 if anything in your stack has reached end of life. Standard library only.

Usage:
    python3 check_eol.py php:8.3.20 nodejs:24.1.0 ubuntu:22.04

Product names are the ones in latestat.com URLs (latestat.com/php -> php).
"""
import json
import sys
import urllib.parse
import urllib.request


def main(args: list[str]) -> int:
    if not args:
        print(__doc__, file=sys.stderr)
        return 2
    url = "https://latestat.com/api/stack.json?s=" + urllib.parse.quote(",".join(args), safe=":,")
    req = urllib.request.Request(url, headers={"User-Agent": "check_eol.py"})
    with urllib.request.urlopen(req, timeout=20) as r:
        report = json.load(r)

    for item in report["items"]:
        name = f"{item['product']} {item['version']}" if item.get("product") else item.get("input")
        print(f"{(item.get('status') or item.get('state') or '?'):<9} {name}: {item['message']}")
    print(f"\nGrade: {report['grade']}  ->  {report['url']}")

    if report["summary"]["eol"]:
        print(f"{report['summary']['eol']} item(s) have reached end of life.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
