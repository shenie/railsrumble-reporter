#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'open-uri'
require 'extensions/all'
require 'hpricot'
require 'cache'

# 
# Created by Andy Shen (andy@shenie.info)
# Keeps an eye on the ranking of railsrumble voting results and post updates to Twitter
# Usage:
# r = Reporter.new('admin@example.com', 'password', 5)
# r.publish
# 
class Reporter
  
  def initializer(screen_name_or_email, password, top = 20)
    @login = screen_name_or_email
    @password = password
    @cache = Cache.new("/tmp/cache.railsrumblerank")
    @top = top
  end
  
  def rankings
    return @rankings if @rankings
    doc = Hpricot(open("http://vote.railsrumble.com/teams/browse?order=ranking"))
    @rankings = ''
    doc.search('h3//a').map(&:inner_html)[0..@top-1].each_with_index { |r, i| @rankings << "##{i + 1} #{r}, \n" }
    @rankings
  end
  
  def publish
    if @cache.keep(rankings)
      Net::HTTP.post_form(URI.parse("http://#{@login}:#{@password}@twitter.com/statuses/update.json"), 'status' => rankings)
    end
  end
end
