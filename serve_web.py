#!/usr/bin/env python3
"""Lokal server för Dumpen webapp med CORS-proxy mot dumpen.se.

Servrar filer från build/web och vidarebefordrar /wp-json/* samt
/wp-content/* till https://dumpen.se så att appen kan köras lokalt
utan CORS-fel, inklusive videor och bilder.
"""

import http.server
import socketserver
import urllib.request
import urllib.error
import sys
from pathlib import Path

PORT = 8080
BUILD_DIR = Path(__file__).parent / "build" / "web"
API_BASE = "https://dumpen.se"


def _is_proxy_path(path: str) -> bool:
    return path.startswith("/wp-json/") or path.startswith("/wp-content/")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BUILD_DIR), **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, HEAD, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Access-Control-Expose-Headers", "*")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_HEAD(self):
        if _is_proxy_path(self.path):
            self._proxy(API_BASE + self.path, method="HEAD")
            return
        super().do_HEAD()

    def do_GET(self):
        if _is_proxy_path(self.path):
            self._proxy(API_BASE + self.path, method="GET")
            return
        super().do_GET()

    def _proxy(self, target_url: str, method: str = "GET"):
        try:
            headers = {"User-Agent": "DumpenApp/1.0"}
            if self.path.startswith("/wp-json/"):
                headers["Accept"] = "application/json"

            req = urllib.request.Request(target_url, headers=headers, method=method)
            with urllib.request.urlopen(req, timeout=60) as resp:
                body = b""
                if method != "HEAD":
                    body = resp.read()
                self.send_response(resp.status)
                for key, value in resp.headers.items():
                    lower = key.lower()
                    if lower in ("content-encoding", "transfer-encoding", "access-control-allow-origin"):
                        continue
                    self.send_header(key, value)
                self.end_headers()
                if body:
                    self.wfile.write(body)
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            if method != "HEAD":
                self.wfile.write(e.read())
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            if method != "HEAD":
                self.wfile.write(f"Proxy error: {e}".encode())


def main():
    if not BUILD_DIR.exists():
        print(f"Hittade inte {BUILD_DIR}. Kör 'flutter build web' först.")
        sys.exit(1)

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Server kör på http://localhost:{PORT}")
        print("Öppna den URL:en i Chrome för att se appen.")
        print("Tryck Ctrl+C för att stoppa.")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
