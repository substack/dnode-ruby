##
# This is the Dnode client.

# it gets its data from the server and not much more :D
module DNode
  class Client < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    attr_reader :requests

    def self.from_args *args, &block
      types = args.inject({}) { |acc,x| acc.merge(x.class.to_s => x) }
      kw = types['Hash'] || {}
      {
        :host => kw['host'] || kw[:host] || types['String'] || 'localhost',
        :port => kw['port'] || kw[:port] || types['Fixnum'] || 5050,
        :block => block || kw['block'] || kw[:block] || types['Proc'],
      }
    end

    ##
    # sugar for those people who don't want to run their reactor
    def self.connect *args, &block
      EM.run do 
        start args, &block
      end
    end

    ##
    # Initiates the connection. 
    def self.start *args, &block
      params = from_args(*args, &block)
      EM.connect(params[:host], params[:port], DNode::Client, params)
    end

    ##
    # Called by EM loop when connected.
    def initialize params
      @block = params[:block] || lambda {}
      @requests = {} # A set of all current requests.
      
      request = Request.new("methods", {}) do |response|
        update_methods(response.callbacks)
      end 
      
      request.id = "methods"
      send(request)
    end

    ##
    # Called when connection terminates
    def unbind
      puts 'unbind'
    end

    ##
    # Called when new line was received
    def receive_line(line)
      puts ">> #{line}"
      response = Response.new(line)
      request = @requests[response.method]
      request.callback.call(response) unless request.nil?
    end
    
    ##
    # Re-defines methods locally based on remote's methods.
    def update_methods(remotes)
      remotes.each do |remote|
        # Here we need to add the right methods required for everything to run smooth!
        self.class.send(:define_method, remote[1][1]) do |*args|
          block = args.pop
          request = Request.new(remote[1][0], *args) do |response|
            block.call(response.arguments)
          end
          send(request)
        end
      end
      @block.call
    end
    
    def send(request)
      request.prepare
      if request.method == "methods"
        @requests["methods"] = request
      else
        request.callbacks.each do |callback|
          @requests[callback[0]] = request
        end
      end
      puts "<< #{request.data}"
      send_data(request.data + "\n")
    end
  end


end