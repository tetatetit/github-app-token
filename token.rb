#!/usr/bin/env ruby

# Taken from [Authenticating as a GitHub App](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
# sample

require 'openssl'
require 'jwt'  # https://rubygems.org/gems/jwt
require 'json'
require 'rest-client'

# Private key contents
private_pem = STDIN.read
private_key = OpenSSL::PKey::RSA.new(private_pem)

# Generate the JWT
payload = {
  # issued at time
  iat: Time.now.to_i,
  # JWT expiration time (10 minute maximum)
  exp: Time.now.to_i + (10 * 60),
  # GitHub App's identifier
  iss: ARGV[0]
}


jwt = JWT.encode(payload, private_key, "RS256")
headers = {
   :Authorization => "Bearer #{jwt}",
   :Accept => "application/vnd.github.machine-man-preview+json"
}
installations_endpoint = 'https://api.github.com/app/installations'

begin
  retries ||= 0

  installations = RestClient.get(
    installations_endpoint, headers)
  installationId = JSON.parse(installations)[0]['id']

  access_tokens = RestClient.post(
    "#{installations_endpoint}/#{installationId}/access_tokens", {}, headers)
  puts JSON.parse(access_tokens)['token']
rescue
  sleep 1
  retry if (retries += 1) < 3
end
