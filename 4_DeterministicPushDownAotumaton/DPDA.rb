require 'set'
#一个非破坏性的Stack
class Stack < Struct.new(:content)
	def push(character)
		Stack.new([character] + content)
	end
	def pop
		Stack.new(content.drop(1))
	end
	def top
		content.first
	end
	def inspect
		"#<Stack (#{top})#{content.drop(1).join}>"
	end
end

class PDAConfiguration < Struct.new(:state, :stack)
	STUCK_STATE = Object.new
	def stuck
		PDAConfiguration.new(STUCK_STATE, stack)
	end
	def stuck?
		state == STUCK_STATE
	end
end

class PDARule < Struct.new(:state, :character, :next_state, :pop_character, :push_characters)
	def applies_to?(configuration, character)
		state == configuration.state && self.character == character &&
			pop_character == configuration.stack.top 
	end
	def next_stack(configuration)
		popped_stack = configuration.stack.pop
		push_characters.reverse.inject(popped_stack) { |stack, character| stack.push(character) }
	end
	def follow(configuration)
		PDAConfiguration.new(next_state, next_stack(configuration))
	end
end

class PDARulebook < Struct.new(:rules)
	def rule_for(config, character)
		rules.detect { |rule| rule.applies_to?(config, character) }
	end
	def next_configuration(config, character)
		rule_for(config, character).follow(config)
	end
	def applies_to?(config, character)
		#是否有规则适用config和character
		!rule_for(config, character).nil?
	end
	def follow_free_moves(config)
		#确定性下推自动机的确定性在这里又一次体现出来：
		#如果有自由移动的规则适用，就必须执行它
		#因为如果同时还有其他规则也适用，那么这个自动机就不是确定的，
		#而是非确定性下推自动机
		if applies_to?(config, nil)
			follow_free_moves(next_configuration(config, nil))
		else
			config
		end
	end
end

#确定性下推自动机
class DPDA < Struct.new(:current_config, :accept_states, :rulebook)
	def accepting?
		accept_states.include?(current_config.state)
	end
	def next_configuration(character)
		#这里在判断条件中的current_config已经立即执行了自由移动，
		#体现了上面提到过的确定性：有规则就立即执行
		if rulebook.applies_to?(current_config, character)
			rulebook.next_configuration(current_config, character)
		else
			current_config.stuck
		end
	end
	def stuck?
		current_config.stuck?
	end
	def read_character(character)
		# self.current_config = rulebook.next_configuration(current_config, character)
		self.current_config = next_configuration(character)
	end
	def read_string(string)
		string.chars.each do |character|
			read_character(character) unless stuck?
		end
	end
	def current_config
		rulebook.follow_free_moves(super)
	end
end

class DPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
	def to_dpda
		start_stack = Stack.new([bottom_character])
		start_config = PDAConfiguration.new(start_state, start_stack)
		DPDA.new(start_config, accept_states, rulebook)
	end
	def accepts?(string)
		to_dpda.tap { |dpda| dpda.read_string(string) }.accepting?
	end
end

#非确定性下推自动机
class NPDARulebook < Struct.new(:rules)
	def rules_for(config, character)
		rules.select { |rule| rule.applies_to?(config, character) }
	end
	def follow_rules_for(config, character)
		rules_for(config, character).map { |rule| rule.follow(config) }
	end
	def next_configurations(config, character)
		config.flat_map { |config| follow_rules_for(config, character) }.to_set
	end
	def follow_free_moves(configs)
		#与确定性下推自动机不同，这里不用判断规则集中是否有可用的自由移动，
		#无论有没有，直接执行，即使没有可用的自由移动规则，那么返回结果也不过是个空集，
		#而空集是任何集合的子集，当然configs不例外，这符合follow_free_moves结束的条件，
		#故而，直接返回的configs是完备的最终结果集合
		more_configs = next_configurations(configs, nil)
		if more_configs.subset?(configs)
			configs
		else
			follow_free_moves(configs + more_configs)
		end
	end
end

class NPDA < Struct.new(:current_configs, :accept_states, :rulebook)
	def accepting?
		current_configs.any? { |config| accept_states.include?(config.state) }
	end
	def current_configs
		rulebook.follow_free_moves(super)
	end
	def read_character(character)
		#这里只对起始的current_configs进行了自由移动，
		#理论上得到的结果也要进行自由移动才是最终结果
		#但是，请注意上面的accepting?也调用了current_configs，进行了自由移动
		#这样，在类外部看起来就是正确的，虽然得到最终结果前的最后一步自由移动运行得迟了一些
		self.current_configs = rulebook.next_configurations(current_configs, character)
	end
	def read_string(string)
		string.chars.each do |character|
			read_character(character)
		end
	end
end

class NPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
	def to_npda
		NPDA.new(Set[PDAConfiguration.new(start_state, Stack.new([bottom_character]))],
						 accept_states, rulebook)
	end
	def accepts?(string)
		to_npda.tap { |npda| npda.read_string(string) }.accepting?
	end
end
