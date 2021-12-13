namespace :microsoft do
  desc "TODO"
  task retrieve_mails: :environment do
    puts "TOKEN = " + access_token
    token = access_token
    s = CalendarService.new
    s.exec(token)

  end

  def calendar
    # Get the IANA identifier of the user's time zone
    time_zone = get_iana_from_windows('Europe/Madrid')

    # Calculate the start and end of week in the user's time zone
    start_datetime = Date.today.beginning_of_week(:sunday).in_time_zone(time_zone).to_time
    end_datetime = start_datetime.advance(:days => 7)

    @events = get_calendar_view access_token, start_datetime, end_datetime, user_timezone || []
    #render json: @events
  rescue RuntimeError => e
    @errors = [
      {
        :message => 'Microsoft Graph returned an error getting events.',
        :debug => e
      }
    ]
  end


  def access_token
    token_hash = Token.last
    # Get the expiry time - 5 minutes
    expiry = Time.at(token_hash.expires_at - 3000)
    puts "ACCES TOKEN METHOD"
    if Time.now > expiry
      puts "TOKEN EXPIRED ! REFRESHING"
      # Token expired, refresh
      new_hash = refresh_tokens(token_hash)
      create_token(new_hash)
      new_hash[:access_token]
    else
      puts "TOKEN IS CORRECT"
      token_hash.token
    end
  end

  def refresh_tokens(token_hash)
    oauth_strategy = OmniAuth::Strategies::MicrosoftGraphAuth.new(
    nil, ENV['AZURE_APP_ID'], ENV['AZURE_APP_SECRET']
    )

    token = OAuth2::AccessToken.new(
    oauth_strategy.client, token_hash.token,
    :refresh_token => token_hash.refresh_token
    )

    # Refresh the tokens
    new_tokens = token.refresh!.to_hash.slice(:access_token, :refresh_token, :expires_at)
    new_tokens
  end

  def create_token(new_hash)
      token = Token.last
      token.token = new_hash[:access_token]
      token.refresh_token = new_hash[:refresh_token]
      token.expires_at = new_hash[:expires_at]
      token.save!
  end

end

