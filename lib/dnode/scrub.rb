class Scrub
    def initialize
        @callbacks = {}
        @last_id = 0
    end
    
    attr_accessor :callbacks
    
    def scrub args
        callbacks = {}
        walked = Walk.new(args).walk do |node|
            if node.value.is_a? Proc then
                id = @last_id
                @last_id += 1
                @callbacks[id] = node.value
                callbacks[id] = node.path.clone
                node.value = '[Function]'
            end
        end
        { :arguments => walked, :callbacks => callbacks }
    end
    
    def unscrub req, &block
        args = Walk.new(req['arguments']).walk do |node|
            path = node.path.map(&:to_s)
            pair = req['callbacks'].detect{ |_,p| p.map(&:to_s) == path }
            unless pair.nil? then
                id = pair.first
                node.value = block.call(id)
            end
        end
    end
end