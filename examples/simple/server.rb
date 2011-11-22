$: << "."
require File.dirname(__FILE__)+"/../../lib/dnode.rb"

EM.run do 
  server = DNode::Client.listen({
    :port => 5050,
    :methods => {
      :zing => proc { |n,cb| 
        cb.call(n*100) 
      }
    }
  }) 
end
