#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
import_kaikki.py — Full-dictionary importer for Lingua+ from Kaikki/Wiktextract.

The bundled seed dictionary (assets/data/dictionary.json, ~3.3k words) covers
the most frequent vocabulary. This script lets you expand the offline DB to
the FULL English Wiktionary dump with Persian translations, IPA (US/UK),
glosses, examples, synonyms and antonyms.

USAGE
-----
1) Download the English subset of Kaikki (about 2 GB):
     https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl

2) Run:
     python3 scripts/import_kaikki.py \
         --input ~/Downloads/kaikki.org-dictionary-English.jsonl \
         --output assets/data/dictionary_full.json \
         --max-words 50000

3) Either replace assets/data/dictionary.json with the output (then rebuild
   the app so the bundle contains it), or ship dictionary_full.json as a
   second asset and feed it to IsarDatabase.seedDictionary(isar, jsonText).

NOTES
-----
- Output format matches lib/data/models/mappers.dart exactly.
- Persian definitions come from Wiktionary `translations` with lang code
  fa/fas/fa-IR; entries without any Persian translation are skipped unless
  --keep-en is passed (then the English gloss is used as the definition).
- Frequency rank/level via wordfreq (same bands as the seed builder).
"""
import argparse
import io
import json
import os
import sys

POS_MAP = {
    "noun": "noun",
    "verb": "verb",
    "adj": "adjective",
    "adv": "adverb",
    "prep": "preposition",
    "conjunction": "conjunction",
    "pron": "pronoun",
    "interjection": "interjection",
    "det": "determiner",
    "num": "numeral",
    "name": "noun",
    "phrase": "phrase",
    "prep_phrase": "phrase",
    "proverb": "phrase",
    "particle": "phrase",
}

FA_CODES = {"fa", "fas", "fa-IR", "pes"}

BANDS = [(300, "A1"), (800, "A2"), (1600, "B1"), (3000, "B2"), (5000, "C1")]


def freq_rank():
    try:
        from wordfreq import top_n_list
        top = top_n_list("en", 8000)
        return {w: i + 1 for i, w in enumerate(top)}
    except Exception:
        return {}


def level_for(rank):
    if rank == 999999:
        return ""
    for cap, lv in BANDS:
        if rank <= cap:
            return lv
    return "C2"


def extract_ipa(sounds):
    us, uk = "", ""
    for s in sounds or []:
        ipa = s.get("ipa", "")
        if not ipa:
            continue
        tags = set(s.get("tags", []) or [])
        if {"US", "American"} & tags and not us:
            us = ipa
        elif {"UK", "British"} & tags and not uk:
            uk = ipa
        elif not us:
            us = ipa
    return us, uk


def fa_from_translations(translations):
    out = []
    for t in translations or []:
        code = t.get("code", "") or t.get("lang", "")
        if code in FA_CODES or code.startswith("fa"):
            word = (t.get("word") or "").strip()
            if word and word not in out:
                out.append(word)
    return out[:3]


def iter_jsonl(path):
    with io.open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--input", required=True, help="Kaikki English .jsonl")
    ap.add_argument("--output", required=True, help="output .json path")
    ap.add_argument("--max-words", type=int, default=50000)
    ap.add_argument("--keep-en", action="store_true",
                    help="keep entries without Persian translation")
    args = ap.parse_args()

    rank_map = freq_rank()

    # word -> {pos -> {glosses, examples, syn, ant}}
    words = {}
    ipas = {}  # word -> [us, uk]

    n = 0
    for entry in iter_jsonl(args.input):
        n += 1
        if (entry.get("lang_code") or entry.get("lang")) != "en":
            continue
        word = (entry.get("word") or "").strip()
        pos_raw = entry.get("pos", "")
        pos = POS_MAP.get(pos_raw)
        if not word or not pos or not re.match(r"^[A-Za-z][A-Za-z'’\-]*$", word):
            continue

        wl = word.lower()
        # IPA (collect once per word)
        us, uk = extract_ipa(entry.get("sounds"))
        if us or uk:
            cur = ipas.get(wl, ["", ""])
            if not cur[0] and us:
                cur[0] = us
            if not cur[1] and uk:
                cur[1] = uk
            ipas[wl] = cur

        bucket = words.setdefault(wl, {})

        senses = entry.get("senses") or []
        glosses, examples, syn, ant = [], [], [], []
        for s in senses:
            gl = s.get("glosses") or []
            if gl:
                g = gl[0]
                if len(g) > 160:
                    g = g[:157] + "..."
                if g not in glosses:
                    glosses.append(g)
            for ex in (s.get("examples") or [])[:2]:
                txt = (ex.get("text") or "").strip()
                if txt and txt not in examples:
                    examples.append(txt)
                tr = (ex.get("translation") or "").strip() if ex.get("translation") else ""
                if tr and (txt, tr) not in examples:
                    examples.append((txt, tr)) if False else None
            for s_syn in (s.get("synonyms") or [])[:3]:
                w = (s_syn.get("word") or "").strip()
                if w and w.lower() != wl and w not in syn:
                    syn.append(w)
            for s_ant in (s.get("antonyms") or [])[:3]:
                w = (s_ant.get("word") or "").strip()
                if w and w.lower() != wl and w not in ant:
                    ant.append(w)

        # Persian meaning from word-level translations
        fa = fa_from_translations(entry.get("translations"))

        entry_data = bucket.setdefault(pos, {
            "glosses": [], "examples": [], "syn": set(), "ant": set(), "fa": [],
        })
        for g in glosses:
            if g not in entry_data["glosses"] and len(entry_data["glosses"]) < 4:
                entry_data["glosses"].append(g)
        for e in examples:
            if len(entry_data["examples"]) < 3:
                entry_data["examples"].append(e)
        for s_ in syn:
            entry_data["syn"].add(s_)
        for a_ in ant:
            entry_data["ant"].add(a_)
        for f_ in fa:
            if f_ not in entry_data["fa"]:
                entry_data["fa"].append(f_)

        if n % 500000 == 0:
            print(f"  ...read {n} lines, {len(words)} words so far", file=sys.stderr)

    print(f"parsed {n} lines -> {len(words)} unique words", file=sys.stderr)

    # Build output entries
    out_entries = []
    for wl in sorted(words, key=lambda w: rank_map.get(w, 999999)):
        if len(out_entries) >= args.max_words:
            break
        bucket = words[wl]

        meanings = []
        has_fa = False
        for pos, data in bucket.items():
            defs = list(data["fa"])
            if defs:
                has_fa = True
            elif args.keep_en and data["glosses"]:
                defs = data["glosses"][:2]
            if defs:
                meanings.append({"pos": pos, "definitions": defs})

        if not meanings:
            continue  # nothing useful (no fa and no gloss usage)

        examples = []
        for pos, data in bucket.items():
            for e in data["examples"]:
                if isinstance(e, tuple):
                    en, fa_tr = e
                else:
                    en, fa_tr = e, ""
                if en and len(examples) < 4:
                    examples.append({"en": en, "fa": fa_tr})

        r = rank_map.get(wl, 999999)
        ipa_us, ipa_uk = ipas.get(wl, ["", ""])
        syn = sorted({s for d in bucket.values() for s in d["syn"]})[:6]
        ant = sorted({a for d in bucket.values() for a in d["ant"]})[:6]

        # Primary pos: pick the first bucket deterministically (noun > verb > adj ...)
        order = ["noun", "verb", "adjective", "adverb", "preposition",
                 "conjunction", "pronoun", "interjection", "determiner",
                 "numeral", "phrase"]
        primary = next((p for p in order if p in bucket), list(bucket)[0])

        out_entries.append({
            "word": wl,
            "display": wl,
            "pos": primary,
            "meanings": meanings,
            "examples": examples,
            "synonyms": syn,
            "antonyms": ant,
            "ipaUs": ipa_us,
            "ipaUk": ipa_uk,
            "level": level_for(r),
            "rank": r,
            "source": "kaikki",
        })

    out_entries.sort(key=lambda e: e["rank"])
    with io.open(args.output, "w", encoding="utf-8") as f:
        json.dump(out_entries, f, ensure_ascii=False, separators=(",", ":"))

    with_fa = sum(1 for e in out_entries if any(
        d["definitions"] for d in e["meanings"]))
    print(f"entries written: {len(out_entries)}")
    print(f"entries with definitions: {with_fa}")
    print(f"output: {args.output}")


if __name__ == "__main__":
    sys.exit(main())
