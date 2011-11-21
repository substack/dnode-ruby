require 'rubygems'
require 'dnode'

DNode.new({
    :f => proc { |x,cb| 
      cb.call(x + 1337) 
    },
    :g => proc { |x,cb| cb.call(x - 1337) }
}).listen(5050)
