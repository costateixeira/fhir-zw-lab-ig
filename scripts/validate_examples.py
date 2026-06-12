#!/usr/bin/env python3
"""
Validate the built IG example resources against a live FHIR server.

For every example instance in fsh-generated/resources/ this script calls

    POST {server}/{ResourceType}/$validate?profile={meta.profile}

and pretty-prints the resulting OperationOutcome, ending with a summary
table — designed for live demos.

Usage:
    python3 scripts/validate_examples.py                       # defaults
    python3 scripts/validate_examples.py --server http://173.212.195.88/fhir
    python3 scripts/validate_examples.py --only ServiceRequest Patient
    python3 scripts/validate_examples.py --no-color            # plain output
"""

import argparse
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

DEFAULT_SERVER = "http://173.212.195.88/fhir"
DEFAULT_DIR = Path(__file__).resolve().parent.parent / "fsh-generated" / "resources"

# Resource types that are IG definition artifacts, not examples
DEFINITIONAL = {"StructureDefinition", "CodeSystem", "ValueSet", "ImplementationGuide",
                "SearchParameter", "CapabilityStatement", "ConceptMap", "NamingSystem"}


class C:
    """ANSI colors (disabled with --no-color)."""
    enabled = True
    @classmethod
    def _c(cls, code, text):
        return f"\033[{code}m{text}\033[0m" if cls.enabled else str(text)
    @classmethod
    def bold(cls, t):    return cls._c("1", t)
    @classmethod
    def dim(cls, t):     return cls._c("2", t)
    @classmethod
    def red(cls, t):     return cls._c("31", t)
    @classmethod
    def green(cls, t):   return cls._c("32", t)
    @classmethod
    def yellow(cls, t):  return cls._c("33", t)
    @classmethod
    def blue(cls, t):    return cls._c("34", t)
    @classmethod
    def cyan(cls, t):    return cls._c("36", t)


SEV_ORDER = {"fatal": 0, "error": 1, "warning": 2, "information": 3}
SEV_ICON = {"fatal": "✖", "error": "✖", "warning": "▲", "information": "ℹ"}


def sev_color(sev, text):
    if sev in ("fatal", "error"):
        return C.red(text)
    if sev == "warning":
        return C.yellow(text)
    return C.dim(text)


def load_examples(directory: Path, only: list[str] | None):
    examples = []
    for path in sorted(directory.glob("*.json")):
        try:
            resource = json.loads(path.read_text())
        except (json.JSONDecodeError, UnicodeDecodeError):
            continue
        rtype = resource.get("resourceType")
        if not rtype or rtype in DEFINITIONAL:
            continue
        if only and rtype not in only:
            continue
        examples.append((path, resource))
    return examples


def validate(server: str, resource: dict, timeout: int):
    rtype = resource["resourceType"]
    profiles = resource.get("meta", {}).get("profile", [])
    url = f"{server.rstrip('/')}/{rtype}/$validate"
    if profiles:
        url += "?" + urllib.parse.urlencode({"profile": profiles[0]})

    body = json.dumps(resource).encode()
    request = urllib.request.Request(
        url, data=body, method="POST",
        headers={"Content-Type": "application/fhir+json",
                 "Accept": "application/fhir+json"})
    started = time.time()
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            payload = json.loads(response.read())
            status = response.status
    except urllib.error.HTTPError as e:
        # Servers return 4xx/5xx with an OperationOutcome body on failure
        try:
            payload = json.loads(e.read())
        except Exception:
            payload = {"resourceType": "OperationOutcome",
                       "issue": [{"severity": "fatal", "code": "exception",
                                  "diagnostics": f"HTTP {e.code}: {e.reason}"}]}
        status = e.code
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        payload = {"resourceType": "OperationOutcome",
                   "issue": [{"severity": "fatal", "code": "exception",
                              "diagnostics": f"Connection failed: {e}"}]}
        status = None
    elapsed = time.time() - started
    return url, status, payload, elapsed


def summarize_issues(outcome: dict):
    issues = outcome.get("issue", [])
    counts = {"fatal": 0, "error": 0, "warning": 0, "information": 0}
    for issue in issues:
        sev = issue.get("severity", "information")
        counts[sev] = counts.get(sev, 0) + 1
    return issues, counts


def issue_location(issue: dict):
    loc = issue.get("expression") or issue.get("location") or []
    return loc[0] if loc else ""


def issue_text(issue: dict):
    details = issue.get("details", {}).get("text")
    return details or issue.get("diagnostics", "(no detail)")


