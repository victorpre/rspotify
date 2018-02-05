module RSpotify
  class Player < Base

    def initialize(user, options = {})
      @user = user

      @repeat_state  = options['repeat_state']
      @shuffle_state = options['shuffle_state']
      @progress      = options['progress_ms']
      @is_playing    = options['is_playing']

      @track = if options['track']
        Track.new options['track']
      end

      @device = if options['device']
        Device.new options['device']
      end
    end

    def playing?
      is_playing
    end

    def play_context(device_id=nil, uri)
      params = {"context_uri": uri}
      play(device_id, params)
    end

    def play_tracks(device_id=nil, uris)
      params = {"uris": uris}
      play(device_id, params)
    end

    # Allow browser to trigger playback in the user's currently active spotify app.
    # User must be a premium subscriber for this feature to work.
    def play_track(device_id=nil, uri)
      params = {"uris": [uri]}
      play(device_id, params)
    end

    # Play the user's currently active player
    #
    # @example
    #           player = user.player
    #           player.play
    def play(device_id = nil, params = {})
      url = "me/player/play"
      url = device_id.nil? ? url : url+"?device_id=#{device_id}"

      User.oauth_put(@user.id, url, params.to_json)
    end

    # Pause the user's currently active player
    #
    # @example
    #           player = user.player
    #           player.pause
    def pause
      url = 'me/player/pause'
      User.oauth_put(@user.id, url, {})
    end

    def volume(percent)
      url = "me/player/volume?volume_percent=#{percent}"

      User.oauth_put(@user.id, url, {}.to_json)
    end
  end

  def currently_playing
    url = "me/player/currently-playing"
    response = RSpotify.resolve_auth_request(@user.id, url)
    return response if RSpotify.raw_response
    Track.new response["item"]
  end

  # Get the current user’s recently played tracks. Requires the *user-read-recently-played* scope.
  #
  # @param limit  [Integer] Optional. The number of entities to return. Default: 20. Minimum: 1. Maximum: 50.
  # @return [Array<Track>]
  #
  # @example
  #           recently_played = user.recently_played
  #           recently_played.size       #=> 20
  #           recently_played.first.name #=> "Ice to Never"
  def recently_played(limit: 20)
    url = "me/player/recently-played?limit=#{limit}"
    response = RSpotify.resolve_auth_request(@id, url)
    return response if RSpotify.raw_response

    json = RSpotify.raw_response ? JSON.parse(response) : response
    json['items'].map do |t|
      data = t['track']
      data['played_at'] = t['played_at']
      data['context_type'] = t['context']['type'] if t['context']
      Track.new data
    end
  end
end
