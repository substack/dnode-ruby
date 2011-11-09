##
# This is the Dnode client.

# it gets its data from the server and not much more :D
module DNode
  class Client < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    include Events::Emitter

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
      params = from_args(*args, &block).merge(:instance => @instance)
      EM.connect(params[:host], params[:port], DNode::Client, params)
    end

    ##
    # Called by EM loop when connected.
    def initialize params
      @block = params[:block] || lambda {}
      @instance = params[:instance] || {}
      @scrub = Scrub.new
      @remote = {}

      request('methods', if @instance.is_a? Proc
      then @instance.call(*[@remote,self][0..@instance.arity-1])
    else @instance
    end)
  end

  ##
  # Called when connection terminates
  def unbind
  end

  ##
  # Called when new line was received
  def receive_line(line)
    handle(JSON(line))
  end

  ##
  # Handling request
  def handle req
    args = @scrub.unscrub(req) do |id|
      lambda { |*argv| self.request(id, *argv) }
    end

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
      @remote.update(args[0])
      js = JSObject.create(@remote)

      if @block.arity === 0 then
        @block.call
      else
        @block.call(*[ js, self ][ 0 .. @block.arity - 1 ])
      end
      self.emit('remote', js)
      self.emit('ready')
    end
  end

  ##
  # Sending request
  def request(method, *args)
    scrubbed = @scrub.scrub(args)
    data = JSON({
      :method => (
      if method.respond_to? :match and method.match(/^\d+$/)
        then method.to_i
      else method
      end
      ),
      :links => [],
      }.merge(scrubbed))
      send_data(data + "\n")
    end
  end

end