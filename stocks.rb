
module Stock
  require 'net/http'
  extend self
  def fetch(*symbols)
    Hash[*(symbols.collect { |symbol| [symbol, Hash[*(Net::HTTP.get('download.finance.yahoo.com','/d?f=nl1&s='+symbol).chop.split(',').unshift("Name").insert(2,"Price"))]];}.flatten)];
  end
end
# stock = Stock::fetch("MSFT")["MSFT"]["Price"].to_f