def print_banner(server, count):
    line = "═" * 74
    print(C.cyan(line))
    print(C.cyan("  Zimbabwe Lab IG — Example Validation Demo"))
    print(C.cyan(f"  Server: {server}"))
    print(C.cyan(f"  Validating {count} example resource(s) against their profiles"))
    print(C.cyan(line))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--server", default=DEFAULT_SERVER, help=f"FHIR base URL (default: {DEFAULT_SERVER})")
    parser.add_argument("--dir", type=Path, default=DEFAULT_DIR, help="Directory of built example JSON files")
    parser.add_argument("--only", nargs="*", help="Limit to these resource types (e.g. --only ServiceRequest Patient)")
    parser.add_argument("--timeout", type=int, default=60, help="Per-request timeout in seconds (default 60)")
    parser.add_argument("--max-issues", type=int, default=10, help="Max issues displayed per resource (default 10)")
    parser.add_argument("--no-color", action="store_true", help="Disable colored output")
    parser.add_argument("--pause", action="store_true", help="Wait for Enter between resources (demo pacing)")
    args = parser.parse_args()

    if args.no_color or not sys.stdout.isatty():
        C.enabled = False

    if not args.dir.is_dir():
        sys.exit(f"Directory not found: {args.dir} — run sushi/the IG build first.")

    examples = load_examples(args.dir, args.only)
    if not examples:
        sys.exit("No example resources found.")

    print_banner(args.server, len(examples))
    results = []

    for path, resource in examples:
        rtype = resource["resourceType"]
        rid = resource.get("id", "?")
        profiles = resource.get("meta", {}).get("profile", [])
        profile = profiles[0] if profiles else "(no profile — base validation)"

        print()
        print(C.bold(f"▶ {rtype}/{rid}"))
        print(f"  {C.dim('file:')}    {path.name}")
        print(f"  {C.dim('profile:')} {profile}")

        url, status, outcome, elapsed = validate(args.server, resource, args.timeout)
        print(f"  {C.dim('request:')} POST {url}")

        issues, counts = summarize_issues(outcome)
        ok = counts["fatal"] == 0 and counts["error"] == 0 and status is not None

        verdict = C.green("✔ PASSED") if ok else C.red("✘ FAILED")
        http = f"HTTP {status}" if status else "no response"
        print(f"  {C.dim('result:')}  {verdict}  {C.dim(f'({http}, {elapsed:.1f}s)')}  "
              f"{sev_color('error', str(counts['fatal'] + counts['error']) + ' errors')}, "
              f"{sev_color('warning', str(counts['warning']) + ' warnings')}, "
              f"{C.dim(str(counts['information']) + ' info')}")

        shown = 0
        for issue in sorted(issues, key=lambda i: SEV_ORDER.get(i.get("severity"), 9)):
            sev = issue.get("severity", "information")
            if sev == "information" and issue_text(issue).lower().startswith("validation successful"):
                continue
            if shown >= args.max_issues:
                print(C.dim(f"    … {len(issues) - shown} more issue(s) suppressed (--max-issues)"))
                break
            loc = issue_location(issue)
            loc_part = C.dim(f" @ {loc}") if loc else ""
            print(f"    {sev_color(sev, SEV_ICON.get(sev, '·') + ' ' + sev.upper())}{loc_part}")
            print(f"      {issue_text(issue)[:300]}")
            shown += 1

        results.append((rtype, rid, ok, counts, status))
        if args.pause:
            input(C.dim("  — press Enter for next resource —"))

    # ── Summary table ─────────────────────────────────────────────────────
    print()
    line = "─" * 74
    print(C.cyan(line))
    print(C.bold(f"  {'RESOURCE':<46}{'ERRORS':>8}{'WARN':>7}{'RESULT':>10}"))
    print(C.cyan(line))
    passed = 0
    for rtype, rid, ok, counts, status in results:
        name = f"{rtype}/{rid}"
        errs = counts["fatal"] + counts["error"]
        verdict = C.green("PASS") if ok else C.red("FAIL")
        print(f"  {name:<46}{errs:>8}{counts['warning']:>7}    {verdict}")
        passed += ok
    print(C.cyan(line))
    total = len(results)
    overall = C.green(f"{passed}/{total} passed") if passed == total else C.red(f"{passed}/{total} passed")
    print(f"  {C.bold('TOTAL:')} {overall}")
    print(C.cyan(line))

    sys.exit(0 if passed == total else 1)


if __name__ == "__main__":
    main()
