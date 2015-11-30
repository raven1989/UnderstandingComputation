require_relative 'Lambda'

puts '---------------------------------Infinity---------------------------------------'
#1. 无限流
#用代码表示数据可以描述无限
ZEROS = Z[ -> f{ UNSHIFT[f][ZERO] } ]
#这是一个无限0 的List，不能直接调用to_array，因为会溢出，修改下
def to_array2(l, count=nil)
	array = []
	until to_bool(IS_EMPTY[l]) || count==0 do
		array.push(FIRST[l])
		l=REST[l]
		count = count-1 unless count.nil?
	end
	array
end
puts to_array2(ZEROS, 4).map{|p| to_integer(p)}.inspect
puts to_array2(ZEROS, 10).map{|p| to_integer(p)}.inspect

#大于等于某个特定值的流
UPWARDS_OF = Z[ ->f{ ->n{
	UNSHIFT[ ->p{f[INCREMENT[n]][p]} ][n]
}}]
puts to_array2(UPWARDS_OF[FIVE], 10).map{|p| to_integer(p)}.inspect

#给定数的所有倍数的流
MULTIPLYS_OF = ->m { 
	Z[ ->f{ ->n{
		UNSHIFT[ ->p{f[ADD[m][n]][p]} ][ n ]
	}}][m]
}
puts to_array2(MULTIPLYS_OF[TWO], 10).map{|p| to_integer(p)}.inspect

