require 'microsoft_graph_auth'
require 'oauth2'

namespace :get_token do
ENV['AZURE_APP_ID'] = 'b89780ce-f5f4-486c-8690-39e60b8b96a7'
ENV['AZURE_APP_SECRET'] = 'Lbf7Q~By1HYe.dCwTQfjrWEi_3yFPvLb_U1zi'
ENV['AZURE_SCOPES'] = 'openid profile email offline_access user.read mailboxsettings.read calendars.readwrite'

	task :get_token do
	  puts "hi"
	end

    
	def access_token
	  puts "as"
	  token_hash = session[:graph_token_hash]

	  # Get the expiry time - 5 minutes
	  expiry = Time.at(token_hash[:expires_at] - 300)

	  if Time.now > expiry
	    # Token expired, refresh
	    new_hash = refresh_tokens token_hash
	    new_hash[:token]
	  else
	    token_hash[:token]
	  end
	end

	def refresh_tokens(token_hash)
		oauth_strategy = OmniAuth::Strategies::MicrosoftGraphAuth.new(
		nil, ENV['AZURE_APP_ID'], ENV['AZURE_APP_SECRET']
		)

		token = OAuth2::AccessToken.new(
		oauth_strategy.client, token_hash[:token],
		:refresh_token => token_hash[:refresh_token]
		)

		# Refresh the tokens
		new_tokens = token.refresh!.to_hash.slice(:access_token, :refresh_token, :expires_at)

		# Rename token key
		new_tokens[:token] = new_tokens.delete :access_token

		# Store the new hash
		session[:graph_token_hash] = new_tokens
	end

end
