require_relative 'semantic'

puts '... go go go ...'
puts '--------------------------------------------------------------------------------------'
#exp1 = Add.new(Multiply.new(Number.new(1), Number.new(2)), Multiply.new(Number.new(3), Number.new(4)))
#exp2 = Add.new(Number.new(1), Number.new(2))
#Machine.new(exp1, {}).run
puts '--------------------------------------------------------------------------------------'
#Machine.new(exp2, {}).run
puts '--------------------------------------------------------------------------------------'
#exp3 = LessThan.new(Add.new(Number.new(1),Number.new(1)), Number.new(2))
#Machine.new(exp3, {}).run
puts '--------------------------------------------------------------------------------------'
#exp4 = Add.new(Variable.new(:x), Variable.new(:y))
#Machine.new(exp4, {x:Number.new(4), y:Number.new(5)}).run
puts '--------------------------------------------------------------------------------------'
statement1 = Assign.new(:i, Add.new(Add.new(Number.new(2), Number.new(5)), Multiply.new(Number.new(1), Number.new(4))))
Machine.new(statement1, {}).run
puts '--------------------------------------------------------------------------------------'
statement2 = If.new(LessThan.new(Add.new(Number.new(1),Number.new(2)), Number.new(3)), 
									 Assign.new(:x, Number.new(0)),
									 Assign.new(:x, Number.new(1)) )
Machine.new(statement2, {}).run
puts '--------------------------------------------------------------------------------------'
sequence1 = Sequence.new(Assign.new(:i, Multiply.new(Number.new(1), Number.new(2))),
											 Assign.new(:i, Add.new(Variable.new(:i), Number.new(1)))	)
Machine.new(sequence1, {}).run
puts '--------------------------------------------------------------------------------------'
sequence2 = Sequence.new(Assign.new(:x, Number.new(1)),
												Assign.new(:x, Add.new(Variable.new(:x),Number.new(2))) )
Machine.new(sequence2, {}).run
puts '--------------------------------------------------------------------------------------'
sequence3 = Sequence.new(Assign.new(:i, Number.new(0)), 
												While.new( LessThan.new(Variable.new(:i),Number.new(2)),
														 Assign.new(:i,Add.new(Variable.new(:i),Number.new(1))) ) 
												)
Machine.new(sequence3, {}).run								
puts '------------big-step-semantic---------------------------------------------------------'
display = DisplayHelper.new
display.run(Number.new(2))
display.run(Multiply.new(Number.new(2),Number.new(3)).evaluate({}))
display.run(Add.new(Number.new(2),Number.new(3)).evaluate({}))
# display.run(LessThan.new(Number.new(2),Number.new(3)).evaluate({}))
puts Boolean.new(true).inspect
puts Number.new(2).inspect
display.run( LessThan.new( Add.new(Number.new(1),Number.new(1)),
					 Multiply.new(Number.new(1), Number.new(2))	).evaluate({}) 
					 )
puts '--------------------------------------------------------------------------------------'
display.run( Assign.new(:i, Add.new(Number.new(1),Number.new(-1))).evaluate({}) )
puts '--------------------------------------------------------------------------------------'
display.run( If.new( LessThan.new(Number.new(4),Number.new(0)),
									Assign.new(:x, Number.new(-1)),
									Assign.new(:x, Number.new(1)) ).evaluate({}) 
					 )
puts '--------------------------------------------------------------------------------------'
display.run( Sequence.new( Assign.new(:x, Add.new(Number.new(1),Number.new(3))), 
												 Assign.new(:x, Add.new(Variable.new(:x),Number.new(-4))) ).evaluate({}) 
					 )
puts '--------------------------------------------------------------------------------------'
display.run( While.new( LessThan.new(Variable.new(:x),Number.new(2)), 
											Assign.new(:x, Add.new(Variable.new(:x),Number.new(1))) 
											).evaluate({x:Number.new(0)}) 
					 )
puts '------------------denotation-semantic--------------------------------------------------'
translator = Translator.new
translator.run( Number.new(3).to_ruby, {})
translator.run( Boolean.new(false).to_ruby, {})
puts '--------------------------------------------------------------------------------------'
translator.run( Variable.new(:x).to_ruby, {x:8})
translator.run( Add.new(Variable.new(:x),Number.new(2)).to_ruby, {x:8} )
translator.run( Multiply.new(Variable.new(:x),Number.new(2)).to_ruby, {x:8} )
translator.run( LessThan.new(Variable.new(:x),Number.new(2)).to_ruby, {x:8} )
puts '--------------------------------------------------------------------------------------'
translator.run( Assign.new(:x, Add.new(Variable.new(:x),Number.new(-7))).to_ruby, {x:8} )
puts '--------------------------------------------------------------------------------------'
translator.run( If.new(LessThan.new(Variable.new(:x),Number.new(10)), 
											 Assign.new(:x, Add.new(Variable.new(:x),Number.new(10))),
											 Assign.new(:x, Add.new(Variable.new(:x),Number.new(-10)))
											).to_ruby, {x:19} 
							)
puts '--------------------------------------------------------------------------------------'
translator.run( Sequence.new(Assign.new(:x,Number.new(10)), 
											 Assign.new(:x, Add.new(Variable.new(:x),Number.new(5)))
											).to_ruby, {x:-5} 
							)
puts '--------------------------------------------------------------------------------------'
translator.run( While.new(LessThan.new(Variable.new(:x),Number.new(10)), 
											 Assign.new(:x, Add.new(Variable.new(:x),Number.new(5)))
											).to_ruby, {x:-5} 
							)

