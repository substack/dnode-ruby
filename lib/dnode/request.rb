##
# This is the Dnode request object.

# it gets its data from the server and not much more :D
module DNode
  
  
  class Request
    include EventMachine::Deferrable
    attr_reader :data, :callbacks, :callback
    attr_accessor :id
    @@id = 0
    
    def initialize(method, *args, &callback)
      @id = @@id = @@id + 1
      @method = (method.respond_to? :match and method.match(/^\d+$/)) ? method.to_i : method
      @callback = callback || lambda {}
      @args = args.push "[Function]"
    end
    
    def prepare
      @callbacks = {@id => [@callback.arity]}
      @data = JSON({
        :method     => @method,
        :links      => [],
        :arguments  => @args,
        :callbacks  => @callbacks 
        })
    end
    
  end
end