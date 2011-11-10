##
# This is the Dnode response object.

# it gets its data from the server and not much more :D
module DNode
  class Response
    
    def initialize(line, connection)
      @connection = connection
      resp = JSON(line)
      if resp['method'].is_a? Integer 
        request = @connection.requests[resp['method']]
        request.callback.call(*resp['arguments'])
      elsif resp['method'] == 'methods' 
        @connection.update_methods(resp['callbacks'])
      end
    end

  end
end