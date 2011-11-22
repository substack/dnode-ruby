##
# This is the Dnode client.

# it gets its data from the server and not much more :D
module DNode
  class NotConnected < StandardError; end
  class Client < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    attr_reader :requests

    ##
    # sugar for those people who don't want to run their reactor
    def self.connect *args, &block
      EM.run do 
        start_client *args, &block
      end
    end

    ##
    # sugar for those people who don't want to run their reactor. the first arguments needs to be a port number
    def self.listen *args, &block
      EM.run do 
        start_server *args, &block
      end
    end

    ##
    # Initiates the connection to an existing/running server (dnode protocol is actually symetrical, so servers are clients. We just need to have a first running client which will act as a server)
    def self.start_client *params, &block
      params = params[0]
      params ||= {} 
      params[:host] ||= 'localhost'
      params[:port] ||= 5050
      params[:block] = block || lambda {}
      params[:methods] ||= {}
      EM.connect(params[:host], params[:port], DNode::Client, params)
    end
    
    ##
    # Initiates the connection. 
    def self.start_server *params, &block
      params = params[0]
      params ||= {} 
      params[:host] ||= 'localhost'
      params[:port] ||= 5050
      params[:block] = block || lambda {}
      params[:methods] ||= {}
      EM.start_server(params[:host], params[:port], DNode::Client, params)
    end

    ##
    # Called by EM loop when connected.
    def initialize params
      @scrub      = Scrub.new
      @block = params[:block]
      @methods  = {} # A hash to keep track of all methods.
      
      # let's add all the methods.
      # params[:methods].each do |method, proc|
      #   method = Method.new(method, &proc)
      #   @methods[method.id] = method
      # end
      
      # Let's all send the methods request
      args = Hash[*(@methods.map() {|id,m|
        [m.name, m.proc]
      }.flatten)]
      callbacks = {}
      request = Request.new('methods', [args])
      send(request)
    end

    ##
    # Called when connection terminates
    # We need to use this to prevent more calls!
    def unbind
      @ready = false
    end

    ##
    # Called when new line was received
    def receive_line(line)
      puts ">> #{line}"
      
      resp = JSON(line)
      if(resp['method'] == "methods")
        # Named methods
        arguments = @scrub.unscrub(resp) do |id|
          id
        end
        remote_methods = arguments[0]
        remote_methods.each do |name, id|
          # Here we need to add the right methods required for everything to run smooth!
          self.class.send(:define_method, name) do |*args|
            if @ready
              scrubbed    = @scrub.scrub(args)
              # Let's register the new methods (from the callbacks)
              scrubbed[:callbacks].each do |c|
                @methods[c[0]] = Method.new(c[0], c[0], args[c[1][0]])
              end
              
              data = JSON({
                :method     => id.to_i,
                :links      => []
              }.merge(scrubbed))
              puts "<< #{data}"
              send_data(data + "\n")
            else
              raise NotConnected
            end
          end
        end if remote_methods
        @ready = true
        @block.call
      else
        # Unnamed methods (used when callbacks are provided as arguments)
        arguments = @scrub.unscrub(resp) do |id|
          lambda { |*args| 
            if @ready
              request = Request.new(id.to_i, args)
              send(request)
            else
              raise NotConnected
            end
          }
        end

        method = @methods[resp['method']]
        method.proc.call(arguments) unless method.nil?
      end
    end
    
    ##
    # Methods that sends a request. It also binds the request to the @requests hash so that we can look it up after a response.
    def send(request)
      request.prepare
      puts "<< #{request.data}"
      send_data(request.data + "\n")
    end
  end


end