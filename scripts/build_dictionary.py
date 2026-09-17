#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_dictionary.py — Builds assets/data/dictionary.json for Lingua+.

Sources:
  1. scripts/data_work/vocab_core.txt  — curated "word|pos|fa" lines
  2. ipa-dict (open-dict-data) en_US.txt / en_UK.txt — British/American IPA
  3. wordfreq — frequency rank + CEFR level bands

Output entry format (consumed by lib/data/models/mappers.dart):
  { word, display, pos, meanings:[{pos, definitions:[fa,...]}],
    examples:[{en, fa}], synonyms:[], antonyms:[], ipaUs, ipaUk,
    level, rank, source:"seed" }
"""
import io
import json
import os
import re
import sys

DATA_DIR = os.path.join(os.path.dirname(__file__), "data_work")
OUT_PATH = os.path.join(
    os.path.dirname(__file__), "..", "lingua_plus", "assets", "data", "dictionary.json"
)

POS_ALLOWED = {
    "noun", "verb", "adjective", "adverb", "preposition", "conjunction",
    "pronoun", "interjection", "determiner", "numeral", "phrase",
}

# CEFR bands by frequency rank
BANDS = [(300, "A1"), (800, "A2"), (1600, "B1"), (3000, "B2"), (5000, "C1")]


def load_freq():
    from wordfreq import top_n_list
    top = top_n_list("en", 8000)
    rank = {w: i + 1 for i, w in enumerate(top)}
    return rank


def load_ipa():
    """Returns (us: dict, uk: dict) mapping lowercase word -> first IPA."""
    def read(path):
        d = {}
        if not os.path.exists(path):
            return d
        with io.open(path, encoding="utf-8") as f:
            for line in f:
                line = line.rstrip("\n")
                if not line or "\t" not in line:
                    continue
                w, ipas = line.split("\t", 1)
                w = w.strip().lower()
                ipas = ipas.strip().strip("/").split(",")
                first = ipas[0].strip().strip("/") if ipas else ""
                first = first.split("/")[0].strip()
                if w and first and w not in d:
                    d[w] = first
        return d

    us = read(os.path.join(DATA_DIR, "en_US.txt"))
    uk = read(os.path.join(DATA_DIR, "en_UK.txt"))
    return us, uk


def example_for(word, pos, fa):
    """Template-based bilingual example (grammatical for every word)."""
    w = word
    if pos == "noun":
        en = f"The {w} is very important here."
        fa = f"اینجا {fa} خیلی مهم است."
    elif pos == "verb":
        en = f"I want to {w}."
        fa = f"یعنی {fa}."
    elif pos == "adjective":
        en = f"It looks {w} today."
        fa = f"امروز به نظر {fa} می‌رسد."
    elif pos == "adverb":
        en = f"He did it {w}."
        fa = f"او این کار را {fa} انجام داد."
    else:
        en = f"Try to use \"{w}\" in a sentence."
        fa = f"سعی کن در یک جمله از \"{fa}\" استفاده کنی."
    return {"en": en, "fa": fa}


def main():
    rank_map = load_freq()
    ipa_us, ipa_uk = load_ipa()

    vocab_paths = [
        os.path.join(DATA_DIR, "vocab_core.txt"),
        os.path.join(DATA_DIR, "vocab_function.txt"),
    ]
    entries = []
    seen = set()
    skipped = 0

    lines = []
    for vp in vocab_paths:
        if os.path.exists(vp):
            with io.open(vp, encoding="utf-8") as f:
                lines.extend(f.readlines())

    for raw in lines:
            line = raw.strip()
            if not line or line.startswith("#") or "|" not in line:
                continue
            parts = [p.strip() for p in line.split("|")]
            if len(parts) < 3:
                skipped += 1
                continue
            word, pos, fa = parts[0].lower(), parts[1].lower(), parts[2]
            if pos not in POS_ALLOWED or not re.match(r"^[a-z][a-z'’\- ]*$", word):
                skipped += 1
                continue
            if word in seen:
                skipped += 1
                continue
            seen.add(word)

            r = rank_map.get(word, 999999)
            level = ""
            for cap, lv in BANDS:
                if r <= cap:
                    level = lv
                    break
            if not level and r != 999999:
                level = "C2"

            entries.append({
                "word": word,
                "display": parts[0].strip(),
                "pos": pos,
                "meanings": [{"pos": pos, "definitions": [fa]}],
                "examples": [example_for(word, pos, fa)],
                "synonyms": [],
                "antonyms": [],
                "ipaUs": ipa_us.get(word, ""),
                "ipaUk": ipa_uk.get(word, ""),
                "level": level,
                "rank": r,
                "source": "seed",
            })

    entries.sort(key=lambda e: e["rank"])

    out = os.path.abspath(OUT_PATH)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with io.open(out, "w", encoding="utf-8") as f:
        json.dump(entries, f, ensure_ascii=False, separators=(",", ":"))

    with_ipa = sum(1 for e in entries if e["ipaUs"] or e["ipaUk"])
    with_level = sum(1 for e in entries if e["level"])
    print(f"entries written: {len(entries)}")
    print(f"with IPA: {with_ipa}")
    print(f"with CEFR level: {with_level}")
    print(f"skipped lines: {skipped}")
    print(f"output: {out}")
    print(f"size: {os.path.getsize(out) / 1024:.0f} KB")


if __name__ == "__main__":
    sys.exit(main())
