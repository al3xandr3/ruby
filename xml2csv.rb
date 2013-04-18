
# http://www.ruby-forum.com/topic/1595950
# http://stackoverflow.com/questions/5400841/parse-data-from-multiple-xml-files-and-output-to-csv-file
# http://girliemangalo.wordpress.com/2009/08/14/convert-xml-to-csv-with-nokogiri-ruby-gem/

require 'nokogiri'

doc = Nokogiri::XML(xml)
content = doc.search('item').map { |i| 
  i.search('data').map { |d| d.text }
}

content.each do |c|
  puts c.join(',')
end

if __FILE__ == $0
  puts "TODO"
end
