module RSpotify
  class Player < Base

    def initialize(options = {})
      @device = if options['device']
        Device.new options['device']
      end
    end
  end
end
