require 'set'

class FARule < Struct.new(:state, :character, :next_state)
	def applies_to?(state, character)
		self.state == state && self.character == character
	end
	def follow
		next_state
	end
	def inspect
		"#<FARule #{state.inspect} -- #{character} --> #{next_state.inspect}>"
	end
end

#Deterministic Finite Automata
class DFARulebook < Struct.new(:rules)
	def next_state(state, character)
		rule_for(state, character).follow
	end
	def rule_for(state, character)
		rules.detect { |rule| rule.applies_to?(state, character) }
	end
end

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
	def accepting?
		accept_states.include?(current_state)
	end
	def read_character(character)
		self.current_state = rulebook.next_state(current_state, character)
	end
	def read_string(string)
		string.chars.each do |character|
			read_character(character)
		end
	end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
	def to_dfa
		DFA.new(start_state, accept_states, rulebook)
	end
	def accepts?(string)
		to_dfa.tap { |dfa| dfa.read_string(string) }.accepting?
	end
end

#Nondeterministic Finite Automata
class NFARulebook < Struct.new(:rules)
	def next_states(states, character)
		states.flat_map { |state| follow_rules_for(state, character) }.to_set
	end
	def follow_rules_for(state, character)
		rules_for(state, character).map(&:follow)
	end
	def rules_for(state, character)
		rules.select { |rule| rule.applies_to?(state, character) }
	end
	def follow_free_moves(states)
		more_states = next_states(states, nil)
		if more_states.subset?(states)
			states
		else
			#始终需要加上之前的states，因为一个状态可以同时拥有自由移动和正常的移动
			#如果一个状态满足上述条件，那么在正常的移动next_states中不会走到条件为nil的自由移动
			#然而，如果一个状态没有正常移动，只有自由移动，那么在正常移动中就不会产生任何移动，把这样的状态加入状态集合不会影响正确性
			follow_free_moves(states+more_states)
		end
	end
	def alphabet
		rules.map(&:character).compact.uniq #compact去掉nil
	end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
	def accepting?
		(current_states & accept_states).any?
	end
	def read_character(character)
		self.current_states = rulebook.next_states(current_states, character)
	end
	def read_string(string)
		string.chars.each do |character|
			read_character(character)
		end
	end
	def current_states
		#super表示调用父类同名函数，并把所有参数传进去，这里的super=Struct的current_states
		#不能直接写current_states是因为这里的current_states已经被重载成当前的这个函数了，这明显是一个错误的参数
		#我们想要的其实是父类的那个对象current_states
		rulebook.follow_free_moves(super)
	end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
	def accepts?(string)
		to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
	end
	def to_nfa(current_states = Set[start_state])
		NFA.new(current_states, accept_states, rulebook)
	end
end

class NFASimulation < Struct.new(:nfa_design)
	def next_state(state, character)
		nfa_design.to_nfa(state).tap { |nfa|
			nfa.read_character(character)
		}.current_states
	end
	def rules_for(state)
		nfa_design.rulebook.alphabet.map { |character|
			FARule.new(state, character, next_state(state,character))
		}
	end
	def discover_states_and_rules(states)
		rules = states.flat_map { |state| rules_for(state) }
		real_rules = rules.select { |rule| not rule.follow.empty? }
		more_states = real_rules.map(&:follow).to_set
		if more_states.subset?(states)
			return [states, real_rules]
		else
			discover_states_and_rules(states+more_states)
		end
	end
	def to_dfa_design
		start_state = nfa_design.to_nfa.current_states
		states,rules = discover_states_and_rules(Set[start_state])
		accept_states = states.select { |state| nfa_design.to_nfa(state).accepting? }
		DFADesign.new(start_state, accept_states, DFARulebook.new(rules))
	end
end
