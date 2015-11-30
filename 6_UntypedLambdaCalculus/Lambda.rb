#Number
#数字的本质并不是0，1，2，而是表示某种事物重复的次数，我们用proc 执行的次数来反映它
def zero(proc, x)
	x
end
ZERO = ->p{ ->x{ x } }
def one(proc, x)
	proc[x]
end
ONE = ->p{ ->x{ p[x] } }
def two(proc, x)
	proc[proc[x]]
end
TWO = ->p{ ->x{ p[p[x]] } }
THREE = ->p{ ->x{ p[p[p[x]]] } }
FIVE = ->p{ ->x{ p[p[p[p[p[x]]]]] } }
#定义一个to_integer 方法，其proc=->n{n+1}，以这个proc 来把数字的性质表示为ruby 的格式，来检验它
#正如用现象去检验被发现的真理一样
def to_integer(proc)
	proc[->n{n+1}][0]
end
#还需要其他大的数字，比如一百，显然我们不会蠢到去写一百个p[p[..x..]] 这样的嵌套，
#这不是说我们不能，而是我们选择不，这有着本质的区别。
#我们要使用数字的另一个性质了，加法！！
#该怎么写呢？我们先写函数形式再转换成proc 形式，这样帮助我们思考
def plus(proc, x, ln, rn)
	ln[proc][rn[proc][x]]
end
#是不是觉得很复杂？那是因为你还没有理解本质！
#def one(proc, x) 的意思是针对某个对象x 执行proc 操作1 次，
#还太抽象？ok，x=一代苹果，proc=取出，so，针对一代苹果取出1 次。这就是1 的本质。
#我们再来思考“加”这件事，它必然有一个左值数字ln 和一个右值数字rn ，嗯，对于一代苹果先取出苹果ln 次再取出rn 次
#一代苹果=x，取出=proc；那么我们必然有四个参数了proc,x,ln,rn；接下来呢？
#当然是先取苹果ln 次啦：ln[proc][x]，它的实现代码是p..[x]，其中..=ln，即有ln 个p
#怎么接着取rn 个苹果呢？rn[proc][x] = p..[x](..=rn) 这只是取rn 个，而不是接着取；
#我们要的结果是p..[x](..=ln+rn)，也就是要ln+rn 个p ，嘻嘻，那只需要把p..[x](..=ln) 中的x 替换为p..[x](..=rn)不就是了吗
#所以ln[proc][rn[proc][x]]，嗒哒~，其实这个表达式是先执行rn，再执行ln的，嘿嘿，加法的交换律就被我们这么发现了。
#快，夸我
PLUS = ->l{
 ->r{	
	->p{
	 ->x{
	  l[p][r[p][x]]
}}}}
#我们终于得到10 啦
TEN = PLUS[FIVE][FIVE]
FIFTEEN = PLUS[TEN][FIVE]
#难道我们要一直加下去直到100 吗？不！因为我们是极其懒惰的！！
#ladies and gentelmen, now i present to you ...
def power(a, exp)
	exp[a]
end
POWER0 = -> a{
	-> exp{
	 exp[a]
}}
#有些同学想到了乘，巴嘎！乘不就是加吗？
#而且你看幂运算竟如此简洁，它的简洁性揭示了一个本质：
#我帅，另一个是幂是数字本质的直接多次运算
#我们以power(TWO,THREE) 为例，TWO=p[p[x]], THREE=p[p[p[x]]]
#POWER0[TWO][THREE]=THREE[TWO]=TWO[TWO[TWO]]，
#由内往外地，首先执行proc两次(这是数字2 的本质)，记为proc1，再执行proc1两次=执行proc四次...
#shall i go on ?
HUNDRED = POWER0[TEN][TWO]

#Bool
#bool 的本质是二选一
def true(x, y)
	x
end
def false(x, y)
	y
end
TRUE = -> x{
	-> y{
	  x
}}
FALSE = -> x{
	-> y{
	  y
}}
#bool经常会与if...else if...else...联合使用
def if(proc, x, y)
	proc[x][y]
end
REDANDANT_IF = -> b{
	-> x{
	  -> y{
	   b[x][y]
}}}
#IF只是锦上添花，并不是必须的，可以看出它只是将x,y 传递给b(TRUE|FALSE)
#所以可以简化，让它做bool 的壳子而已
IF = -> b{ b }
#判断一个数是不是零，利用观察到的一个特性，ZERO是唯一没有调用p的，直接返回x的，其他数字都调用了p
#所以只需要p永远返回FALSE，而x返回TRUE
def zero?(proc)
	proc[->x{FALSE}][TRUE]
