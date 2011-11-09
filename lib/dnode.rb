require 'eventmachine'
require 'dnode/conn'
require 'json'
require 'socket'

class DNode
    def initialize obj={}
        @instance = obj
    end
    
    def from_args *args, &block
        types = args.inject({}) { |acc,x| acc.merge(x.class.to_s => x) }
        kw = types['Hash'] || {}
        {
            :host => kw['host'] || kw[:host] || types['String'] || 'localhost',
            :port => kw['port'] || kw[:port] || types['Fixnum'],
            :block => block || kw['block'] || kw[:block] || types['Proc'],
        }
    end
    private :from_args
    
    def handle_conn c, conn
        c.extend EM::P::LineText2
        (class << c; self; end).send(:define_method, 'receive_line') do |line|
            conn.handle(JSON(line))
        end
    end
    private :handle_conn
    
    def connect *args, &block
        params = from_args(*args, &block).merge(:instance => @instance)
        EM.run do EM.connect(params[:host], params[:port]) do |c|
            conn = Conn.new(params.merge :conn => c)
            handle_conn(c, conn)
        end end
    end
    
    class Listener < EM::Connection
    end
    
    ##
    # Call sthis when you have no EM running.
    def listen *args, &block
        params = from_args(*args, &block).merge(:instance => @instance)
        EM.run do
            start(params, &block)
        end
    end
    
    ##
    # Call this when an EventLoop is already running
    def start(params, &block)
          EM.start_server(params[:host], params[:port], Listener) do |c|
              conn = Conn.new(params.merge :conn => c)
              handle_conn(c, conn)
          end
      end
    end
    
end
