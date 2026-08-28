# ruff: noqa: UP031
# This file is a VENDORED generator: one upstream copy is swept into every CH repo, so it meets
# a different lint config in each one. Its style is owned upstream, not by the host repo - the
# same reason vendored code is normally excluded from a project's lint scope. UP031 is the only
# rule exempted, and only because printf-style width specifiers (%.1f) are what keep the SVG
# coordinate maths readable; every other ruff rule is satisfied. Verified against .CH-App's
# config on 2026-08-28, whose own src/ passes clean - the 29 findings there were all mine.
"""build-project-atlas.py - a README-embeddable atlas for ANY CH project, generated from the repo.

Purpose
  Give every project the same treatment the Brain has: one honest, self-refreshing picture of what
  the repo actually contains. Portable by design - it reads only what the D-018 standard made
  universal (AGENTS.md, PROJECT_ARTIFACT.md, DECK.md, git history, tracked source) and degrades
  gracefully when the optional parts (STATUS.md, session ledger, a Brain pack) are absent.
When to use
  In any `CH-*` repo, after a meaningful change, and in CI/pre-push if the repo has one. Emits SVG
  for the README plus a JSON sidecar so a figure can be checked without opening a picture.
When NOT to use
  As a source of truth - it is DERIVED (D-009 R6). And not as a progress badge to wave: the
  substance meter is deliberately unflattering, because the metrics law outranks looking finished
  (ARTIFACT_POLICY Amendment C).
Inputs   --repo <path> (default: cwd) · --out <dir> (default: <repo>/docs) · --brain <path>
         (optional; enriches the one-liner from the project's knowledge pack)
Outputs  <out>/atlas.svg, <out>/atlas-dark.svg, <out>/atlas.json  - no script, no CSS, no web
         fonts, no external refs, so GitHub renders them in a README via <picture>.
Example  python build-project-atlas.py --repo "D:\\.CH Project\\.CH-Monetize"
Dependencies  Python >= 3.9 stdlib, and `git` on PATH for history/tracked files.
Known limitations
  - The substance meter reports PROJECT-SPECIFIC content: lines in the artifact + deck that are
    neither identical to the template baseline nor carrying a placeholder marker. It measures whether
    the record was WRITTEN, never whether the project is good - a thoroughly-documented failure scores
    high, correctly. Where no template is reachable it falls back to placeholder-counting and labels
    itself so on the page, because that mode is measurably more generous (a fresh scaffold scored 78%
    under it and 4% against the real baseline).
  - Language bytes are `git ls-tree` blob sizes with the same generated/vendored exclusions the
    Brain's signature uses; bytes favour verbose languages. Composition, not authorship.
  - Commit cadence is a 12-week window; a repo older than that shows only its recent shape.
  - OWNERSHIP (L-024): the atlas belongs to the repo it lives in. One machine regenerates it - the
    other may run this to a scratch --out and report, never write.
Provenance
  CH-Claude-Persistent-Brain scripts/07-visualize, 2026-08-28. Generalises build-brain-map.py after
  the owner asked whether every project could have one. Measured first: 19/19 CH repos carry
  AGENTS.md + PROJECT_ARTIFACT.md + DECK.md + a Brain pack, so those are the only hard dependencies.
"""

import argparse
import collections
import datetime
import html
import json
import os
import re
import subprocess
import sys

PLACEHOLDER = re.compile(
    r"(TODO|TBD|not measured|<sha>|YYYY-MM-DD|lorem ipsum|FIXME|\bxxx\b|placeholder)", re.I
)

