require_relative 'Tape'
require_relative 'TM'

puts '---------------------------------Tape--------------------------------------'
tape = Tape.new(['1','0','1'],'1',[],'_')
puts tape.inspect
puts tape.write('0').inspect
puts tape.move_head_left.inspect
puts tape.move_head_right.inspect
puts '--------------------------------TMRule-------------------------------------'
rule = TMRule.new(1,'0',2,'1',:right)
puts rule.inspect
puts rule.applies_to?(TMConfiguration.new(1,Tape.new([],'0',[],'_')))
puts rule.applies_to?(TMConfiguration.new(1,Tape.new([],'1',[],'_')))
puts rule.follow(TMConfiguration.new(1,Tape.new([],'0',['0'],'_')))
puts '-------------------------------TMRuleboox----------------------------------'
# 一个二进制数自增的Rulebook
increaseRulebook = DTMRulebook.new(
	[
	TMRule.new(1,'0',2,'1',:right),
  TMRule.new(1,'1',1,'0',:left),
  TMRule.new(2,'0',2,'0',:right),
  TMRule.new(2,'1',2,'1',:right),
  TMRule.new(2,'_',3,'_',:left),
  ]
)
dtm = DTM.new(TMConfiguration.new(1, Tape.new(['1','0','0'],'1',[],'_') ), [3], increaseRulebook)
puts dtm.current_configuration
dtm.run
puts dtm.current_configuration
dtm = DTM.new(TMConfiguration.new(1, Tape.new(['1','0','0'],'2',[],'_') ), [3], increaseRulebook)
puts dtm.current_configuration
dtm.run
puts dtm.current_configuration
puts dtm.stuck?
# 一个以若干a开头后面跟等量的b和c的Rulebook
# eg: aabbcc
tripletsRulebook = DTMRulebook.new(
	[
	#状态1，向右扫描寻找a，找到替换为x
	TMRule.new(1,'a',2,'x',:right),
	TMRule.new(1,'x',1,'x',:right),
	TMRule.new(1,'_',6,'_',:left), #6是接受状态
	#状态2，向右扫描寻找b，找到替换为x
  TMRule.new(2,'b',3,'x',:right),
  TMRule.new(2,'x',2,'x',:right),
  TMRule.new(2,'a',2,'a',:right),
	#状态3，向右扫描寻找c，找到替换为x
  TMRule.new(3,'c',4,'x',:right),
  TMRule.new(3,'b',3,'b',:right),
  TMRule.new(3,'x',3,'x',:right),
	#状态4，向右到达结尾
  TMRule.new(4,'_',5,'_',:left),
  TMRule.new(4,'c',4,'c',:right),
	#状态5，向左到达开头
  TMRule.new(5,'_',1,'_',:right), #到达开头，进入状态1
  TMRule.new(5,'x',5,'x',:left),
  TMRule.new(5,'c',5,'c',:left),
  TMRule.new(5,'b',5,'b',:left),
  TMRule.new(5,'a',5,'a',:left),
  ]
)
dtm = DTM.new(TMConfiguration.new(1, Tape.new([],'a',['a','b','b','c','c'],'_') ), [6], tripletsRulebook)
dtm.run
puts dtm.current_configuration
puts dtm.stuck?
dtm = DTM.new(TMConfiguration.new(1, Tape.new([],'a',['a','b','b','c','c','c'],'_') ), [6], tripletsRulebook)
dtm.run
puts dtm.current_configuration
puts dtm.stuck?
