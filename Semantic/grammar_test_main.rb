require_relative 'semantic'
require 'treetop'

Treetop.load('simple')
parse_tree = SimpleParser.new.parse('while(x<5){x=x*3}')
# puts parse_tree.inspect
statement = parse_tree.to_ast
puts statement.inspect
puts (statement.evaluate({x:Number.new(1)})).inspect
puts ( eval(statement.to_ruby).call({x:1}) ).inspect
