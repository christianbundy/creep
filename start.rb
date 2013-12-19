require_relative 'creep'

c = Creep.new(*ARGV)
c.scrape

puts c.data unless c == FALSE
