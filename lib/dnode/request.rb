##
# This is the Dnode request object.

# it gets its data from the server and not much more :D
module DNode
  class Request
    include EventMachine::Deferrable
    attr_reader :data
    
    def initialize(method, *args, &block)
      
      @scrub = Scrub.new
      scrubbed = @scrub.scrub(args)
      @block = block
      
      @data = JSON({
        :method => (
        if method.respond_to? :match and method.match(/^\d+$/)
          then method.to_i
        else method
        end
        ),
        :links => [],
        }.merge(scrubbed))
        
    end
    
  end
end