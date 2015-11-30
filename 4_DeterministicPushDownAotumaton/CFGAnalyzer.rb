#Context-Free Grammar Analyzer
#上下文无关语法分析
require_relative 'DPDA'
require_relative 'LexicalAnalyzer'

class CFGAnalyzer < Struct.new(:sentence)
	def self.rulebook
		start_rule = PDARule.new(1,nil,2,'$',['S','$'])
		stop_rule = PDARule.new(2,nil,3,'$',['$'])
		symbol_rules = [
			#Sentence ::= While | Assignment
			PDARule.new(2,nil,2,'S',['W']),
			PDARule.new(2,nil,2,'S',['A']),
			#While ::= w ( Expression ) { Sentence }
			PDARule.new(2,nil,2,'W',['w','(','E',')','{','S','}']),
			#Assignment ::= v = Expression 
			PDARule.new(2,nil,2,'A',['v','=','E']),
			#Expression ::= LessThan
			PDARule.new(2,nil,2,'E',['L']),
			#LessThan ::= Mutiply < LessThan | Multiply
			PDARule.new(2,nil,2,'L',['M','<','L']),
			PDARule.new(2,nil,2,'L',['M']),
			#Multiply ::= Term * Multiply | Term
			PDARule.new(2,nil,2,'M',['T','*','M']),
			PDARule.new(2,nil,2,'M',['T']),
			#Term ::= n | v
			PDARule.new(2,nil,2,'T',['n']),
			PDARule.new(2,nil,2,'T',['v'])
		]
		token_rules = LexicalAnalyzer::GRAMMAR.map do |rule|
			PDARule.new(2,rule[:token],2,rule[:token],[])
		end
		NPDARulebook.new([start_rule,stop_rule]+symbol_rules+token_rules)
	end
	def analyze
		token_string = LexicalAnalyzer.new(sentence).analyze.join
		NPDADesign.new(1,'$',[3],CFGAnalyzer.rulebook).accepts?(token_string)
	end
end
