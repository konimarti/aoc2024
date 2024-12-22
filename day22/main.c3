module aoc2024::app;

import std::io, std::time, std::collections::map;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
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
fn ulong part2() => solve2();

fn ulong solve()
{
	ulong sum;
	foreach (secret: secrets()) sum += run(secret, 2000);
	return sum;
}

union Seq
{
	ichar[4] c;
	uint h;
}
fn uint Seq.hash(&self) => self.h;
fn bool Seq.equals(&self, Seq other) => self.h == other.h;
fn usz! Seq.to_format(&self, Formatter *f) @dynamic => f.printf("%s", self.c);

def SeqMap = HashMap(<Seq, long>);

fn ulong solve2()
{
	// we need to loop 2001 times to get 2000 price *changes*
	uint n = 2001;
	ichar[] changes = mem::temp_new_array(ichar, n);

	SeqMap m;
	m.temp_init(n);

	SeqMap visited;
	visited.temp_init(n);

	foreach (secret: secrets())
	{
		char last_digit, prev_digit;
		visited.clear();
		for (int i = 0; i < n; i++)
		{
			secret = run(secret);
			last_digit = (char)(secret % 10);
			if (i > 0) changes[i] = last_digit - prev_digit;
			prev_digit = last_digit;

			if (i >= 4)
			{
				// subtract -3 because we want the
				// current element in the list
				Seq key = {.c = changes[(i - 3):4]};

				if (visited.has_key(key)) continue;
				visited.set(key, 0);

				m.set(key, (m.get(key) ?? 0) + last_digit);
			}
		}
	}

	ulong bananas;
	m.@each(; Seq key, long value)
	{
		if (value > bananas) bananas = value;
	};

	return bananas;
}


fn ulong mix(ulong a, ulong b) @inline => a ^ b;
fn ulong prune(ulong a) @inline => a % 16777216;

fn ulong run(ulong secret, usz rounds = 1)
{
	while (rounds--)
	{
		secret = prune(mix(secret, secret * 64));
		secret = prune(mix(secret, secret / 32));
		secret = prune(mix(secret, secret * 2048));
	}
	return secret;
}
