module aoc2024::app;

import std::io;
import std::time;
import std::math;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		// io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

fn ulong[] secrets()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	String[] lines = input.trim().tsplit("\n");
	ulong[] nums = mem::temp_new_array(ulong, lines.len);
	foreach (i, line: lines) nums[i] = line.to_ulong()!!;
	return nums;
}

fn ulong part1() => solve();
// fn long part2() => solve(26);

fn ulong solve()
{
	ulong sum;
	foreach (secret: secrets()) sum += num2000(secret);
	return sum;
}

fn ulong num2000(ulong secret)
{
	usz rounds = 2000;
	while (rounds--)
	{
		secret = mul_step(secret, 64);
		secret = div_step(secret);
		secret = mul_step(secret, 2048);
	}
	return secret;
}


fn ulong mul_step(ulong secret, ulong factor)
{
	secret ^= secret * factor;
	secret %= 16777216;
	return secret;
}

fn ulong div_step(ulong secret)
{
	secret ^= secret / 32;
	secret %= 16777216;
	return secret;
}
