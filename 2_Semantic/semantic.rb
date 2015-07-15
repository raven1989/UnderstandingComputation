class Number < Struct.new(:value)
	def to_s
		value.to_s
	end
	def reducible?
		false
	end
	def inspect
		"|#{self}|"
	end
end

class Add < Struct.new(:left, :right)
	def to_s
		"#{left}+#{right}"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		if left.reducible?
			Add.new(left.reduce(environment), right)
		elsif right.reducible?
			Add.new(left, right.reduce(environment))
		else
			Number.new(left.value+right.value)
		end
	end
end

class Multiply < Struct.new(:left, :right)
	def to_s
		"#{left}*#{right}"
	end
	def reducible?
		true
	end
	def inspect
		"|#{self}|"
	end
	def reduce(environment)
		if left.reducible?
			Multiply.new(left.reduce(enviroment), right)
		elsif right.reducible?
			Multiply.new(left, right.reduce(environment))
		else
			Number.new(left.value*right.value)
		end
	end
end

class Boolean < Struct.new(:value)
	def to_s
		value.to_s
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		false
	end
end

class LessThan < Struct.new(:left, :right)
	def to_s
		"#{left}<#{right}"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		if left.reducible?
			LessThan.new(left.reduce(environment), right)
		elsif right.reducible?
			LessThan.new(left, right.reduce(environment))
		else
			Boolean.new(left.value<right.value)
		end
	end
end

class Variable < Struct.new(:name)
	def to_s
		name.to_s
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		environment[name]
	end
end

#statement
class DoNothing
	def to_s
		'do-nothing'
	end
	def inspect
		"|#{self}|"
	end
	def ==(other)
		other.instance_of?(DoNothing)
	end
	def reducible?
		false
	end
end

class Assign < Struct.new(:name, :expression)
	def to_s
		"#{name}=#{expression}"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		if expression.reducible?
			[Assign.new(name, expression.reduce(environment)), environment]
		else
			[DoNothing.new, environment.merge({name => expression})]
		end
	end
end

class If < Struct.new(:condition, :consequence, :alternative)
	def to_s
		"if #{condition} { #{consequence} } else { #{alternative} }"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		if condition.reducible?
			[If.new(condition.reduce(environment), consequence, alternative), environment]
		else
			case condition.value
			when true
				[consequence, environment]
			when false
				[alternative, environment]
			end
		end
	end
end

class Sequence < Struct.new(:first, :second)
	def to_s
		"#{first}; #{second}"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		case first
		when DoNothing.new
			[second, environment]
		else
			reduced_first, reduced_env = first.reduce(environment)
			[Sequence.new(reduced_first, second), reduced_env]
		end
	end
end

class While < Struct.new(:condition, :body)
	def to_s
		"while #{condition} { #{body} }"
	end
	def inspect
		"|#{self}|"
	end
	def reducible?
		true
	end
	def reduce(environment)
		#这反映了while的本质不是一个基本语句，而是基本语句的聚合，我们可以通过不断地写if语句来实现while的功能
		[If.new( condition, 
				 Sequence.new(body, While.new(condition, body)),
				 DoNothing.new	), 
		environment]
	end
end

class Machine < Struct.new(:statement, :environment)
	def step
		self.statement, self.environment = statement.reduce(environment)
	end
	def run
		while statement.reducible?
			puts "#{statement}, #{environment}"
			step
		end
		puts "#{statement}, #{environment}"
	end
end

#big-step semantic
class DisplayHelper
	def run(object)
		puts object.inspect
	end
end

class Number
	def evaluate(environment)
		self
	end
end

class Boolean
	def evaluate(environment)
		self
	end
end

class Variable
	def evaluate(environment)
		environment[name]
	end
end

class Add
	def evaluate(environment)
		Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
	end
end

class Multiply
	def evaluate(environment)
		Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
	end
end

class LessThan
	def evaluate(environment)
		Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
	end
end
#与表达式返回一个值类型（Number, Boolean）不同
#下面的叫做语句，语句的evaluate 返回的都是一个更改后的环境
class DoNothing
	def evaluate(environment)
		environment
	end
end

class Assign
	def evaluate(environment)
		environment.merge({name => expression.evaluate(environment)})
	end
end

class If
	def evaluate(environment)
		case condition.evaluate(environment)
		when Boolean.new(true)
			consequence.evaluate(environment)
		when Boolean.new(false)
			alternative.evaluate(environment)
		end
	end
end

class Sequence
	def evaluate(environment)
		second.evaluate(first.evaluate(environment))
	end
end

class While
	def evaluate(environment)
		#impletement 1
		# If.new(condition, 
					# Sequence.new(body, While.new(condition,body)), 
					# DoNothing.new
					# ).evaluate(environment)
		#impletement 2
		#这个语言的condition只允许是返回Boolean 的表达式，而不能是语句（会改变环境）
		#并不支持如if(x=1){...}这样条件会改变environment的语句
		case condition.evaluate(environment) 
		when Boolean.new(true)
			evaluate(body.evaluate(environment))
		when Boolean.new(false)
			environment
		end
	end
end

#denotation semantic
class Translator
	def run(object,env)
		puts eval(object).call(env).inspect
	end
end
class Number
	def to_ruby
		"-> env {#{value.inspect}}"
	end
end
class Boolean
	def to_ruby
		"-> env {#{value.inspect}}"
	end
end
class Variable
	def to_ruby
		"-> env {env[#{name.inspect}]}"
	end
end
class Add
	def to_ruby
		"-> env {(#{left.to_ruby}).call(env)+(#{right.to_ruby}).call(env)}"
	end
end
class Multiply
	def to_ruby
		"-> env {(#{left.to_ruby}).call(env)*(#{right.to_ruby}).call(env)}"
	end
end
class LessThan
	def to_ruby
		"-> env {(#{left.to_ruby}).call(env)<(#{right.to_ruby}).call(env)}"
	end
end
class Assign
	def to_ruby
		"-> env {env.merge( {#{name.inspect} => (#{expression.to_ruby}).call(env)} )}"
	end
end
class DoNothing
	def to_ruby
		"-> env {env}"
	end
end
class If
	def to_ruby
		"-> env {if (#{condition.to_ruby}).call(env) "+
			"then (#{consequence.to_ruby}).call(env) "+
			"else (#{alternative.to_ruby}).call(env) "+
			"end}"
	end
end
class Sequence
	def to_ruby
		"-> env { (#{second.to_ruby}).call((#{first.to_ruby}).call(env)) }"
	end
end
class While
	def to_ruby
		"-> env {while (#{condition.to_ruby}).call(env); env=(#{body.to_ruby}).call(env); end; env}"
	end
end


