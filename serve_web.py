#!/usr/bin/env python3
"""Lokal CORS-proxy för Dumpen webapp.

Servrar Flutter-webappen från build/web och vidarebefordrar /proxy/*
till https://dumpen.se med rätt User-Agent (dumpen.se blockerar requests
utan browser UA).
"""

import http.server
import socketserver
import urllib.request
import urllib.error
import sys
from pathlib import Path

PORT = 8080
BUILD_DIR = Path(__file__).parent / "build" / "web"
DUMPEN = "https://dumpen.se"
UA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BUILD_DIR), **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_HEAD(self):
        self._handle()

    def do_GET(self):
        self._handle()

    def _handle(self):
        # Proxya /proxy/* till dumpen.se
        if self.path.startswith("/proxy/"):
            target = DUMPEN + self.path[len("/proxy"):]
            self._proxy(target)
            return

        # Försök serva lokalt
        super().do_GET() if self.command == "GET" else super().do_HEAD()

    def _proxy(self, target_url: str):
        try:
            req = urllib.request.Request(target_url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as resp:
                body = resp.read()
                self.send_response(resp.status)
                for key, value in resp.getheaders():
                    lower = key.lower()
                    if lower in ("content-encoding", "transfer-encoding",
                                "access-control-allow-origin",
                                "access-control-allow-methods",
                                "access-control-allow-headers",
                                "content-length"):
                        continue
                    self.send_header(key, value)
                self.send_header("Content-Length", str(len(body)))
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                if self.command != "HEAD":
                    self.wfile.write(body)
        except urllib.error.HTTPError as e:
            body = e.read()
            self.send_response(e.code)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(body)
        except Exception as e:
            msg = f"Proxy error: {e}".encode()
            self.send_response(502)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Content-Length", str(len(msg)))
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(msg)

    def log_message(self, format, *args):
        # Tysta loggen lite
        pass


def main():
    if not BUILD_DIR.exists():
        print(f"Hittade inte {BUILD_DIR}. Kör 'flutter build web' först.")
        sys.exit(1)

    socketserver.TCPServer.allow_reuse_address = True

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Dumpen app kör på http://localhost:{PORT}")
        print(f"På mobil: http://192.168.0.23:{PORT}")
        print("Tryck Ctrl+C för att stoppa.")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
