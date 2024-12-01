module aoc2024::app;

import std::io;
import std::sort;
import std::math;
import std::collections::list;
import std::collections::map;

def LongList = List(<long>);

fn long part1(LongList l, LongList r)
{
	sort::quicksort(l);
	sort::quicksort(r);

	long dist = 0;
	foreach (i, lv : l)
	{
		dist += math::abs(r[i] - lv);
	}

	return dist;
}


fn long part2(LongList l, LongList r)
{
	HashMap(<long, long>) map;
	map.temp_init(1000);

	foreach (rv : r)
	{
		map[rv] = map.@get_or_set(rv, 0) + 1;
	}

	long score = 0;
	foreach (lv : l)
	{
		if (try v = map[lv]) score += v * lv;
	}

	return score;
}


fn void! main()
{
	File f = file::open("input", "r+")!;
	defer (void)f.close();

	LongList left;
	LongList right;

	@pool()
	{
		left.temp_init(1000);
		right.temp_init(1000);

		while (true)
		{
			String! line = io::treadline(&f);
			if (catch line) break;

			String[] values = line.tsplit("   ");
			if (!values.len) break;

			left.push(values[0].to_long()!!);
			right.push(values[1].to_long()!!);
		}
		io::printfn("result part1: %d", part1(left, right));
		io::printfn("result part2: %d", part2(left, right));

		// Output:
		// result part2: 2176849
		// result part2: 23384288
	};
}
