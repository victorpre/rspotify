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

    def play(device_id = nil, options = {})
      url = "me/player/play"
      url = device_id.nil? ? url : url+"?device_id=#{device_id}"

      request_body = options
      User.oauth_put(@user.id, url, request_body)
    end
  end
end
