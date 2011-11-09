$: << "."
require File.dirname(__FILE__)+"/../../lib/dnode.rb"

DNode::Client.connect() do |server|
  EM.add_periodic_timer(1) do
    server.f(30000, proc { |x| puts "x=<#{x}>" })
  end
end
