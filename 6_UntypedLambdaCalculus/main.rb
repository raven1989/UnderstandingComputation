require_relative 'Lambda'
puts '---------------------------------Number---------------------------------------'
puts to_integer(ZERO)
puts to_integer(ONE)
puts to_integer(TWO)
puts to_integer(THREE)
puts to_integer(FIVE)
puts to_integer(TEN)
puts to_integer(HUNDRED)
puts to_integer(POWER0[FIVE][ZERO])
puts '----------------------------------Bool----------------------------------------'
puts TRUE[true][false]
puts FALSE[true][false]
puts REDANDANT_IF[TRUE]["redandant"]["concise"]
puts IF[TRUE["haha"]["hehe"]]
puts IF[FALSE["haha"]["hehe"]]
puts IS_ZERO[ZERO]["zero"]["nonzero"]
puts to_bool(IS_ZERO[THREE])
puts '----------------------------------Pair----------------------------------------'
my_pair = PAIR[THREE][FIVE]
puts to_integer(LEFT[my_pair])
puts to_integer(RIGHT[my_pair])
puts '------------------------------PLUS-MINUS-v2-----------------------------------'
puts to_integer2(PLUS2[THREE][TWO])
puts to_integer2(MINUS2[THREE][TWO])
puts to_integer2(MINUS2[ONE][TWO])
puts '-------------------------------Arithmetic--------------------------------------'
puts '----------------INCREMENT------------------'
puts to_integer(INCREMENT[ONE])
puts to_integer(INCREMENT2[ONE])
puts '----------------DECREMENT------------------'
puts to_integer(DECREMENT[FIVE])
puts to_integer(DECREMENT[ZERO])
puts '----------------+-*^------------------'
puts to_integer(ADD[ZERO][ONE])
puts to_integer(SUBTRACT[FIVE][ONE])
puts to_integer(SUBTRACT[TWO][TEN])
puts to_integer(MULTIPLY[FIVE][FIVE])
puts to_integer(POWER[TEN][TWO])
puts '----------------MOD------------------'
puts to_integer(MOD[TEN][TWO])
puts to_integer(MOD[FIVE][TWO])
puts to_integer(MOD[FIVE][FIVE])
puts '----------------------------------List-----------------------------------------'
my_list = UNSHIFT[
	UNSHIFT[
		UNSHIFT[EMPTY][THREE]
  ][TWO]
][ONE]
puts to_array(my_list).map {|p| to_integer(p)}.inspect
puts to_array(RANGE[ONE][FIVE]).map {|p| to_integer(p)}.inspect
puts to_array(RANGE[ZERO][ZERO]).map {|p| to_integer(p)}.inspect
puts '-----------------------------------Map-----------------------------------------'
puts to_array(MAP[EMPTY][INCREMENT]).map {|p| to_integer(p)}.inspect
puts to_array(MAP[RANGE[ZERO][FIVE]][INCREMENT]).map {|p| to_integer(p)}.inspect
puts to_array(MAP[RANGE[ZERO][FIVE]][ADD[TWO]]).map {|p| to_integer(p)}.inspect
puts to_array(MAP[RANGE[ZERO][FIVE]][SUBTRACT[TWO]]).map {|p| to_integer(p)}.inspect
puts to_array(MAP[RANGE[TWO][FIVE]][->x{SUBTRACT[x][TWO]}]).map {|p| to_integer(p)}.inspect
puts '----------------------------------Char-----------------------------------------'
FIZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]
puts to_char(ZED)
puts to_char(FIVE)
puts to_string(FIZZBUZZ)
puts to_integer(DIVIDE[TEN][TEN])
puts to_integer(DIVIDE[TEN][FIVE])
puts to_integer(DIVIDE[TEN][THREE])
puts to_integer(DIVIDE[ZERO][THREE])
puts to_array(PUSH[my_list][FIVE]).map{|p| to_integer(p)}.inspect
puts to_array(TO_DIGITS[FIFTEEN]).map{|p| to_integer(p)}.inspect
puts to_string(TO_DIGITS[INCREMENT[FIFTEEN]])
puts '---------------------------------FIZZBUZZ--------------------------------------'
my_fizzbuzz = MAP[ RANGE[ONE][HUNDRED] ][ ->n{
	IF[ IS_ZERO[MOD[n][FIFTEEN]] ][
		FIZZBUZZ
  ][
	  IF[ IS_ZERO[MOD[n][THREE]] ][
			FIZZ
	  ][
		  IF[ IS_ZERO[MOD[n][FIVE]] ][
				BUZZ
		  ][
			  TO_DIGITS[n]
			]
		]
	]
}]
# puts to_array(my_fizzbuzz).map{|p| to_string(p)}
