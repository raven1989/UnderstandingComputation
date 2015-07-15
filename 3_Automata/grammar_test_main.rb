require_relative 'RegularExpression'
require 'treetop'

Treetop.load('pattern')
parse_tree = PatternParser.new.parse('(a(|b))*')
puts parse_tree.inspect
pattern = parse_tree.to_ast
puts pattern.inspect
puts pattern.matches?('')
puts pattern.matches?('a')
puts pattern.matches?('aaaaa')
puts pattern.matches?('aab')
puts pattern.matches?('aba')
puts pattern.matches?('abba')
