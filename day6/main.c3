module aoc2024::app;

import std::io;
import std::collections::list;
import std::math;

fn void! main()
{
	@pool()
	{
		solve();
		// io::printfn("result part1: %d", part1());
		// io::printfn("result part2: %d", part2());
	};
}

def Map = List(<String>);
def Pos = Complex(<isz>);

const IMG = Pos{0, -1};
const BLOCK = '#';

fn void solve()
{
	String s = (String)file::load_temp("input_test")!!;
	// String s = (String)file::load_temp("input")!!;

	Map map;
	map.temp_init(256);

	Pos start;

	foreach (i, line : s.tsplit("\n"))
	{
		if (!line.len) continue;
		usz! n = line.index_of_char('^');
		if (try n) start = Pos{i, n};
		map.push(line);
	}

	io::printfn("result part1: %d", play(map,start));

	io::printfn("result part2: %d", loops(map,start));
}

fn bool offgrid(Pos guard, usz xmax, usz ymax)
{
	if (guard.r < 0 || guard.r >= xmax) return true;
	if (guard.c < 0 || guard.c >= ymax) return true;
	return false;
}

fn long play(Map map, Pos start)
{
	Pos guard = start;
	Pos dir = {-1, 0};
	Pos next;

	usz xmax = map.len();
	usz ymax = map[0].len;

	io::printfn("start: %s", start.v);
	io::printfn("xmax: %s", xmax);
	io::printfn("ymax: %s", ymax);

	usz count = 0;
	bool[256][256] visited;

	while (true)
	{
		if (!visited[guard.r][guard.c])
		{
			count++;
			visited[guard.r][guard.c] = true;
		}

		// peek ahead, if obstacle
		next = guard.add(dir);
		if (offgrid(next, xmax, ymax)) break;

		if (map[next.r][next.c] == BLOCK)
		{
			// turn right
			dir = dir.mul(IMG);
		}
		else
		{
			guard = next;
		}
	}

	return count;
}

fn long loops(Map map, Pos start)
{
	usz loop = 0;
	usz xmax = map.len();
	usz ymax = map[0].len;

	for (isz i = 0; i < xmax; i++)
	{
		for (isz j = 0; j < ymax; j++)
		{
			if (is_loop(map, start, Pos{i, j})) loop++;
			io::printn("next");
		}
	}
	return loop;
}

fn bool is_loop(Map map, Pos start, Pos obs)
{
	Pos guard = start;
	Pos dir = {-1, 0};
	Pos next;

	Pos ini_guard = guard;
	Pos ini_dir = dir;

	usz xmax = map.len();
	usz ymax = map[0].len;

	usz loops = 0;

	long max_retries = xmax * ymax;
	while (max_retries--)
	{
		next = guard.add(dir);
		if (offgrid(next, xmax, ymax)) break;

		if (map[next.r][next.c] == BLOCK || next.v == obs.v)
		{
			// turn right
			dir = dir.mul(IMG);
		}
		else
		{

			if (next.v == ini_guard.v && dir.v == ini_dir.v)
			{
				// we have a loop!
				return true;
			}

			guard = next;
		}
	}

	return false;
}
