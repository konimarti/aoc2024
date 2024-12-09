module aoc2024::app;

import std::io;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

fn long part1()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;
	s = s.trim();
	long[] mem = expand(s);
	reorder(mem);
	return sumup(mem);
}

fn long[] expand(String blocks)
{
	List(<long>) line;
	line.temp_init(256);

	// expand blocks
	long w;
	foreach (i, c : blocks)
	{
		switch (i % 2)
		{
			case 0:
				w = (long)i/2;
			case 1:
				w = -1;
		}
		usz n = (usz)(c - '0');
		for (usz j = 0; j < n; j++) line.push(w);
	}

	return line.array_view();
}

fn void reorder(long[] mem)
{
	isz l, r, n;
	n = mem.len;
	r = n-1;
	while (l < r)
	{
		// move l to next free position '.'
		while (mem[l] != -1 && l < n) l++;

		// move r to next file position != '.'
		while (mem[r] == -1 && r >= 0) r--;

		if (l >= r) break;
		@swap(mem[l], mem[r]);
	}
}

fn long sumup(long[] mem)
{
	long sum = 0;
	foreach (i, id : mem)
	{
		if (id >= 0) sum += (long)i * id;
	}
	return sum;
}
