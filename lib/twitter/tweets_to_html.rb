require 'open-uri'
require 'hpricot'

class Twitter::TweetsToHtml
  require 'action_view/test_case'

  TWITTER_USERNAME = "battlepet"
  TWEETS_ENDPOINT = "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{TWITTER_USERNAME}"
  URL_PREFIX = "http://twitter.com/#{TWITTER_USERNAME}/statuses/"
  LOCAL_CACHE = "#{RAILS_ROOT}/tmp/tweets.xml"
  EMPTY_DEFAULT = "<em class='tweets'>No Birdsong</em>"
  EXPIRATION_IN_HOURS = 1
  COUNT_DEFAULT = 3

  attr_accessor :doc
  
  def initialize
    begin
      @doc = load_xml
    rescue
      RAILS_DEFAULT_LOGGER.info "Twitter::TweetsToHtml FAILURE: Could Not Load Tweets"
    end
  end  
  
  def to_html
    return EMPTY_DEFAULT unless @doc && !@doc.blank?
    
    html = ""
    (@doc/'status').each_with_index do |st,idx|
      break if idx >= COUNT_DEFAULT
      
      user = (st/'user name').inner_html
      text = (st/'text').inner_html
      tid = (st/'id').first.inner_html
      text = parse_tweet(text)
      
      html << "<a href=\"#{URL_PREFIX}#{tid}\"><li class='tweet'>#{text}</a></li>"
    end
    return "<ul class='tweets'>#{html}</ul>"
  end
  
  def load_xml
    return load_from_filesystem || load_from_twitter
  end  
  
  def load_from_filesystem
    if File.exist?(LOCAL_CACHE)
      return cache_expired? ? nil : Hpricot( open( LOCAL_CACHE ) ) 
    else
      return nil
    end
  end
  
  def cache_expired?
    last_modified = File.mtime(LOCAL_CACHE)
    last_download_in_ms = Time.now - last_modified
    last_download_in_hours = ((last_download_in_ms / 100) / 60) / 60
    return last_download_in_hours > EXPIRATION_IN_HOURS
  end
  
  def load_from_twitter
    xml = Hpricot( open( TWEETS_ENDPOINT ) ) 
    File.open(LOCAL_CACHE, 'w') {|f| f.write(xml) } # save twitter file
    return xml
  end
  
  def parse_tweet(text)
    URI.extract(text, %w[ http https ftp ]).each do |url|
      text.gsub!(url, "<a href=\"#{url}\">#{url}</a>")
    end
    text = linkup_mentions_and_hashtags(text)
    return text
  end  
  
  def linkup_mentions_and_hashtags(text)
   text.gsub!(/@([\w]+)(\W)?/, '<a href="http://twitter.com/\1">@\1</a>\2')
   text.gsub!(/#([\w]+)(\W)?/, '<a href="http://twitter.com/search?q=%23\1">#\1</a>\2')
   return text
  end  
end