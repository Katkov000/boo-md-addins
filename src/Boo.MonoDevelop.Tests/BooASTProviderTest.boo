namespace Boo.MonoDevelop.Tests

import NUnit.Framework
import ICSharpCode.NRefactory.Ast

[TestFixture]
class BooASTProviderTest(UnitTests.TestBase):

	[Test]
	def ParseTextWithClassHeaderReturnsTypeReference():
		code = "class Foo(Bar):"

		node = BooASTProvider().ParseText(code) as TypeReferenceExpression
		Assert.AreEqual("Foo", node.TypeReference.Type)