require 'httparty'

GRAPH_HOST = 'https://graph.microsoft.com'.freeze
class CalendarService
  def exec(access_token)

    time_zone = 'Africa/Lagos'
    puts "CALENDAR SERVICE"
    # Calculate the start and end of week in the user's time zone
    start_datetime = Date.today.beginning_of_week(:sunday).in_time_zone(time_zone).to_time
    end_datetime = start_datetime.advance(:days => 7)
   # puts get_calendar_view access_token, start_datetime, end_datetime, 'W. Central Africa Standard Time'
    puts get_emails(access_token)
   # update_email('as')
   # @events = get_calendar_view access_token, start_datetime, end_datetime, 'Europe/Madrid' || []
  end


def update_email(id)
  id="AAMkAGU0YzA0YzE3LWNhYjMtNGQ5My1iMDY1LTkyNGEwOTA5M2JkNABGAAAAAABg9nGnyTG2Qbw6m7WQtLSqBwDNbNXbA2d6SqBIOL-5HyZWAAAAAAEMAADNbNXbA2d6SqBIOL-5HyZWAAB6kh3LAAA="
  get_events_url = "/v1.0/me/messages/#{id}"
  headers = {
    'Content-Type' => "application/json"

  }

  query = {  
    '$top' => 2,
    "$select"=>"subject",
    "$filter"=>"isRead eq false",
    "$orderby" => 'receivedDateTime desc'
  }

  response = make_api_call 'GET', get_events_url, token, headers, query
  puts response

end


def get_emails(token)
  get_events_url = '/v1.0/me/mailFolders/inbox/messages'
  headers = {
    'Prefer' => "outlook.body-content-type=html"

  }

  query = {  
    '$top' => 1,
    "$select"=>"subject,id,body",
    "$filter"=>"isRead eq false",
    "$orderby" => 'receivedDateTime desc'
  }

  response = make_api_call 'GET', get_events_url, token, headers, query
  puts response
  puts "####### subject ######"
  parsed_response = response.parsed_response['value']
  arr = []
  parsed_response.each do |mail| 
    arr << mail["body"] 
  end

  arr.each do |body| 
    puts "================================="
    puts body
    puts "================================="
  end
  
end

def get_calendar_view(token, start_datetime, end_datetime, timezone)
  get_events_url = '/v1.0/me/calendarview'
  headers = {
    'Prefer' => "outlook.timezone=\"#{timezone}\""

  }
  puts "start time :"+ start_datetime.to_s
  puts "timezone :" + timezone
  query = {
    'startDateTime' => start_datetime.iso8601,
    'endDateTime' => end_datetime.iso8601,
    '$select' => 'subject,organizer,start,end',
    '$orderby' => 'start/dateTime',
    '$top' => 50
  }

  response = make_api_call 'GET', get_events_url, token, headers, query
  puts response
  raise response.parsed_response.to_s || "Request returned #{response.code}" unless response.code == 200

  response.parsed_response['value']
end


  def make_api_call(method, endpoint, token, headers = nil, params = nil, payload = nil)
    headers ||= {}
    headers[:Authorization] = "Bearer #{token}"
    headers[:Accept] = 'application/json'

    params ||= {}

    case method.upcase
    when 'GET'
      HTTParty.get "#{GRAPH_HOST}#{endpoint}",
                   :headers => headers,
                   :query => params
    when 'POST'
      headers['Content-Type'] = 'application/json'
      HTTParty.post "#{GRAPH_HOST}#{endpoint}",
                    :headers => headers,
                    :query => params,
                    :body => payload ? payload.to_json : nil
    else
      raise "HTTP method #{method.upcase} not implemented"
    end

  end
end
