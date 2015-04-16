require 'logstash/environment'

require_relative '../helper/url_helper'
require_relative 'user'

# This class creates a connection to keystone
module LogStash::Outputs
  module Keystone
    class KeystoneClient
      def initialize host, port, user
        @user = user
      	@keystone_client = RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, port, '/v2.0').to_s)
      end
    
      # Authenticate against keystone and get token back
      def get_token
        json_resp = handle_response(authenticate)
      	json_resp['access']['token']['id']
      end
    
      private
      def get_auth_hash
      	"{\"auth\": {\"tenantName\": \"#{@user.tenant}\", \"passwordCredentials\": {\"username\": \"#{@user.username}\", \"password\": \"#{@user.password}\"}}}"
      end
    
      def authenticate
        @keystone_client['tokens'].post(get_auth_hash, :content_type => 'application/json', :accept => 'application/json')
      end

      def handle_response response
        raise LogStash::PluginLoadingError, "Failed to authorize user" unless response.is_a? String and response.include? ('token')
        parse_string_to_json response
      end

      def parse_string_to_json response
        JSON.parse(response)
      end
    
    end
  end
end