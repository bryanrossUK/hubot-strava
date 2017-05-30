# Description:
#   Get the latest activities from your Strava friends.
#
# Commands:
#   strava           - see you and your friends recent activity
#   strava friends   - list your friends
#   strava user <id> - show the details of a strava user
#
# Configuration:
#   HUBOT_STRAVA_API_URL - optional URL to Strava API Endpoint
#   HUBOT_STRAVA_API_ACCESS_TOKEN - your Strava API Access Token

process.env.HUBOT_STRAVA_API_URL ||= 'https://www.strava.com/api/v3'
process.env.HUBOT_STRAVA_API_ACCESS_TOKEN

strava_url  = process.env.HUBOT_STRAVA_API_URL
strava_auth = 'Bearer ' + process.env.HUBOT_STRAVA_API_ACCESS_TOKEN

module.exports = (robot) ->
  robot.respond /strava$/i, (msg) ->
    showFriendsActivity msg

  robot.respond /strava friends$/i, (msg) ->
    showFriends msg

  robot.respond /strava user (.+)$/i, (msg) ->
    showAthlete msg.match[1].trim(), msg


  ##
  # Check for HTTP Errors
  #
  checkHTTPErrors = (err, res, body, msg) ->
    if err
      robot.logger.error err
      msg.send err
      return false
    if res.statusCode != 200
      robot.logger.error res
      obj = JSON.parse(body)
      msg.send "#{res.statusCode}: #{obj.meta.error_detail}"
      return false
    true

  ##
  # Show Friends
  #
  showFriends = (msg) ->
    url = strava_url + '/athlete/friends'
    msg.http(url)
    .headers(Authorization: strava_auth, Accept: 'application/json')
    .get() (err, res, body) ->
      return unless checkHTTPErrors err, res, body, msg
      #robot.logger.info body
      result = JSON.parse(body)
      if result.length > 0
        friends = []
        for friend in result
          friends.push "#{friend.firstname} #{friend.lastname} (#{friend.id})"
        msg.send friends.join ', '
      else
	      msg.send "Your robot has no friends."

  ##
  # Show Friends Activity
  #
  showFriendsActivity = (msg) ->
    url = strava_url + '/activities/following'
    msg.http(url)
    .headers(Authorization: strava_auth, Accept: 'application/json')
    .get() (err, res, body) ->
      return unless checkHTTPErrors err, res, body, msg
      #robot.logger.info body
      result = JSON.parse(body)
      if result.length > 0
        activities = []
        for activity in result[..4]
          distance_in_miles = Number((activity.distance * 0.000621371).toFixed(1))
          activities.push "#{activity.athlete.firstname} did a #{distance_in_miles} mile #{activity.type} in #{activity.location_city} called '#{activity.name}'."
        msg.send activities.join '\n '
      else
        msg.send "Your friends haven't done anything."

  ##
  # Show Athlete
  #
  showAthlete = (athleteID, msg) ->
    unless athleteID
      msg.send 'Must provide an athlete ID.'
      return

    url = strava_url + '/athletes/' + athleteID
    msg.http(url)
    .headers(Authorization: strava_auth, Accept: 'application/json')
    .get() (err, res, body) ->
      return unless checkHTTPErrors err, res, body, msg
      #robot.logger.info body
      athlete = JSON.parse(body)

      msg.send "Name: #{athlete.firstname} #{athlete.lastname}"
      msg.send "Location: #{athlete.city}, #{athlete.state}, #{athlete.country}"
      msg.send "Profile: #{athlete.profile_medium}"