LANG_BY_EXT = {
    "py": "Python",
    "pyw": "Python",
    "ps1": "PowerShell",
    "psm1": "PowerShell",
    "psd1": "PowerShell",
    "pine": "Pine Script",
    "ts": "TypeScript",
    "tsx": "TypeScript",
    "js": "JavaScript",
    "jsx": "JavaScript",
    "mjs": "JavaScript",
    "cjs": "JavaScript",
    "cs": "C#",
    "sh": "Shell",
    "bash": "Shell",
    "cmd": "Batch",
    "bat": "Batch",
    "html": "HTML",
    "htm": "HTML",
    "css": "CSS",
    "scss": "CSS",
    "vue": "Vue",
    "sql": "SQL",
    "rs": "Rust",
    "go": "Go",
    "java": "Java",
    "rb": "Ruby",
    "php": "PHP",
    "c": "C",
    "h": "C",
    "cpp": "C++",
    "swift": "Swift",
    "r": "R",
    "lua": "Lua",
    "kt": "Kotlin",
    "dockerfile": "Dockerfile",
    "ipynb": "Jupyter",
}
LANG_COLORS = {
    "Python": "#3572A5",
    "JavaScript": "#f1e05a",
    "PowerShell": "#012456",
    "TypeScript": "#3178c6",
    "Pine Script": "#00a99d",
    "C#": "#178600",
    "Shell": "#89e051",
    "HTML": "#e34c26",
    "CSS": "#563d7c",
    "Batch": "#C1F12E",
    "SQL": "#e38c00",
    "Rust": "#dea584",
    "Go": "#00ADD8",
    "Vue": "#41b883",
    "Java": "#b07219",
    "Dockerfile": "#384d54",
    "Jupyter": "#DA5B0B",
    "Other": "#8b949e",
}
GENERATED = (
    "/node_modules/",
    "/dist/",
    "/build/",
    "/.venv/",
    "/venv/",
    "/vendor/",
    "/libs/",
    "/site-packages/",
    "/__pycache__/",
    "/.next/",
    "/coverage/",
    "/outputs/",
    "/assets-source/",
    "/wwwroot/lib/",
    "/static/vendor/",
    ".min.",
    "-lock.",
    "package-lock",
    "yarn.lock",
)
OVERSIZE = 300 * 1024

THEME = {
    "light": {
        "ground": "#F7F8FA",
        "panel": "#FFFFFF",
        "ink": "#12161C",
        "ink2": "#3D4754",
        "ink3": "#6B7789",
        "rule": "#DCE2EA",
        "accent": "#0E7C86",
        "good": "#0F7B4F",
        "warn": "#9A6B00",
        "gap": "#C2410C",
        "track": "#E7ECF2",
    },
    "dark": {
        "ground": "#0E1116",
        "panel": "#161B22",
        "ink": "#E8EDF4",
        "ink2": "#AFBACA",
        "ink3": "#7C8798",
        "rule": "#242C36",
        "accent": "#4DD0C7",
        "good": "#4ADE9B",
        "warn": "#E3B341",
        "gap": "#E0894F",
        "track": "#1D242D",
    },
}
SANS = "ui-sans-serif,Segoe UI,system-ui,-apple-system,sans-serif"
MONO = "ui-monospace,SFMono-Regular,Consolas,monospace"


def sh(args, cwd, default=""):
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=90)
        return r.stdout if r.returncode == 0 else default
    except Exception:
        return default


def read(path, default=""):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return default


def substance(text, baseline=None):
    """How much of this record is about THIS project, versus still the scaffold it was cloned from.

    Calibration note (2026-08-28): the first cut counted "lines without a TODO marker" as filled,
    which scored a freshly-scaffolded repo at 78% - because a template's boilerplate prose carries no
    TODO. Measured against the real template, that repo's artifact was 66 of 71 lines IDENTICAL to
    the scaffold: ~7% its own. Counting boilerplate as content is the flattering-figure failure the
    metrics law exists to prevent, so the measure now diffs against the template baseline when one is
    reachable and falls back (labelled) to placeholder-counting when it is not."""
    lines = [
        ln.strip()
        for ln in text.splitlines()
        if ln.strip() and not ln.lstrip().startswith(("---", "```", "|---"))
    ]
    if not lines:
        return 0, 0
    if baseline:
        boiler = {ln.strip() for ln in baseline.splitlines() if ln.strip()}
        own = [ln for ln in lines if ln not in boiler and not PLACEHOLDER.search(ln)]
        return len(own), len(lines) - len(own)
    holes = sum(1 for ln in lines if PLACEHOLDER.search(ln))
    return len(lines) - holes, holes


