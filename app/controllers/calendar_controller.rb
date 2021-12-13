# Calendar controller
class CalendarController < ApplicationController
  include GraphHelper

  def index
    # Get the IANA identifier of the user's time zone
    time_zone = get_iana_from_windows(user_timezone)
    puts "*************TIMEZONE 1 : "+ time_zone
    # Calculate the start and end of week in the user's time zone
    start_datetime = Date.today.beginning_of_week(:sunday).in_time_zone(time_zone).to_time
    end_datetime = start_datetime.advance(:days => 20)

    #@events = get_calendar_view access_token, start_datetime, end_datetime, user_timezone || []
    emails = get_emails(access_token)
    
    render json: @events
  rescue RuntimeError => e
    @errors = [
      {
        :message => 'Microsoft Graph returned an error getting events.',
        :debug => e
      }
    ]
  end
end
