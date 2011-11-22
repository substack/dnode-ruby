##
# This represents a method

# it can either be a "default" method or a method called as a response
# Each client has a set of methods, indexed by the its id, which is either "methods" or an integer.
# Each method has a name, and a proc as well
module DNode
  class Method
    attr_accessor :id, :name, :proc
    @@id = -1
    
    def initialize(name,  &block)
      if name == "methods"
        @id = "methods"
      else
        @id = (@@id = @@id + 1).to_s
      end
      @name = name
      @proc = block
    end
    
  end
end