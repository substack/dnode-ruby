$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
 
require 'rubygems'
require 'eventmachine'

require 'dnode/client'
require 'dnode/conn'
require 'dnode/jsobject'
require 'dnode/scrub'
require 'dnode/walk'
require 'dnode/request'
require 'dnode/response'

module DNode

end
