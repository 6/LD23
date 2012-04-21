#!/usr/bin/env ruby

# from: http://chrismdp.github.com/2011/12/cache-busting-ruby-http-server/
# (not part of the game, just tool for development)

require 'webrick'
class NonCachingFileHandler < WEBrick::HTTPServlet::FileHandler
  def prevent_caching(res)
    res['ETag']          = nil
    res['Last-Modified'] = Time.now + 100**4
    res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
    res['Pragma']        = 'no-cache'
    res['Expires']       = Time.now - 100**4
  end

  def do_GET(req, res)
    super
    prevent_caching(res)
  end
end

server = WEBrick::HTTPServer.new :Port => 8000

server.mount '/', NonCachingFileHandler , Dir.pwd
trap('INT') { server.stop }
server.start
