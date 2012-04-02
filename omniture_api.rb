
# https://developer.omniture.com/en_US/get-started/api-explorer
# https://github.com/msukmanowsky/ROmniture

require 'net/http'
require 'net/https'
require 'openssl'
require 'digest/md5'
require 'digest/sha1'
require 'base64'
require 'json'
require 'yaml'

# config
config   = YAML::load(File.open("omniture_config.yml"))
username = config["username"]
secret   = config["secret"]
server   = config["server"]

# Create the HTTP object
http = Net::HTTP.new(server, 443)
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
apiMethod = 'Report.QueueRanked'
path = '/admin/1.3/rest/?method=' + apiMethod
http.use_ssl = true

# Generate auth header
nonce = Digest::MD5.new.hexdigest(rand().to_s)
created = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
combo_string = nonce + created + secret
sha1_string =  Digest::SHA1.new.hexdigest(combo_string)
password = Base64.encode64(sha1_string).to_s.chomp("\n")

headers = {
  "X-WSSE" => "UsernameToken Username=\"#{username}\", PasswordDigest=\"#{password}\", Nonce=\"#{nonce}\", Created=\"#{created}\""
}

#
report = File.open("omniture_report.json").read
report = File.open(ARGV[0]).read unless ARGV[0].nil?

# Post the request to the API server
res = http.post(path, report, headers)

# Print Output
puts res.code, res.message
print res.body
