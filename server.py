#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class OTelDebugHandler(BaseHTTPRequestHandler):
    def _set_response(self, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        print(f"\n=== GET {self.path} ===")
        for key, value in self.headers.items():
            print(f"{key}: {value}")
        self._set_response()
        response = {"message": "GET received", "path": self.path}
        self.wfile.write(json.dumps(response).encode("utf-8"))

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length > 0 else b''
        print(f"\n=== POST {self.path} ===")
        print("Headers:")
        for key, value in self.headers.items():
            print(f"  {key}: {value}")

        print("\nBody:")
        try:
            parsed = json.loads(body.decode('utf-8'))
            print(json.dumps(parsed, indent=2))
        except Exception:
            print(body.decode('utf-8', errors='replace'))

        self._set_response()
        response = {"status": "ok", "path": self.path}
        self.wfile.write(json.dumps(response).encode("utf-8"))

def run(server_class=HTTPServer, handler_class=OTelDebugHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Servidor OTel Debug escuchando en http://0.0.0.0:{port}")
    httpd.serve_forever()

if __name__ == '__main__':
    run()
