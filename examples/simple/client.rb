$: << "."
require File.dirname(__FILE__)+"/../../lib/dnode.rb"

EM.run {
  server = DNode::Client.connect()
  EM.add_periodic_timer(1) do
      server.f(30000, proc { |x| puts "x=<#{x}>" })
  end
  
}