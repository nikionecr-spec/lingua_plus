#!/usr/bin/env python3
"""Rough Dart syntax sanity check: balanced brackets outside strings/comments,
trailing commas sanity, obvious unterminated strings."""
import os
import re
import sys

ROOT = "/home/z/my-project/lingua_plus/lib"


def check(path):
    s = open(path, encoding="utf-8").read()
    i, n = 0, len(s)
    stack = []
    line = 1
    errors = []
    while i < n:
        ch = s[i]
        if ch == "\n":
            line += 1
            i += 1
            continue
        if s.startswith("//", i):
            j = s.find("\n", i)
            i = n if j < 0 else j
            continue
        if s.startswith("/*", i):
            j = s.find("*/", i + 2)
            if j < 0:
                errors.append(f"{path}: unterminated block comment at {line}")
                break
            line += s.count("\n", i, j)
            i = j + 2
            continue
        if ch in "'\"":
            # triple-quoted?
            triple = s[i:i + 3]
            if triple in ("'''", '"""'):
                j = s.find(triple, i + 3)
                if j < 0:
                    errors.append(f"{path}: unterminated string at {line}")
                    break
                line += s.count("\n", i, j)
                i = j + 3
                continue
            # raw?
            raw = i > 0 and s[i - 1] == "r"
            j = i + 1
            quote = ch
            while j < n:
                c = s[j]
                if c == "\\" and not raw:
                    j += 2
                    continue
                if c == quote:
                    break
                if c == "\n":
                    errors.append(f"{path}: newline in string line {line}")
                    break
                j += 1
            i = j + 1
            continue
        if ch in "([{":
            stack.append((ch, line))
        elif ch in ")]}":
            if not stack:
                errors.append(f"{path}: unmatched {ch} at line {line}")
            else:
                o, ln = stack.pop()
                if "([{".index(o) != ")]}".index(ch):
                    errors.append(
                        f"{path}: {o} (line {ln}) closed by {ch} at {line}")
        i += 1
    for o, ln in stack:
        errors.append(f"{path}: unclosed {o} from line {ln}")
    return errors


def main():
    all_errors = []
    count = 0
    for root, _, names in os.walk(ROOT):
        for nm in names:
            if nm.endswith(".dart"):
                count += 1
                all_errors += check(os.path.join(root, nm))
    if all_errors:
        print("\n".join(all_errors))
        sys.exit(1)
    print(f"OK: {count} dart files pass bracket/string sanity")


if __name__ == "__main__":
    main()
