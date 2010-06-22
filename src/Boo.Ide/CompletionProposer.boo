namespace Boo.Ide

import Boo.Lang.Compiler.Ast

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Core

import Boo.Adt
import Boo.Lang.PatternMatching

import System.Linq.Enumerable

data CompletionProposal(Entity as IEntity)

static class CompletionProposer:
	
	def ForExpression(expression as Expression):
		match expression:
			case MemberReferenceExpression(Target: target=Expression(ExpressionType)) and ExpressionType is not null:
				
				if IsTypeReference(target):
					members = StaticMembersOf(ExpressionType)
				else:
					members = InstanceMembersOf(ExpressionType)
				
				membersByName = (member for member in members).GroupBy({ member as IEntity | member.Name })
				for member in membersByName:
					yield CompletionProposal(Entities.EntityFromList(member.ToList()))
			otherwise:
				pass
				
	def IsTypeReference(e as Expression):
		return TypeSystemServices.GetOptionalEntity(e) isa IType
				
	def InstanceMembersOf(type as IType):
		for member in AccessibleMembersOf(type):
			match member:
				case IAccessibleMember(IsStatic):
					yield member unless IsStatic
				otherwise:
					yield member
					
	def StaticMembersOf(type as IType):
		for member in AccessibleMembersOf(type):
			match member:
				case IAccessibleMember(IsStatic):
					yield member if IsStatic
				otherwise:
					yield member
				
	def AccessibleMembersOf(type as IType):
		currentType = type
		while currentType is not null:
			for member in currentType.GetMembers():
				if IsSpecialName(member.Name):
					continue
				match member:
					case IConstructor():
						continue
					case IEvent():
						yield member
					case IAccessibleMember(IsPublic):
						if IsPublic:
							yield member
					otherwise:
						continue
			currentType = currentType.BaseType
			
	_specialPrefixes = { "get_": 1, "set_": 1, "add_": 1, "remove_": 1, "op_": 1 }
	
	def IsSpecialName(name as string):
		index = name.IndexOf('_')
		return false if index < 0
		
		prefix = name[:index + 1]
		return prefix in _specialPrefixes