def collect(repo, brain=None):
    d = {"name": os.path.basename(repo.rstrip("\\/")).lstrip("."), "repo": repo}

    # identity: prefer the Brain pack's one-liner, else the README's first prose line
    one = ""
    if brain:
        pack = read(os.path.join(brain, "PROJECTS", d["name"], "PROJECT.md"))
        for line in pack.splitlines():
            if line.startswith(">") and len(line.strip()) > 4:
                one = line.lstrip("> ").strip()
                break
    if not one:
        for line in read(os.path.join(repo, "README.md")).splitlines():
            t = line.strip()
            if t and not t.startswith(("#", "[", "<", "!", "-", "|", ">")):
                one = t
                break
    d["one"] = re.sub(r"\s+", " ", one)[:150]

    # the D-018 standard set (universal across the estate, measured 2026-08-28)
    art = read(os.path.join(repo, "PROJECT_ARTIFACT.md"))
    deck = read(os.path.join(repo, "DECK.md")) or read(
        os.path.join(repo, "docs", "01-session", "DECK.md")
    )
    agents = read(os.path.join(repo, "AGENTS.md"))
    status = read(os.path.join(repo, "STATUS.md"))
    # Template baseline: the scaffold these files were cloned from. Looked for as a sibling of the
    # repo, so this stays portable - absent is fine, the measure just says which mode it used.
    # r"\/" not "\/": the latter is an INVALID escape. Python 3.14 emits
    # SyntaxWarning: '"\/" is an invalid escape sequence ... will not work in the future'
    # and prints this source line on every run - which leaked into the atlas output that
    # sent PC2 looking for a stray debug print. It strips both characters today by accident,
    # so the behaviour is unchanged; only the warning and the future SyntaxError go away.
    tpl_root = os.path.join(
        os.path.dirname(repo.rstrip(r"\/")), ".CH-Project-Architecture", "template"
    )
    tpl_art = read(os.path.join(tpl_root, "PROJECT_ARTIFACT.md"))
    tpl_deck = read(os.path.join(tpl_root, "DECK.md")) or read(
        os.path.join(tpl_root, "docs", "01-session", "DECK.md")
    )
    d["baseline"] = bool(tpl_art or tpl_deck)
    a_real, a_hole = substance(art, tpl_art or None)
    k_real, k_hole = substance(deck, tpl_deck or None)
    d["parts"] = {
        "AGENTS.md": bool(agents),
        "PROJECT_ARTIFACT.md": bool(art),
        "DECK.md": bool(deck),
        "STATUS.md": bool(status),
    }
    d["substance"] = {"filled": a_real + k_real, "placeholder": a_hole + k_hole}

    sd = os.path.join(repo, "docs", "01-session")
    d["sessions"] = (
        len([f for f in os.listdir(sd) if f.startswith("SESSION-") and f.endswith(".md")])
        if os.path.isdir(sd)
        else 0
    )

    # git: total commits, first/last, 12-week cadence
    log = sh(["git", "log", "--format=%ct"], repo)
    stamps = sorted(int(x) for x in log.split() if x.isdigit())
    d["commits"] = len(stamps)
    now = datetime.datetime.now()
    weeks = [0] * 12
    if stamps:
        d["first"] = datetime.datetime.fromtimestamp(stamps[0]).strftime("%Y-%m-%d")
        d["last"] = datetime.datetime.fromtimestamp(stamps[-1]).strftime("%Y-%m-%d")
        d["days_since"] = (now - datetime.datetime.fromtimestamp(stamps[-1])).days
        for t in stamps:
            wk = int((now - datetime.datetime.fromtimestamp(t)).days // 7)
            if 0 <= wk < 12:
                weeks[11 - wk] += 1
    else:
        d["first"] = d["last"] = "-"
        d["days_since"] = None
    d["weeks"] = weeks
    d["remote"] = sh(["git", "remote", "get-url", "origin"], repo).strip() or "none"
    d["branch"] = sh(["git", "rev-parse", "--abbrev-ref", "HEAD"], repo).strip() or "-"

    # languages from committed blobs
    langs = collections.Counter()
    listing = sh(["git", "ls-tree", "-r", "-l", "-z", "HEAD"], repo)
    nfiles = 0
    for entry in listing.split("\0"):
        if not entry:
            continue
        meta, _, rel = entry.partition("\t")
        parts = meta.split()
        if len(parts) < 4 or parts[1] != "blob" or not parts[3].isdigit():
            continue
        nfiles += 1
        low = rel.lower().replace("\\", "/")
        base = low.rsplit("/", 1)[-1]
        ext = base.rsplit(".", 1)[-1] if "." in base else base
        lang = LANG_BY_EXT.get(ext)
        size = int(parts[3])
        if not lang or any(g in "/" + low for g in GENERATED) or size >= OVERSIZE:
            continue
        langs[lang] += size
    d["tracked_files"] = nfiles
    total = sum(langs.values()) or 1
    ranked = sorted(langs.items(), key=lambda kv: kv[1], reverse=True)
    head = [kv for kv in ranked if 100.0 * kv[1] / total >= 1.0][:6]
    tail = sum(v for k, v in ranked if (k, v) not in head)
    d["languages"] = [{"name": k, "pct": round(100.0 * v / total, 1)} for k, v in head]
    if tail:
        d["languages"].append({"name": "Other", "pct": round(100.0 * tail / total, 1)})
    d["source_bytes"] = sum(langs.values())
    return d


def svg(d, dark=False):
    c = THEME["dark" if dark else "light"]
    W, pad = 880, 30
    P = []

    def esc(t):
        return html.escape(str(t), quote=True)

    def T(x, y, s, size, fill, weight="400", font=SANS, anchor="start", spacing=None):
        ls = f' letter-spacing="{spacing}"' if spacing else ""
        P.append(
            f'<text x="{x:.1f}" y="{y:.1f}" font-family="{font}" font-size="{size}" font-weight="{weight}" fill="{fill}" '
            f'text-anchor="{anchor}"{ls}>{esc(s)}</text>'
        )

    # header
    T(pad, 40, d["name"].upper(), 11, c["accent"], "600", MONO, spacing="3")
    T(pad, 72, d["one"] or "no one-line description recorded", 19, c["ink"], "600")
    meta = "{}  ·  {}  ·  {}".format(
        d["branch"],
        (d["remote"].split("/")[-1].replace(".git", "") if d["remote"] != "none" else "no remote"),
        ("last commit {}".format(d["last"])) if d["commits"] else "no commits",
    )
    T(pad, 94, meta, 12, c["ink3"], font=MONO)

    # chips
    chips = [
        (d["commits"], "commits"),
        (d["tracked_files"], "files"),
        ("%.0f KB" % (d["source_bytes"] / 1024.0), "source"),
        (d["sessions"], "sessions"),
        (("%dd" % d["days_since"]) if d["days_since"] is not None else "-", "since commit"),
    ]
    cy = 116
    cw = (W - 2 * pad) / len(chips)
    P.append(
        '<rect x="%d" y="%d" width="%d" height="54" rx="4" fill="%s" stroke="%s"/>'
        % (pad, cy, W - 2 * pad, c["panel"], c["rule"])
    )
    for i, (v, k) in enumerate(chips):
        cx = pad + i * cw + 14
        if i:
            P.append(
                '<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="%s"/>'
                % (pad + i * cw, cy + 11, pad + i * cw, cy + 43, c["rule"])
            )
        T(cx, cy + 31, v, 19, c["ink"], "600", MONO)
        T(cx, cy + 46, k, 10.5, c["ink3"])

    # substance meter - the honest centrepiece
    sy = 196
    filled, holes = d["substance"]["filled"], d["substance"]["placeholder"]
    tot = filled + holes
    pct = (100.0 * filled / tot) if tot else 0
    T(
        pad,
        sy,
        "PROJECT-SPECIFIC CONTENT"
        if d["baseline"]
        else "RECORD COMPLETENESS (no template baseline)",
        10.5,
        c["ink3"],
        "600",
        MONO,
        spacing="2.5",
    )
    T(
        W - pad,
        sy,
        ("%d filled  ·  %d still placeholder" % (filled, holes))
        if tot
        else "no artifact or deck to measure",
        11.5,
        c["ink3"],
        font=MONO,
        anchor="end",
    )
    bw = W - 2 * pad
    P.append(
        '<rect x="%d" y="%d" width="%d" height="14" rx="3" fill="%s"/>'
        % (pad, sy + 10, bw, c["track"])
    )
    if tot:
        col = c["good"] if pct >= 70 else (c["warn"] if pct >= 35 else c["gap"])
        P.append(
            '<rect x="%d" y="%d" width="%.1f" height="14" rx="3" fill="%s"/>'
            % (pad, sy + 10, max(bw * pct / 100.0, 2), col)
        )
        T(
            pad,
            sy + 42,
            (
                f"{pct:.0f}% of the artifact + deck is this project's own words; the rest is still template "
                "boilerplate or TODO."
            )
            if d["baseline"]
            else (
                f"{pct:.0f}% carries no TODO marker (weaker measure - template baseline not found)."
            ),
            12,
            c["ink2"],
        )
    else:
        T(
            pad,
            sy + 42,
            "Neither PROJECT_ARTIFACT.md nor DECK.md carries content yet.",
            12,
            c["ink2"],
        )
    T(
        pad,
        sy + 60,
        "Measures whether the record was written - never whether the project is good.",
        11.5,
        c["ink3"],
    )

    # standard parts
    py = sy + 88
    T(pad, py, "STANDARD SET", 10.5, c["ink3"], "600", MONO, spacing="2.5")
    x = pad
    for k, ok in d["parts"].items():
        col = c["good"] if ok else c["gap"]
        P.append(f'<circle cx="{x + 5:.1f}" cy="{py + 20:.1f}" r="4.5" fill="{col}"/>')
        T(x + 16, py + 24, k, 12, c["ink2"] if ok else c["ink3"], font=MONO)
        x += 22 + len(k) * 7.1 + 22

    # activity sparkline
    ay = py + 56
    T(pad, ay, "COMMIT CADENCE  ·  LAST 12 WEEKS", 10.5, c["ink3"], "600", MONO, spacing="2.5")
    mx = max(d["weeks"]) or 1
    bwid = (W - 2 * pad) / 12.0
    for i, v in enumerate(d["weeks"]):
        h = max(2, 40 * v / mx)
        bx = pad + i * bwid
        P.append(
            '<rect x="{:.1f}" y="{:.1f}" width="{:.1f}" height="{:.1f}" rx="2" fill="{}" opacity="{:.2f}"/>'.format(
                bx, ay + 54 - h, bwid - 5, h, c["accent"], 0.35 + 0.65 * (v / mx)
            )
        )
    T(pad, ay + 70, "{} → {}".format(d["first"], d["last"]), 11, c["ink3"], font=MONO)
    T(W - pad, ay + 70, "peak %d commits/week" % mx, 11, c["ink3"], font=MONO, anchor="end")

    # languages
    ly = ay + 96
    if d["languages"]:
        T(pad, ly, "LANGUAGE MIX", 10.5, c["ink3"], "600", MONO, spacing="2.5")
        cur = pad
        for lg in d["languages"]:
            seg = bw * lg["pct"] / 100.0
            P.append(
                '<rect x="%.1f" y="%d" width="%.1f" height="11" fill="%s"/>'
                % (cur, ly + 10, max(seg, 1), LANG_COLORS.get(lg["name"], "#8b949e"))
            )
            cur += seg
        kx = pad
        for lg in d["languages"]:
            P.append(
                '<rect x="{:.1f}" y="{:.1f}" width="8" height="8" rx="1" fill="{}"/>'.format(
                    kx, ly + 33, LANG_COLORS.get(lg["name"], "#8b949e")
                )
            )
            lab = "{} {:.0f}%".format(lg["name"], lg["pct"])
            T(kx + 13, ly + 41, lab, 11.5, c["ink2"])
            kx += 13 + len(lab) * 6.9 + 18
        fy = ly + 68
    else:
        T(pad, ly, "No committed source detected (documentation-only repo).", 12, c["ink3"])
        fy = ly + 24

    T(
        pad,
        fy,
        "Derived view - regenerate with build-project-atlas.py. Holds no truth of its own.",
        11,
        c["ink3"],
        font=MONO,
    )
    H = int(fy + 22)
    return (
        (
            '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">'
            '<rect width="%d" height="%d" rx="10" fill="%s"/>' % (W, H, W, H, W, H, c["ground"])
        )
        + "".join(P)
        + "</svg>"
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=os.getcwd())
    ap.add_argument("--out", default=None)
    ap.add_argument("--brain", default=None)
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    out = args.out or os.path.join(repo, "docs")
    os.makedirs(out, exist_ok=True)
    d = collect(repo, args.brain)

    # newline="" on every write: Python's Windows text mode silently turns each \n into \r\n, and a
    # CRLF file fails prettier and several pre-commit configs. This generator is swept into repos
    # that gate on both, so it must emit LF regardless of the host OS. (Diagnosed the slow way on
    # 2026-08-28: escaped unicode and a missing trailing newline were the two wrong guesses before
    # `od -c` showed the line endings were the actual difference.)
    for dark, sfx in ((False, ""), (True, "-dark")):
        with open(os.path.join(out, f"atlas{sfx}.svg"), "w", encoding="utf-8", newline="") as fh:
            fh.write(svg(d, dark))
    with open(os.path.join(out, "atlas.json"), "w", encoding="utf-8", newline="") as fh:
        # Trailing newline on purpose: prettier (and pre-commit's end-of-file-fixer) treat its
        # absence as a violation, and this file is swept into repos that gate on both. Without it
        # the atlas broke .CH-Graph's pre-commit hook on 2026-08-28 - the repo itself was clean,
        # my file was the only offender.
        # ensure_ascii=False: json.dump escapes non-ASCII by default (an em dash becomes —),
        # and prettier - which several repos gate on - rewrites that back to literal UTF-8. The
        # escaped form is what actually broke .CH-Graph's pre-commit hook; the missing newline was
        # only the half I guessed first.
        json.dump(d, fh, indent=2, ensure_ascii=False)
        fh.write(chr(10))

    s = d["substance"]
    tot = s["filled"] + s["placeholder"]
    sys.stdout.write(
        "%-26s commits=%-5d files=%-5d source=%-7s sessions=%-3d record=%s\n"
        % (
            d["name"],
            d["commits"],
            d["tracked_files"],
            "%.0fKB" % (d["source_bytes"] / 1024.0),
            d["sessions"],
            (("%.0f%% own" % (100.0 * s["filled"] / tot)) if tot else "no artifact/deck")
            + ("" if d["baseline"] else " (no baseline)"),
        )
    )


if __name__ == "__main__":
    main()
