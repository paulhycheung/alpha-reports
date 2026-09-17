"""
publish_site.py
================
Maintenance script for the public "site" mirror of the daily alpha reports.

What it does each run:
  1. Looks at the full report history in C:\\Users\\phc220001\\OneDrive\\alpha
     (files named alpha_report_YYYY-MM-DD.html) — that folder is NEVER pruned,
     it's your permanent local archive.
  2. Copies any reports from the last KEEP_DAYS days into site/reports/,
     which is the folder that actually gets pushed to GitHub Pages.
  3. Deletes any report files inside site/reports/ that are OLDER than
     KEEP_DAYS, so the public GitHub repo/page stays small.
  4. Regenerates site/manifest.json (the list the password-gated page reads
     to show available reports).

This script does NOT touch git at all — it just prepares the site/ folder's
contents. The scheduled task runs `git add -A && git commit && git push`
in this folder separately, after calling this script.

Usage:
    python publish_site.py
"""
import json
import re
import shutil
from datetime import datetime, timedelta
from pathlib import Path

KEEP_DAYS = 14

ALPHA_DIR = Path(r"C:\Users\phc220001\OneDrive\alpha")
SITE_DIR = ALPHA_DIR / "site"
REPORTS_DIR = SITE_DIR / "reports"

FILENAME_RE = re.compile(r"alpha_report_(\d{4}-\d{2}-\d{2})\.html$")


def main():
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    cutoff = datetime.today().date() - timedelta(days=KEEP_DAYS)

    # 1+2: copy in-window reports from the permanent archive into site/reports/
    copied = []
    for f in ALPHA_DIR.glob("alpha_report_*.html"):
        m = FILENAME_RE.match(f.name)
        if not m:
            continue
        report_date = datetime.strptime(m.group(1), "%Y-%m-%d").date()
        if report_date >= cutoff:
            dest = REPORTS_DIR / f.name
            shutil.copy2(f, dest)
            copied.append((m.group(1), f.name))

    # 3: prune anything in site/reports/ older than the window (in case KEEP_DAYS
    # was lowered, or a file lingered from before)
    removed = []
    for f in REPORTS_DIR.glob("alpha_report_*.html"):
        m = FILENAME_RE.match(f.name)
        if not m:
            continue
        report_date = datetime.strptime(m.group(1), "%Y-%m-%d").date()
        if report_date < cutoff:
            f.unlink()
            removed.append(f.name)

    # 4: regenerate manifest.json from whatever remains in site/reports/
    manifest = []
    for f in REPORTS_DIR.glob("alpha_report_*.html"):
        m = FILENAME_RE.match(f.name)
        if m:
            manifest.append({"date": m.group(1), "filename": f.name})
    manifest.sort(key=lambda r: r["date"], reverse=True)

    with open(SITE_DIR / "manifest.json", "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2)

    print(f"Copied/kept {len(manifest)} report(s) in site/reports/.")
    if removed:
        print(f"Pruned {len(removed)} report(s) older than {KEEP_DAYS} days: {', '.join(removed)}")


if __name__ == "__main__":
    main()
