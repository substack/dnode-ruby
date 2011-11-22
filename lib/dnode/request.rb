##
# This is the Dnode request object.

# It invoques a request on the other side of the connection.
module DNode
  
  class Request
    attr_reader :data, :callbacks, :arguments, :method
    
    def initialize(method, args, links = [])
      @method     = method
      @links      = links
      @scrub      = Scrub.new
      scrubbed    = @scrub.scrub(args)
      @args       = scrubbed[:arguments]
      @callbacks  = scrubbed[:callbacks] 
    end
    
    def prepare
      @data = JSON({
        :method     => @method,
        :arguments  => @args,
        :callbacks  => @callbacks,
        :links      => @links
      })
    end
  end
end