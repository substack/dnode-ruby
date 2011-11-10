##
# This is the Dnode response object.

# it gets its data from the server and not much more :D
module DNode
  class Response
    
    def initialize(line, connection)
      @scrub = Scrub.new
      @connection = connection
      req = JSON(line)
      
      puts req.inspect
      
      if req['method'].is_a? Integer then
        id = req['method']
        cb = @scrub.callbacks[id]
        if cb.arity < 0 then
          cb.call(*JSObject.create(args))
        else
          argv = *JSObject.create(args)
          padding = argv.length.upto(cb.arity - 1).map{ nil }
          argv = argv.concat(padding).take(cb.arity)
          cb.call(*argv)
        end
      elsif req['method'] == 'methods' then
        @connection.update_methods(args[0])
      end
    end

  end
end