require_relative 'FA'
require_relative 'RegularExpression'

#DFA
puts '----------------------------------DFA----------------------------------------'
rulebook = DFARulebook.new([
											 FARule.new(1, 'a', 2), FARule.new(1, 'b', 1), 
											 FARule.new(2, 'a', 2), FARule.new(2, 'b', 3), 
											 FARule.new(3, 'a', 3), FARule.new(3, 'b', 3), 
])
puts rulebook.inspect
puts rulebook.next_state(1, 'a')
puts rulebook.next_state(1, 'b')
puts rulebook.next_state(2, 'b')

dfa = DFA.new(1, [3], rulebook)
puts dfa.accepting?
dfa.read_character('b')
puts dfa.accepting?
dfa.read_character('a')
puts dfa.accepting?
dfa.read_character('b')
puts dfa.accepting?

dfa.read_string('baaab')
puts dfa.accepting?  
dfa_design = DFADesign.new(1, [3], rulebook)
puts dfa_design.accepts?('a')
puts dfa_design.accepts?('baa')
puts dfa_design.accepts?('baba')

#NFA
puts '----------------------------------NFA----------------------------------------'
rulebook1 = NFARulebook.new([
														FARule.new(1,'a',1), FARule.new(1,'b',1),
														FARule.new(1,'b',2), FARule.new(2,'a',3),
														FARule.new(2,'b',3), FARule.new(3,'a',4),
														FARule.new(3,'b',4)
])
puts rulebook1.rules_for(1,'b')
puts rulebook1.follow_rules_for(1,'b')
puts rulebook1.next_states(Set[1],'b').inspect
puts rulebook1.next_states(Set[1,2],'a').inspect
puts rulebook1.next_states(Set[1,3],'b').inspect
puts '-----------------------------------------------------------------------------'
nfa = NFA.new(Set[1], [4], rulebook1)
nfa.read_character('b'); puts nfa.accepting?
nfa.read_character('a'); puts nfa.accepting?
nfa.read_character('b'); puts nfa.accepting?
nfa = NFA.new(Set[1], [4], rulebook1)
nfa.read_string('bab'); puts nfa.accepting?
puts '-----------------------------------------------------------------------------'
nfa_design = NFADesign.new(1, [4], rulebook1)
puts nfa_design.inspect
puts nfa_design.accepts?('bab')
puts nfa_design.accepts?('bbbbb')
puts nfa_design.accepts?('bbabb')
puts '----------------------------free-move----------------------------------------'
rulebook2 = NFARulebook.new([
														FARule.new(1,nil,2),FARule.new(1,nil,4),
														FARule.new(2,'a',3),FARule.new(3,'a',2),
														FARule.new(4,'a',5),FARule.new(5,'a',6),FARule.new(6,'a',4)
])
nfa_design = NFADesign.new(1, [2,4], rulebook2)
puts nfa_design.inspect
puts nfa_design.accepts?('aa')
puts nfa_design.accepts?('aaa')
puts nfa_design.accepts?('aaaaa')
#Regular Expression
puts '--------------------------Regular-Expression---------------------------------'
mix = Repeat.new(
	Choose.new(
		Concatenate.new(Literal.new('a'), Literal.new('b')),
		Literal.new('a')
))
puts mix.inspect
puts '-----------------------------------------------------------------------------'
nfa_empty = Empty.new.to_nfa_design
puts nfa_empty.accepts?('')
puts nfa_empty.accepts?(' ')
puts nfa_empty.accepts?('a')
puts '-----------------------------------------------------------------------------'
#Literal能够匹配空字符，所以Empty其实是多余的
nfa_literal = Literal.new('').to_nfa_design
puts nfa_literal.accepts?('')
puts nfa_literal.accepts?('b')
puts nfa_literal.accepts?('a')
puts '-----------------------------------------------------------------------------'
concatenate = Concatenate.new(Literal.new('a'), Literal.new('b'))
puts concatenate.inspect
puts concatenate.matches?('ab')
puts concatenate.matches?('a')
puts concatenate.matches?('abc')
puts '-----------------------------------------------------------------------------'
choose = Choose.new(Literal.new('a'), Literal.new('b'))
puts choose.inspect
puts choose.matches?('a')
puts choose.matches?('b')
puts choose.matches?('ab')
puts '-----------------------------------------------------------------------------'
repeat = Repeat.new(Concatenate.new(Literal.new('a'), Literal.new('b')))
puts repeat.inspect
puts repeat.matches?('ab')
puts repeat.matches?('')
puts repeat.matches?('abab')
puts repeat.matches?('ababa')
puts '-----------------------------------------------------------------------------'
puts mix.inspect
puts mix.matches?('')
puts mix.matches?('a')
puts mix.matches?('aa')
puts mix.matches?('ab')
puts mix.matches?('aab')
puts mix.matches?('abab')
puts mix.matches?('bab')
puts '-----------------------------------------------------------------------------'
mix1 = Choose.new(
		Concatenate.new(Literal.new('a'), Literal.new('b')),
		Literal.new('c')
)
puts mix1.inspect
puts mix1.matches?('c')
puts '-----------------------------------------------------------------------------'
mix2 = Concatenate.new(Literal.new('a'), 
											 Choose.new(Literal.new('b'),Literal.new('c'))
											)
puts mix2.inspect
puts mix2.matches?('c')
#
puts '--------------------------------nfa-to-dfa------------------------------------'
rulebook = NFARulebook.new([
													 FARule.new(1,'a',1),FARule.new(1,'a',2),FARule.new(1,nil,2),
													 FARule.new(2,'b',3),
													 FARule.new(3,'b',1),FARule.new(3,nil,2)
])
nfa_design = NFADesign.new(1, [3], rulebook)
puts nfa_design.to_nfa.current_states.inspect
puts '-----------------------------------------------------------------------------'
nfa_simulator = NFASimulation.new(nfa_design)
puts nfa_simulator.rules_for(Set[1])
puts '-----------------------------------------------------------------------------'
states, rules = nfa_simulator.discover_states_and_rules(Set[Set[1]])
puts states.inspect
puts rules
puts '-----------------------------------------------------------------------------'
puts nfa_simulator.to_dfa_design
