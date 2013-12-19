require 'nokogiri'
require 'open-uri'

# Cartographically burglarize your favorite destination
class Creep
  attr_reader :data, :success, :failure

  def initialize(uri = 'https://www.joingrouper.com/', *junk)
    @data = {}
    @success = []
    @failure = []
    @domain = uri.chomp('/')
    merge uri, [], [], [], []
    @success.empty? ? FALSE : super
  end

  def merge(uri, a, js, css, img)
    update = { uri => { a: a, js: js, css: css, img: img } }
    @data = @data.merge(update)
  end

  def download(uri)
    Nokogiri::HTML(open(uri))
  rescue
    @failure.push  uri
    @data.delete uri
    nil
  end

  def look_for(selector, attribute, content)
    list = []
    content.css(selector).each do |e|
      node = audit_uri(e.attribute(attribute).to_s)
      list.push(node) if !node.nil? && !list.include?(node)
    end
    list
  end

  def audit_uri(uri)
    if uri.is_a? String
      if uri.start_with?(@domain)
        website = uri.chomp('/')
      else
        if uri.start_with?('/') && !uri.start_with?('//')
          website = @domain + uri.chomp('/')
        end
      end
      return website unless website.nil?
    end
  end

  def parse(content)
    unless content.nil?
      [
        look_for('a', 'href', content),
        look_for('script', 'src', content),
        look_for('link', 'href', content),
        look_for('img', 'src', content)
      ]
    end
  end

  def mine(key)
    if !@success.include?(key) && !@failure.include?(key)
      result = parse(download(key))
      unless result.nil?
        merge key, *result
        @success.push key
        result[0].each do |link|
          merge(link, [], [], [], []) unless @data.include? link
        end
      end
    end
  end

  def scrape
    progress = 0
    until progress == @data.length
      progress = @data.length
      @data.each do |key, value|
        mine key
      end
    end
    @data
  end
end
