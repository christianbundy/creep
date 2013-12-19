require 'simplecov'
SimpleCov.start
require_relative 'spec_helper.rb'
require_relative '../lib/creep'

describe Creep do
	grouper, approx_size = 'http://www.shopgab.com', 5

	describe '#new' do
		it 'fails with 0 parameters' do
			expect { Creep.new }.not_to raise_error
		end

		it 'takes a single parameter' do
			expect { Creep.new(grouper) }.not_to raise_error
		end

		it 'ignores extra parameters' do
			expect { Creep.new(grouper, 0) }.not_to raise_error
		end
	end

	describe '#download' do
		begin
			c = Creep.new grouper
		end

		it "doesn't fail with a real URL" do
			expect { c.download('http://requestb.in/qgfg5cqg') }.to_not raise_error
		end

		it 'retreives content for correct URIs' do
			content = c.download('http://requestb.in/qgfg5cqg')
			content.should_not eq(nil)
		end

		it 'retreives nil for incorrect URIS' do
			content = c.download('abc')
			content.should eq(nil)
		end
	end

	describe '#look_for' do
		begin
			c = Creep.new grouper
		end

		it 'returns an empty array with no content' do
			content = Nokogiri::HTML('')
			result = c.look_for 'a', 'b', content
			result.should eq([])
		end

		it 'returns an array of matches' do
			content = Nokogiri::HTML('<html><a b="/"></html>')
			result = c.look_for 'a', 'b', content
			result.should eq([grouper])
		end
	end

	describe '#audit_uri' do
		begin
			c = Creep.new grouper
		end

		it 'chomps "/" from URI' do
			uri = (c.audit_uri(grouper + '/'))
			uri.should eq(grouper)
		end

		it 'translates "/"" correctly' do
			uri = c.audit_uri('/')
			uri.should eq(grouper)
		end

		it 'ignores foreign addresses' do
			uri = c.audit_uri('http://example.com')
			uri.should eq(nil)
		end
	end

	describe '#parse' do
		begin
			c = Creep.new grouper
		end

		it 'returns nil for nil' do
			c.parse(nil).should eq(nil)
		end

		it 'finds links' do
			content = Nokogiri::HTML('<html><a href="/"></html>')
			parsed  = c.parse(content)

			parsed.should eq([[grouper], [], [], []])
		end

		it 'finds scripts' do
			content = Nokogiri::HTML('<html><script src="/"></html>')
			parsed  = c.parse(content)

			parsed.should eq([[], [grouper], [], []])
		end

		it 'finds stylesheets' do
			content = Nokogiri::HTML('<html><link href="/"></html>')
			parsed  = c.parse(content)

			parsed.should eq([[], [], [grouper], []])
		end

		it 'finds images' do
			content = Nokogiri::HTML('<html><img src="/"></html>')
			parsed  = c.parse(content)
			parsed.should eq([[], [], [], [grouper]])
		end
	end

	describe '#mine' do
		it 'mines a URI' do
			c = Creep.new grouper
			c.mine grouper
			c.data.include?(grouper).should be_true
		end
	end

	describe '#scrape' do
		it 'scrapes a URI' do
			c = Creep.new grouper
			c.scrape
			c.data.size.should be > (approx_size / 2)
			c.data.size.should be < (approx_size * 2)
		end
	end
end