require_relative 'Tape'

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state, :write_character, :direction)
	def applies_to?(config)
		state==config.state && character==config.tape.middle
	end
	def follow(config)
		TMConfiguration.new(next_state, next_tape(config))
	end
	def next_tape(config)
		written_tape = config.tape.write(write_character)
		case direction
		when :left
			written_tape.move_head_left
		when :right
			written_tape.move_head_right
		end
	end
end

class DTMRulebook < Struct.new(:rules)
	def next_configuration(config)
		rule_for(config).follow(config)
	end
	def rule_for(config)
		rules.detect { |rule| rule.applies_to?(config) }
	end
	def applies_to?(config)
		!rule_for(config).nil?
	end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
	def accepting?
		accept_states.include?(current_configuration.state)
	end
	def step
		self.current_configuration = rulebook.next_configuration(current_configuration)
	end
	def run
		step until accepting? || stuck?
	end
	def stuck?
		!accepting? && !rulebook.applies_to?(current_configuration)
	end
end
