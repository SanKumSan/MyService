using System.Diagnostics;
using NUnit.Framework;

namespace MyService.Test
{
    [TestFixture]
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }

        [TestCase(1, 1, 2)]
        [TestCase(16, 2, 18)]
        [TestCase(1, 2, 3)]
        public void Test1(int a, int b, int c)
        {
            var result = AddTwoNumbers(a, b);
            Assert.That(result, Is.EqualTo(c));
        }

        [TestCase(1, 1, 2)]
        [TestCase(16, 2, 18)]
        [TestCase(1, 2, 3)]
        public void Test2(int a, int b, int c)
        {
            var result = AddTwoNumbers(a, b);
            Assert.That(result, Is.EqualTo(c));
        }

        public int AddTwoNumbers(int a, int b)
        {
            return a+b;
        }

        private string GetDebuggerDisplay()
        {
            return ToString();
        }
    }
}