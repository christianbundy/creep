require 'nokogiri'
require 'open-uri'

# Cartographically burglarize your favorite destination
class Creep
  attr_reader :data, :success, :failure

  # Initialize creep and merge in the first URI
  # @param uri [String] the webite to creep
  # @return [Boolean] if the website can't be scraped
  # @return [Hash] if the website was scraped correctly
  def initialize(uri = 'https://www.joingrouper.com/', *junk)
    @data = {}
    @success = []
    @failure = []
    @domain = uri.chomp('/')
    merge uri, [], [], [], []
    @success.empty? ? FALSE : @data
  end

  # Merge the URI and associated data into collection
  # @param uri [String] the URI that was scraped
  # @param a [Array] links from the URI
  # @param js [Array] javascript from the URI
  # @param css [Array] css from the URI
  # @param img [Array] images from the URI
  # @return [Hash] entire collection of data
  def merge(uri, a, js, css, img)
    update = { uri => { a: a, js: js, css: css, img: img } }
    @data = @data.merge(update)
  end

  # Download the URI
  # @param uri [String] the URI to download
  # @return [String] the content of the URI
  def download(uri)
    Nokogiri::HTML(open(uri))
  rescue
    @failure.push  uri
    @data.delete uri
    nil
  end

  # Look through URI content for element attributes
  # @param selector [String] the selector to use
  # @param attribute [String] the attribute of the selector to safe
  # @param content [String] the content to search through
  # @return [String] a list of the element attributes
  def look_for(selector, attribute, content)
    list = []
    content.css(selector).each do |e|
      node = audit_uri(e.attribute(attribute).to_s)
      list.push(node) if !node.nil? && !list.include?(node)
    end
    list
  end

  # Validate URI
  # @param uri [String] the URI to validate
  # @return [String] if the URI can be validated
  # @return [NilClass] if the URI can't be validated
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

  # Parses content and delegates element attribute search
  # @param content [String] the content to parse 
  # @return [Array] if there is content to search
  # @return [NilClass] if there is no content to search
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

  # Mine URI for other links
  # @param uri [String] the URI to mine
  # @return [TrueClass] if the URI is mined successfully
  # @return [FalseClass] if the URI can't be mined
  def mine(uri)
    if !@success.include?(uri) && !@failure.include?(uri)
      result = parse(download(uri))
      unless result.nil?
        merge uri, *result
        @success.push uri
        result[0].each do |link|
          merge(link, [], [], [], []) unless @data.include? link
        end
        TRUE
      end
    else
      FALSE
    end
  end

  # Scrape website by mining each unmined key in collection 
  # @return [Hash] the full collection of mined data
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
