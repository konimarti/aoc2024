module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result part1: %d", part1());
		io::printfn("result part2: %d", part2());
		// Output:
		// result part1: 549
		// result part2: 589
	};
}

def LongList = List(<long>);

// returns 1 if safe, else 0
fn int count_safety(LongList l)
{
	long d;
	LongList diff;
	diff.temp_init(10);

	if (l.len() < 2) return 0;

	for (usz i = 0; i < (l.len()-1); i++)
	{
		d = l[i+1] - l[i];
		if (math::abs(d) < 1 || math::abs(d) > 3) return 0;
		diff.push(d);
	}

	bool negative = diff.pop()!! < 0; 
	while (diff.len())
	{
		if (diff.pop()!! < 0)
		{
			if (!negative) return 0;
		}
		else
		{
			if (negative) return 0;
		}
	}

	return 1;
}

fn long part1()
{
	// File f = file::open("input_test", "r+")!!;
	File f = file::open("input", "r+")!!;

	long count = 0;

	LongList l;
	l.temp_init(10);

	while (try line = io::treadline(&f))
	{
		l.clear();
		foreach (i, level : line.split(" "))	
		{
			l.push(level.to_long()!!);
		}

		count += count_safety(l);
	}

	return count;
}

fn long part2()
{
	// File f = file::open("input_test", "r+")!!;
	File f = file::open("input", "r+")!!;

	long count = 0;

	LongList l;
	l.temp_init(10);

	while (try line = io::treadline(&f))
	{
		l.clear();
		foreach (i, level : line.split(" "))	
		{
			l.push(level.to_long()!!);
		}

		if (count_safety(l) > 0)
		{
			count += 1;
		}
		else
		{
			// eliminate an element, check again
			LongList tmp;
			for FOR: (usz i = 0; i < l.len(); i++)
			{
				tmp.clear();
				tmp.temp_init_with_array(l.to_tarray());
				tmp.remove_at(i);
				if (count_safety(tmp) > 0)
				{
					count += 1;
					break FOR;
				}
			}
		}
	}

	return count;
}

