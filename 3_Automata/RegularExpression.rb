require_relative 'FA'
module Pattern
	def bracket(outer_precedence)
		if precedence < outer_precedence
			'('+to_s+')'
		else
			to_s
		end
	end
	def inspect
		"/#{self}/"
	end
	def matches?(string)
		to_nfa_design.accepts?(string)
	end
end

class Empty
	include Pattern
	def to_s
		''
	end
	def precedence
		3
	end
	def to_nfa_design
		start_state = Object.new
		accept_state = [start_state]
		rulebook = NFARulebook.new([])
		NFADesign.new(start_state, accept_state, rulebook)
	end
end

class Literal < Struct.new(:character)
	include Pattern
	def to_s
		character
	end
	def precedence
		3
	end
	def to_nfa_design
		start_state = Object.new
		accept_state = Object.new
		rulebook = NFARulebook.new( [FARule.new(start_state,character,accept_state)] )
		NFADesign.new(start_state, [accept_state], rulebook)
	end
end

class Concatenate < Struct.new(:first, :second)
	include Pattern
	def to_s
		[first,second].map { |pattern| pattern.bracket(precedence) }.join
	end
	def precedence
		1
	end
	#使用自有移动组合first和second的nfa，让first所有的接受状态自发地转移到second的开始状态
	def to_nfa_design
		first_nfa = first.to_nfa_design
		second_nfa = second.to_nfa_design
		start_state = first_nfa.start_state
		accept_states = second_nfa.accept_states
		extra_rules = first_nfa.accept_states.map { |state| FARule.new(state,nil,second_nfa.start_state) }
		rulebook = NFARulebook.new(first_nfa.rulebook.rules + second_nfa.rulebook.rules + extra_rules)
		NFADesign.new(start_state, accept_states, rulebook)
	end
end

class Choose < Struct.new(:first, :second)
	include Pattern
	def to_s
		[first,second].map { |pattern| pattern.bracket(precedence) }.join('|')
	end
	def precedence
		0
	end
	#因为nfa只能有一个开始状态，为了达成或的效果，需要增加一个状态作为新起始状态，可自由移动到first和second的起始状态
	def to_nfa_design
		first_nfa = first.to_nfa_design
		second_nfa = second.to_nfa_design
		start_state = Object.new
		accept_states = first_nfa.accept_states + second_nfa.accept_states
		extra_rules = [FARule.new(start_state,nil,first_nfa.start_state),
		FARule.new(start_state,nil,second_nfa.start_state)]
		rulebook = NFARulebook.new(first_nfa.rulebook.rules + second_nfa.rulebook.rules + extra_rules)
		NFADesign.new(start_state, accept_states, rulebook)
	end
end

class Repeat < Struct.new(:pattern)
	include Pattern
	def to_s
		pattern.bracket(precedence) + '*'
	end
	def precedence
		2
	end
	#可以有多种实现方法，这里增加一个新的结束状态作为唯一的结束状态
	#起始状态可以自有移动到结束状态，反过来依然
	#再加上所有pattern的结束状态自有移动到新的结束状态
	def to_nfa_design
		nfa = pattern.to_nfa_design
		start_state = nfa.start_state
		accept_state = Object.new
		extra_rules = [FARule.new(start_state,nil,accept_state), FARule.new(accept_state,nil,start_state)] + 
			nfa.accept_states.map { |state| FARule.new(state,nil,accept_state) }
		rulebook = NFARulebook.new(nfa.rulebook.rules + extra_rules)
		NFADesign.new(start_state, [accept_state], rulebook)
	end
end
