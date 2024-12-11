module aoc2024::app;

import std::io;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		memo.temp_init();
		io::printfn("result: part 1: %d", solve(25));
		memo.clear();
		io::printfn("result: part 2: %d", solve(75));
	};
}

struct Stone
{
	String s;
}

def Memo = HashMap(<String, usz>);
Memo memo;

fn usz solve(usz nblink)
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	s = s.trim();

	usz count = 0;
	foreach (number : s.tsplit(" "))
	{
		number = number.trim();
		if (!number.len) continue;

		count += count_stones({number}, nblink);
	}

	return count;
}

fn String process(String s, long mult = 1)
{
	long u = s.to_long()!! * mult;
	return string::tformat("%d", u);
}

fn usz count_stones(Stone s, usz n)
{
	usz count;

	if (n == 0) return 1;

	String key = string::tformat("%d|%s", n, s.s);
	if (memo.has_key(key)) return memo.get(key)!!;

	switch
	{
		case s.s == "0":
			count += count_stones({"1"}, n-1);
		case s.s.len % 2 == 0:
			count += count_stones({process(s.s[s.s.len/2..])}, n-1);
			count += count_stones({process(s.s[0:s.s.len/2])}, n-1);
		case s.s.len % 2 == 1:
			count += count_stones({process(s.s, 2024)}, n-1);
	}

	memo.set(key, count);

	return count;
}
