require_relative 'DPDA'
require_relative 'LexicalAnalyzer'
require_relative 'CFGAnalyzer'
require 'set'

puts '---------------------------------Stack---------------------------------------'
stack = Stack.new(['a', 'b', 'c', 'd', 'e'])
puts stack
puts stack.top
puts stack.pop
puts stack.push('x')
puts '----------------------------PDAConfiguration---------------------------------'
config = PDAConfiguration.new(1, Stack.new(['$']))
puts config
puts '--------------------------------PDARule--------------------------------------'
rule = PDARule.new(1,'(',2,'$',['b','$'])
puts rule
puts rule.applies_to?(config, '(')
puts '-----------------------------------------------------------------------------'
puts rule.follow(config)
puts '------------------------------PDARulebook------------------------------------'
#这个规则集可以识别括号对串
rulebook = PDARulebook.new([
	PDARule.new(1,'(',2,'$',['b','$']),
  PDARule.new(2,'(',2,'b',['b','b']),
	PDARule.new(2,')',2,'b',[]),
	PDARule.new(2,nil,1,'$',['$'])
])
puts rulebook
puts rulebook.next_configuration(config, '(')
puts '----------------------------------DPDA---------------------------------------'
dpda = DPDA.new(config, [1], rulebook)
puts dpda
puts '-----------------------------------------------------------------------------'
# dpda.read_string('()((()))')
dpda.read_string('())')
puts dpda.current_config, dpda.accepting?
puts '-----------------------------------------------------------------------------'
dpda_design = DPDADesign.new(1,'$',[1],rulebook)
puts dpda_design
puts dpda_design.accepts?('()')
puts dpda_design.accepts?(')(())')
puts dpda_design.accepts?('((())(()))')
puts '------------------------------NPDARulebook-----------------------------------'
#这个规则集可以识别由ab组成的偶数回文串
npda_rulebook = NPDARulebook.new([
	PDARule.new(1,'a',1,'$',['a','$']),
	PDARule.new(1,'b',1,'$',['b','$']),
	PDARule.new(1,'a',1,'a',['a','a']),
	PDARule.new(1,'b',1,'a',['b','a']),
	PDARule.new(1,'a',1,'b',['a','b']),
	PDARule.new(1,'b',1,'b',['b','b']),
	PDARule.new(1,nil,2,'a',['a']),
	PDARule.new(1,nil,2,'b',['b']),
	# PDARule.new(1,nil,2,'$',['$']),  #这一条决定空字符串是回文
	PDARule.new(2,'a',2,'a',[]),
	PDARule.new(2,'b',2,'b',[]),
	PDARule.new(2,nil,3,'$',['$']),
])
puts npda_rulebook
puts '----------------------------------NPDA---------------------------------------'
npda = NPDA.new(Set[PDAConfiguration.new(1,Stack.new(['$']))], [3], npda_rulebook)
puts npda
puts '-----------------------------------------------------------------------------'
puts npda.current_configs.inspect
puts '-----------------------------------------------------------------------------'
puts npda.read_string('ababbaba') 
puts npda.current_configs.inspect
puts npda.accepting?
puts '-------------------------------NPDADesign------------------------------------'
npda_design = NPDADesign.new(1, '$', [3], npda_rulebook)
puts npda_design
puts '-----------------------------------------------------------------------------'
puts npda_design.accepts?('aa')
puts npda_design.accepts?('')
puts npda_design.accepts?('aba')
puts npda_design.accepts?('abba')
puts '-----------------------------LexicalAnalyzer---------------------------------'
lexical_analyzer = LexicalAnalyzer.new('str')
puts lexical_analyzer.rule_matching('if')
puts '-----------------------------------------------------------------------------'
puts LexicalAnalyzer.new('while (x<5) { x=x*3 }').analyze.join
puts '-----------------------------------------------------------------------------'
puts LexicalAnalyzer.new('x = falsehood').analyze
puts '-------------------------------CFGAnalyzer-----------------------------------'
cfg_analyzer =  CFGAnalyzer.new('while (x<5) {x = x*3 }')
puts CFGAnalyzer.rulebook
puts '-----------------------------------------------------------------------------'
puts cfg_analyzer.analyze
puts CFGAnalyzer.new('x=x<2').analyze
puts CFGAnalyzer.new('x<x<2').analyze
