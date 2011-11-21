##
# This is the Dnode response object.

# it gets its data from the server and not much more :D
module DNode
  class Response
    attr_reader :callbacks, :arguments, :method
    
    def initialize(line)
      resp = JSON(line)
      @method   = resp['method']
      @callbacks = resp['callbacks']
      @arguments = resp['arguments']
    end
    
  end
end