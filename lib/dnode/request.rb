##
# This is the Dnode request object.

# it gets its data from the server and not much more :D
module DNode
  
  
  class Request
    include EventMachine::Deferrable
    attr_reader :data, :callbacks, :id, :callback

    @@id = 0
    
    def initialize(method, *args, &callback)
      @id = @@id = @@id + 1
      
      method = if method.respond_to? :match and method.match(/^\d+$/)
        then method.to_i
      else method
      end
      
      @callback = callback || lambda {}
      args.push "[Function]"
      
      @callbacks = {@id => [@callback.arity]}
      
      @data = JSON({
        :method => method,
        :links => [],
        :arguments => args,
        :callbacks =>  callbacks # Just on callback from us? That's a bit sad, but I guess the only way to go.
        })
    end
    
  end
end