##
# This is the Dnode request object.

# it gets its data from the server and not much more :D
module DNode
  
  
  class Request
    include EventMachine::Deferrable
    attr_reader :data, :callbacks, :id, :block

    @@id = 0
    
    def initialize(method, *args, &block)
      @id = @@id = @@id + 1
      
      method = if method.respond_to? :match and method.match(/^\d+$/)
        then method.to_i
      else method
      end
      
      @block = block || lambda {}
      args.push "[Function]"
      
      @callbacks = {@id => [@block.arity]}
      
      @data = JSON({
        :method => method,
        :links => [],
        :arguments => args,
        :callbacks =>  callbacks # Just on callback from us? That's a bit sad, but I guess the only way to go.
        })
    end
    
  end
end