end
IS_ZERO = -> n{
	n[->x{FALSE}][TRUE]
}
def to_bool(b)
	b[true][false]
end

#Pair
PAIR = -> x{ ->y{ ->f{ f[x][y] } } }
#Pair 存储两个值后，返回的是f[x][y]，
#LEFT 和RIGHT 传入proc 给pair 获取x 和 y
LEFT = -> p{ p[->x{->y{x}}] }
RIGHT = -> p{ p[->x{->y{y}}] }

#PLUS MINUS version 2
#我们回头看看之前的PLUS，这样的实现下，如何实现MINUS 呢？
#来看MINUS[l][r]，结果需要l-r个p，这通过嵌套无法实现，因为我们只能增加而不能减少p
#似乎是个棘手的问题
#回到本质去思考，p=取出苹果，l个p即取出苹果l次，-r个p不就是放回苹果r次
#自然而然地，我们想到定义p的反操作q=-p，刚好借用上面的PAIR去具体实现
#左值存p，右值存q
PLUS2 = -> l{
	-> r{
	 -> p{
	  -> x{
	l[LEFT[p]][r[LEFT[p]][x]]
}}}}
#这里的p不再是proc而是pair
MINUS2 = -> l{
	-> r{
	 -> p{
	  -> x{
	l[LEFT[p]][r[RIGHT[p]][x]]
}}}}
#运行完MINUS2后得到数字与之前的不同了，比如
#TWO=p[p[x]]，运行后得到的是p[p[p[q[x]]]]，虽然它也表示2，但与之前的不同了
#这算错吗？我觉得不算，因为p[p[x]]是以1+1的形式表示2，后者是以3-1的形式表示2
#2的本质没有改变，只是两种表示形式不同，而我们不得不借用形式来表示本质
#However，形式上的不统一会给我们造成麻烦，纵然不是错误，后面我们还是会统一形式
#需要一个新的to_integer2方法来检验它，这里的proc 是number
def to_integer2(proc)
	proc[PAIR[->n{n+1}][->n{n-1}]][0]
end

#Arithmetic
#从这里开始我们用统一的形式重新定义这些数值运算
INCREMENT = ->n{
	-> p{
	-> x{
	p[n[p][x]]
}}}
#上面和下面是等价的
INCREMENT2 = ->n{
	-> p{
	-> x{
	n[p][p[x]]
}}}
#DECREMENT怎么办？别忘了Number表示proc执行了n次，
#我们要的是proc执行了n次返回表示n-1的东西，-1自增n次会得到n-1，然而我们没有-1，
#最小的是0，0自增n次是n，它的前一个数是n-1，这正是我们要的，
#我们用pair记住前一个值如何？(-1,0)(0,1)(1,2)...(n-1,n)
#请注意我们只自增1，所以INCREMET(l,r)=(l+1,r+1)=(r,r+1)，
#太棒了自增1可以不依赖左值，没有-1也没关系了，
#但是最后需要返回左值，考虑边界条件DECREMENT(ZERO)这会直接返回最初的左值，
#我们姑且就把最初的左值定为ZERO，也就是说DECREMENT(ZERO)=ZERO
SLIDE = -> p{
	PAIR[ RIGHT[p] ][ INCREMENT[RIGHT[p]] ]
}
DECREMENT = -> n{
	LEFT[
		n[SLIDE][ PAIR[ZERO][ZERO] ]
  ]
}
#为什么自增自减与之前定义的形式是统一的呢？
#定义TWO=p[p[x]]，自增后是p[p[p[x]]]，自减后得到p[x]
#故而我们用自增和自减来做加减的还在形式上是统一的
#与PLUS和MINUS相比，这一组不能处理负数，但却有了形式上的统一
ADD = -> l{
	-> r{
	l[INCREMENT][r]
}}
SUBTRACT = -> l{
	-> r{
	r[DECREMENT][l]
}}
MULTIPLY = -> l{
	-> r{
	l[ADD[r]][ZERO]
}}
POWER = -> a{
	->e{
	e[MULTIPLY[a]][ONE]
}}
#mod运算
def mod(l, r)
	if r<=l
		mod(l-r,r)
	else
		l
	end
