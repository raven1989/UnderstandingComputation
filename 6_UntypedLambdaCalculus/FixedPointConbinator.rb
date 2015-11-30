#不动点组合子
require_relative "Lambda"

#写一个简单的阶乘递归
FACT = -> x{ 
	IF[ IS_ZERO[x] ][
		ONE
  ][
		FACT[ MULTIPLY[x][DECREMENT[x]] ]
	]
}
#ruby会一直去展开FACT，然后栈溢出，稍作修改
FACT2 = -> x{ 
	IF[ IS_ZERO[x] ][
		ONE
  ][
		-> p{
			MULTIPLY[ FACT2[DECREMENT[x]] ][x][p] 
		}
	]
}
puts to_integer(FACT2[THREE])
#这里的递归不得不依靠一个命名FACT，这对递归是必须的吗？
#尝试去消除命名，将其作为参数传入
F = -> f{ -> x{
	IF[ IS_ZERO[x] ][
		ONE
  ][
	  -> p{
		  MULTIPLY[ f[DECREMENT[x]] ][x][p]
	  }
  ]
}}
#似乎很好地工作了
puts to_integer(F[FACT2][THREE])
#但其实并没有消除掉FACT2，它作为参数传入后代码段F中还是有FACT2，
#因为FACT2中本身就有自己，这样做其实是无用功。
#回头看看代码段中f[xxx]替换后变成了FACT2[xxx]，问题似乎就在这里，
#如果我们把这里的FACT2也替换掉呢？f[f][xxx]，
#其实我们要的是一种递归，叫什么名字并不重要，f[f][xxx]是F对于自己的调用，这不正是递归吗
#只不过是两个参数的递归
F2 = -> f{ -> x{
	IF[ IS_ZERO[x] ][
		ONE
  ][
	  -> p{
		  MULTIPLY[ f[f][DECREMENT[x]] ][x][p]
	  }
  ]
}}
#取而代之地，传入的参数应该是F自己
puts to_integer(F2[F2][THREE])
#太棒了，FACT被消除掉了，似乎引进了新的命名F2？
#但是别忘了F2体内可没有F2，它用代码替换名字后就没有F2了，
#我们来替换F2[F2]
poorY = -> f{ -> x{
	IF[ IS_ZERO[x] ][
		ONE
  ][
	  -> p{
		  MULTIPLY[ f[f][DECREMENT[x]] ][x][p]
	  }
  ]
}}[ ->f{ -> x{
			IF[ IS_ZERO[x] ][
				ONE
			][
				-> p{
					MULTIPLY[ f[f][DECREMENT[x]] ][x][p]
				}
			]
  }}
]
#这个叫做穷人的Y组合子，因为它不通用，需要针对每一个递归单独写出
puts to_integer(poorY[THREE])
#太棒了，它在很好地工作，而且一旦我们用poorY的代码块替代poorY，
#就没有命名了（这是真的，因为体内的IF,ONE等全部可以替换为没有命名的代码块）
#到这里MOD的问题已经解决了，只要我们写出MOD对应的穷人的Y组合子；
MOD1 = -> f{ ->l{ ->r{
	IF[ IS_LESS_OR_EQUAL[r][l] ][
		-> p{ f[f][SUBTRACT[l][r]][r][p] }
  ][
	  l
	]
}}}[ ->f{ ->l{ ->r{
		IF[ IS_LESS_OR_EQUAL[r][l] ][
			-> p{ f[f][SUBTRACT[l][r]][r][p] }
		][
			l
		]
  }}}
]
puts to_integer(MOD1[FIVE][THREE])
#但是我们是欲求无度的，(*^__^*) 嘻嘻……
#尝试去提取公共的部分
#  poorY = F2[F2] #外面和方括号里面是一样的东西
#= ->f{->x{ ..f[f].. }}[ ->f{->x{ ..f[f].. }}]
#= ->f{->g{->x{ ..g.. }}[f[f]]}[ ->f{->g{->x{ ..g.. }}}[f[f]] ]   
#注意到内部的->g{->x{..g..}}不正是定义的阶乘proc F，把这部分也提出来
#= ->fact{->f{fact[f[f]]}}[F][ ->fact{->f{fact[f[f]]}}[F] ]
#前面和方括号中的一模一样，再提一次fact
#= ->fact{ ->f{fact[f[f]]}[ ->f{fact[f[f]]} ] }[F]
#注意我们把具体的递归函数fact已经提取出来了，那么前面的这个东西就叫做Y结合子，
#替换一下字母，fact = f, f = x
Y = ->f{ ->x{f[x[x]]}[ ->x{f[x[x]]} ] }
#看起来不错，不过在ruby这样严格的语言下，x[x]会无限展开，稍作修改
#变成针对严格语言的Z结合子
Z = ->f{ ->x{f[->y{x[x][y]}]}[ ->x{f[->y{x[x][y]}]} ] }
#再用阶乘来试试看
#在需要调用阶乘名字的地方用f替换
FACT3 = Z[
	->f{ -> x{ 
		IF[ IS_ZERO[x] ][
			ONE
		][
			-> p{ MULTIPLY[ f[DECREMENT[x]] ][x][p] }
		]
	}}
]
puts to_integer(FACT3[FIVE])
#现在让我们回去处理MOD 吧
