require 'treetop'
require_relative 'LambdaCalculus'

Treetop.load('flaw')
ptree = RightCombinationParser.new.parse('a[b][c][d][e]')
puts ptree.inspect
puts ptree.arguments
puts ptree.to_ast

multiply = RightCombinationParser.new.parse('4*7*9',root: :multiply)
puts multiply.to_ast
#右结合
puts multiply.left.to_ast,multiply.right.to_ast
