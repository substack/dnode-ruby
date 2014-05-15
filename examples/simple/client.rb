$: << "."
require File.dirname(__FILE__)+"/../../lib/dnode.rb"

def go(client)
end

EM.run do 
  client = DNode::Client.connect() 
  EM.add_timer(1) do 
    client.zing(30000, proc { |x| 
      puts "x=<#{x}>" 
    })
  end # We need to wait a bit just to make sure that the first "methods have been excchanged."
end
