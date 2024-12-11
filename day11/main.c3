module aoc2024::app;

import std::io;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", solve(25));
		io::printfn("result: part 2: %d", solve(75));
	};
}

fn usz solve(usz nblink)
{
	$if $feature(TEST):
	String s = (String)file::load_temp("input_test")!!;
	$else
	String s = (String)file::load_temp("input")!!;
	$endif

	usz count = 0;
	foreach (number : s.trim().tsplit(" "))
	{
		count += count_stones(number, nblink);
	}
	return count;
}

fn String proc(String s, long m = 1) @inline => string::tformat("%d", s.to_long()!! * m);

def Memo = HashMap(<String, usz>);

fn usz count_stones(String s, usz n, Memo *memo = Memo{}.temp_init())
{
	usz count;
	if (n == 0) return 1;

	String key = string::tformat("%d|%s", n, s);
	if (memo.has_key(key)) return memo.get(key)!!;
	defer memo.set(key, count);

	switch
	{
		case s == "0":
			count += count_stones("1", n - 1, memo);
		case s.len % 2 == 1:
			count += count_stones(proc(s, 2024), n - 1, memo);
		case s.len % 2 == 0:
			count += count_stones(proc(s[0:s.len/2]), n - 1, memo);
			count += count_stones(proc(s[s.len/2..]), n - 1, memo);
	}

	return count;
}
