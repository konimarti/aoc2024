module aoc2024::app;

import std::io;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", solve(25));
		// io::printfn("result: part 2: %d", solve(75));
	};
}

struct Stone
{
	String s;
	usz n;
}

def ListStone = List(<Stone>);

fn usz solve(usz nblink)
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;
	s = s.trim();

	ListStone stack;

	usz count = 0;
	foreach (number : s.tsplit(" "))
	{
		number = number.trim();
		if (!number.len) continue;

		io::printfn("count: %s", number);
		
		stack.temp_init();
		stack.push({.s=number, .n=0});
		count += count_stones(stack, nblink);
	}

	return count;
}

fn String process(String s, long mult = 1)
{
	long u = s.to_long()!! * mult;
	return string::tformat("%d", u);
}

fn usz count_stones(ListStone stack, usz n)
{
	Stone s;
	usz count = 0;
	while (stack.len())
	{
		s = stack.pop()!!;
		if (s.n == n)
		{
			count++;
			continue;
		}

		switch
		{
			case s.s == "0":
				stack.push({"1", s.n+1});
			case s.s.len % 2 == 0:
				stack.push({process(s.s[s.s.len/2..]), s.n+1});
				stack.push({process(s.s[0:s.s.len/2]), s.n+1});
			case s.s.len % 2 == 1:
				stack.push({process(s.s, 2024), s.n+1});
		}
	}

	return count;
}
