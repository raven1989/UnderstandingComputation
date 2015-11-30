require_relative 'LambdaCalculus'
require 'treetop'

puts '---------------------------------Grammar---------------------------------------'
one = LCFunction.new(:p,
				LCFunction.new(:x,
					LCCall.new(LCVariable.new(:p), LCVariable.new(:x))
  )
)
puts one.inspect

increment = LCFunction.new(:n,
						  LCFunction.new(:p,
								LCFunction.new(:x, 
									LCCall.new( LCCall.new(LCVariable.new(:n),LCVariable.new(:p)), 
										LCCall.new(LCVariable.new(:p),LCVariable.new(:x))
			)
		)
  )
)
puts increment.inspect

add = LCFunction.new(:l,
				LCFunction.new(:r,
					LCCall.new( LCCall.new(LCVariable.new(:l),increment),LCVariable.new(:r) )
  )
)
puts add.inspect
puts '---------------------------------Replace---------------------------------------'
puts LCVariable.new(:x).replace(:x, LCFunction.new(:y,LCVariable.new(:y))).inspect
#Function的replace方法不够健壮
weakf = LCCall.new(LCFunction.new(:p,LCFunction.new(:x,LCCall.new(LCVariable.new(:p),LCVariable.new(:x)))),
									 LCFunction.new(:p,LCFunction.new(:x,LCCall.new(LCVariable.new(:x),LCVariable.new(:p))))
)
while weakf.reducible?
	puts weakf
	weakf = weakf.reduce
end;puts weakf
#到这里之后如果强行replace的话就是错误的结果
#所以我们设置了如果置换参数列表中的参数就返回自己
puts weakf.replace(:x,1)
puts '----------------------------------Call-----------------------------------------'
function = LCFunction.new(:x,
						 LCFunction.new(:y, LCCall.new(LCVariable.new(:x),LCVariable.new(:y)) )
)
puts function
argument = LCFunction.new(:z,LCVariable.new(:z))
puts argument
puts function.call(argument)
puts '----------------------------------Reduce----------------------------------------'
oneplusone = LCCall.new(LCCall.new(add,one),one)
while oneplusone.reducible?
	puts oneplusone
	oneplusone = oneplusone.reduce
end;puts oneplusone
#执行的结果并没有完全规约，因为我们定义了Function是不能规约的；
#事实上如果Function的body内部是可能存在可以规约的表达式的，这个就是个例子；
#如果想要继续规约，需要replace足够健壮才行，但所幸的这样的结果是正确的
puts '--------------------------------------------------------------------------------'
#我们挑选两个没用过的变量名，对上面的结果再调用两次，就得到two的形式了；
#说明表达式是等价的
inc,zero = LCVariable.new(:inc), LCVariable.new(:zero)
oneplusone = LCCall.new(LCCall.new(oneplusone,inc),zero)
while oneplusone.reducible?
	puts oneplusone
	oneplusone = oneplusone.reduce
end;puts oneplusone
puts '----------------------------------Grammar----------------------------------------'
Treetop.load('LambdaCalculus')
parser = LambdaCalculusParser.new.parse(' -> x { 
																				    x  [ x ]	
                                          }[-> y{y}  ]   ')
# puts parser.inspect
expression = parser.to_ast
# expression = LCCall.new(LCFunction.new(:x,LCCall.new(LCVariable.new(:x),LCVariable.new(:x))),
												# LCFunction.new(:y,LCVariable.new(:y)))
puts expression.inspect
puts expression.reduce

space = "  \r\n\t  "
puts space
space_parser = LambdaCalculusParser.new.parse(space,root: :space)
puts space_parser.inspect
