#!/usr/bin/env python3

r"""
show mermaid chart from Document.overview in android_icon_specification.py
copyright 2025, hanagai

view_mermaid_android_icon_specification.py
version: March 29, 2025
"""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import webbrowser
from datetime import datetime, timedelta, timezone
import importlib

class HttpRequestHandler(BaseHTTPRequestHandler):

  def do_GET(self):
    self.send_response(200)
    self.send_header('Content-type', 'text/html')
    expires = datetime.now(timezone.utc) + timedelta(seconds=1)
    self.send_header('Expires', expires.strftime("%a, %d %b %Y %H:%M:%S GMT"))
    self.end_headers()

    module = __import__("android_icon_specification")
    importlib.reload(module)
    r"""
    force reload, because we might editing the module
    """
    content = module.Test().html_overview()
    self.wfile.write(bytes(content, "utf8"))


def main():

  PROTOCOL = "http"
  ADDRESS = "127.0.0.1"
  PORT = 8080

  url = f"{PROTOCOL}://{ADDRESS}:{PORT}"
  print(url)

  httpd = ThreadingHTTPServer((ADDRESS, PORT), HttpRequestHandler)
  webbrowser.open(url, new=2) # open with tab
  httpd.serve_forever()

if __name__ == '__main__':

  main()
