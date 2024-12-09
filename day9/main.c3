module aoc2024::app;

import std::io;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		io::printfn("result: part 2: %d", part2());
	};
}

fn long part1()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;
	s = s.trim();
	long[] mem = expand(s);
	reorder_part1(mem);
	return sumup(mem);
}

fn long part2()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;
	s = s.trim();
	long[] mem = expand(s);
	reorder_part2(mem);
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

fn void reorder_part1(long[] mem)
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

fn void reorder_part2(long[] mem)
{
	isz l, r, n;
	usz k, j;
	n = mem.len;
	r = n-1;
	while (r >= 0)
	{
		// move r to end of the next file position
		while (mem[r] == -1 && r >= 0) r--;

		// get length k of next file block
		k = 0;
		while (r-k >= 0 && mem[r-k] == mem[r]) k++;

		// find first free block at l with enough space j
		l = 0;
		while FREE: (l < r-k)
		{
			// count free space j from start position l
			j = 0;
			while (j < k && mem[l+j] == -1) j++;

			// if free space j is equal to required length k,
			// then move block
			if (j == k)
			{
				// we have enough space, move block
				for (j = 0; j < k; j++) @swap(mem[l+j], mem[r-j]);
				break FREE;
			}
			l++;
		}
		r = r - k;
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
