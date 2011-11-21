##
# This is the Dnode request object.

# it gets its data from the server and not much more :D
module DNode
  
  
  class Request
    include EventMachine::Deferrable
    attr_reader :data, :callbacks, :callback, :method
    attr_accessor :id
    @@id = -1
    
    def initialize(method, *args, &callback)
      @callback = callback || lambda {}
      @args     = args
      if (method.respond_to? :match and method.match(/^\d+$/)) 
        @id       = @@id = @@id + 1
        @method   = method.to_i
        @callbacks = {@id => [@callback.arity]}
      else
        @id       = "methods"
        @method   = method
        @callbacks = {}
      end
    end
    
    def prepare
      if @args.last.is_a? Proc
        @args[@args.length-1] = "[Function]"
      end
      
      @data = JSON({
        :method     => @method,
        :arguments  => @args,
        :callbacks  => @callbacks,
        :links      => [] 
      })
    end
  end
end