end
#Fortunately，if(l<=r) SUBTRACT(l,r)=ZERO
IS_LESS_OR_EQUAL = -> l{
	->r{
	IS_ZERO[SUBTRACT[l][r]]
}}
#MOD
MOD0 = -> l {
	-> r{
	IF[
		IS_LESS_OR_EQUAL[r][l]
  ][
	  MOD0[SUBTRACT[l][r]][r]
	][
	  l
	]
}}
#这样的MOD 定义上没有问题，但让ruby来实现来却出现了问题：
#ruby在对proc处理时试图展开所有的内容，故而递归的定义就会停不下来，
#而ruby的if else不会，因为它在运行时才会展开，
#所以需要一种东西使得proc的展开也延迟到运行时。
MOD1 = -> l {
	-> r{
	IF[
		IS_LESS_OR_EQUAL[r][l]
	][
	  -> p{
	  MOD1[SUBTRACT[l][r]][r][p]
	  }
	][
	  l
	]
}}
#这个p是利用了NUMBER的第一个参数proc，它在运行时才会传入。
#我们举例阐明为什么这么做：
#  to_integer(MOD[FIVE][TWO])
#= MOD[FIVE][TWO][p][0]
#= -> x{ MOD[THREE][TWO][x] }[p][0]
#= MOD[THREE][TWO][p][0]
#= -> x{ MOD[ONE][TWO][x] }[p][0]
#= MOD[ONE][TWO][p][0]
#= ONE[p][0]
#是时候击掌相庆了吗？还太早MOD1 的定义违反lambda 形式语言中
#对于所有的事物都可以用代码表示，现在MOD1中有MOD1，这个名字永远替换不完
#这里我们引入不动点结合子，具体地是Y不动点结合子，请看文件FixedPointConbinator.rb
Z = ->f{ ->x{f[->y{x[x][y]}]}[ ->x{f[->y{x[x][y]}]} ] }
MOD = Z[
	->f{ ->l{ ->r{
		IF[
			IS_LESS_OR_EQUAL[r][l]
		][
			-> p{
			f[SUBTRACT[l][r]][r][p]
			}
		][
			l
		]
  }}}
]
#看起来问题解决了，在需要调用MOD 的地方我们用参数替换掉了

#List
EMPTY = PAIR[TRUE][TRUE]
UNSHIFT = -> l{ -> x{
	PAIR[FALSE][PAIR[x][l]]
}}
IS_EMPTY = LEFT
FIRST = -> l{ LEFT[RIGHT[l]] }
REST = -> l{ RIGHT[RIGHT[l]] }
def to_array(proc)
	array = []
	until to_bool(IS_EMPTY[proc])
		array.push(FIRST[proc])
		proc = REST[proc]
	end
	array
end

#Range
def range(x, y)
	if x<=y
		range(x+1, y).unshift(x)
	else
		[]
	end
end
RANGE = Z[ ->f{ ->x{ ->y{
	IF[ IS_LESS_OR_EQUAL[x][y] ][
		-> p{ UNSHIFT[ f[INCREMENT[x]][y] ][ x ][p] }
  ][
	  EMPTY
  ]
}}}
]

#Map
MAP = Z[ ->f{ ->l{ ->g{
	IF[ IS_EMPTY[l] ][
		EMPTY
  ][
	  ->p{ UNSHIFT[ f[REST[l]][g] ][ g[FIRST[l]] ][ p ] }
	]
}}}
]
#这个map适用于任意元操作，
#MAP[RANGE[ZERO][FIVE]][SUBTRACT[TWO]]
#如果map中的元素不是要执行操作的最后一个参数，构建一个proc 作为新操作即可：
#MAP[RANGE[TWO][FIVE]][->x{SUBTRACT[x][TWO]}]

#Char
#我们只需要0-9和BFiuz，对0-9就编码ZERO-NINE，字母编码TEN-FOURTEEN
B = TEN
F = INCREMENT[TEN]
I = INCREMENT[F]
U = INCREMENT[I]
ZED = INCREMENT[U]
def to_char(c)
	'0123456789BFiuz'.slice(to_integer(c))
end
def to_string(s)
	to_array(s).map {|c| to_char(c)}.join 
end
#最后我们需要一个num.to_s
#先把四则运算补全
DIVIDE = Z[ ->f{ ->x{ ->y{
	IF[ IS_LESS_OR_EQUAL[y][x] ][
		INCREMENT[ ->p{f[SUBTRACT[x][y]][y][p]} ]
  ][
		ZERO
  ]
}}}
]
#对List的push_back操作
PUSH = Z[ ->f{ ->l{ ->x{
	IF[IS_EMPTY[l]][
		UNSHIFT[EMPTY][x]
  ][
	  UNSHIFT[ ->p{f[REST[l]][x][p]} ][FIRST[l]]
	]
}}}]
NINE = DECREMENT[TEN]
#不用PUSH 的话，解出来的顺序是反的
TO_DIGITS = Z[ ->f{ ->n{
	PUSH[
		IF[ IS_LESS_OR_EQUAL[n][NINE] ][
			EMPTY
		][
			->p{ f[ DIVIDE[n][TEN] ][p] } 
		]
  ][ MOD[n][TEN] ]
}}
]
