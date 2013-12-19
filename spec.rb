require 'simplecov'
SimpleCov.start
require_relative 'creep'

describe Creep do
  grouper = 'https://www.joingrouper.com'

  describe '#new' do
    it 'fails with 0 parameters' do
      expect(c = Creep.new).not_to raise_error
    end

    it 'takes a single parameter' do
      expect(c = Creep.new(grouper)).not_to raise_error
    end

    it 'ignores extra parameters' do
      expect(Creep.new(grouper, 0)).not_to raise_error
    end
  end

  describe '#download' do
    begin
      c = Creep.new
    end

    it "doesn't fail with a real URL" do
      content = c.download('http://requestb.in/qgfg5cqg')
      expect(content).to_not raise_error
    end

    it 'retreives content for correct URIs' do
      content = c.download('http://requestb.in/qgfg5cqg')
      expect(content).not_to(eq(nil))
    end

    it 'retreives nil for incorrect URIS' do
      content = c.download('abcdefg')
      expect(content).to(eq(nil))
    end
  end

  describe '#look_for' do
    begin
      c = Creep.new
    end

    it 'returns an empty array with no content' do
      content = Nokogiri::HTML('')
      result = c.look_for 'a', 'b', content
      expect(result).to eq([])
    end

    it 'returns an array of matches' do
      content = Nokogiri::HTML('<html><a b="/"></html>')
      result = c.look_for 'a', 'b', content
      expect(result).to eq [grouper]
    end
  end

  describe '#audit_uri' do
    begin
      c = Creep.new
    end

    it 'chomps "/" from URI' do
      expect(c.audit_uri('https://www.joingrouper.com/')).to eq(grouper)
    end

    it 'translates "/"" correctly' do
      expect(c.audit_uri('/')).to eq(grouper)
    end

    it 'ignores foreign addresses' do
      expect(c.audit_uri('http://example.com')).to eq(nil)
    end
  end

  describe '#parse' do
    begin
      c = Creep.new
    end

    it 'returns nil for nil' do
      expect(c.parse(nil)).to eq(nil)
    end

    it 'finds links' do
      content = Nokogiri::HTML('<html><a href="/"></html>')
      expect(c.parse(content)).to eq [[grouper], [], [], []]
    end

    it 'finds scripts' do
      content = Nokogiri::HTML('<html><script src="/"></html>')
      expect(c.parse(content)).to eq [[], [grouper], [], []]
    end

    it 'finds stylesheets' do
      content = Nokogiri::HTML('<html><link href="/"></html>')
      expect(c.parse(content)).to eq [[], [], [grouper], []]
    end

    it 'finds images' do
      content = Nokogiri::HTML('<html><img src="/"></html>')
      expect(c.parse(content)).to eq [[], [], [], [grouper]]
    end
  end

  describe '#mine' do
    it 'mines a URI' do
      c = Creep.new
      c.mine grouper
      expect(c.data.include? grouper).to eq TRUE
    end
  end

  describe '#scrape' do
    it 'scrapes a URI' do
      c = Creep.new
      c.scrape
      expect(c.data.size > 80).to eq TRUE
      expect(c.data.size < 150).to eq TRUE
    end
  end
end
