require 'oauth2'

baseurl = "http://examplesierrahost.org"

client = OAuth2::Client.new('API_KEY_HERE', 'CLIENT_SECRET_HERE', :site => "#{baseurl}", :token_url => '/iii/sierra-api/v1/token')

token = client.client_credentials.get_token

beforeDate = Time.now.utc.iso8601.to_s
afterDate = (Time.now - (2*7*24*60*60)).utc.iso8601.to_s

response = token.get('iii/sierra-api/v1/bibs?createdDate=[' + afterDate + ',' + beforeDate + ']&deleted=false&suppressed=false')


# results is a Hash, containing one key/value: "entries"
results = response.parsed
# entries is an array, each value is a Hash.
entries = results["entries"]

# API returns results sorted by id, which tends to result in newer stuff last
# We want newer stuff first
entries = entries.sort_by!{|value| value.fetch("createdDate", "")}.reverse

puts "<h1>New titles added in the last two weeks</h1>"
entries.each do |value|
  recordUrl = baseurl + "record=b" + value.fetch("id", "").to_s
  createDate = Time.iso8601(value.fetch("createdDate", "")).to_s
  title = value.fetch("title", "")

  puts <<-eos

    <h2>#{title}</h2>
    <ul>
      <li>Added on: #{createDate}</li>
      <li><a href="#{recordUrl}">View in catalog</a></li>
    </ul>

  eos
end
