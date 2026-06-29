#!/usr/bin/env python3
"""
Simple HTTP server with CORS headers needed for love.js SharedArrayBuffer
"""
import http.server
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000


class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add required headers for SharedArrayBuffer support in love.js
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Origin, Content-Type')

        # Cache control
        if self.path.endswith('.html'):
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        elif self.path.endswith('.love'):
            self.send_header('Cache-Control', 'public, max-age=86400')
        else:
            self.send_header('Cache-Control', 'public, max-age=3600')

        super().end_headers()

    def log_message(self, format, *args):
        print(f'[{self.log_date_time_string()}] {format % args}')


if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
        print(f'🐄 Cow Game server running on port {PORT}')
        print(f'📍 Visit: http://localhost:{PORT}')
        print(f'   or:   http://192.168.0.9:{PORT}')
        print(f'\nPress Ctrl+C to stop')
        httpd.serve_forever()
