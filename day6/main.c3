module aoc2024::app;

import std::io;
import std::collections::list;
import std::math;

fn void! main()
{
	@pool()
	{
		solve();
	};
}

def Map = List(<String>);
def Pos = Complex(<isz>);

const IMG = Pos{0, -1};
const BLOCK = '#';

fn void solve()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

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

	io::printfn("result part1: %d", part1(map,start).len());

	io::printfn("result part2: %d", part2(map,start));
}

fn bool offgrid(Pos guard, usz xmax, usz ymax)
{
	if (guard.r < 0 || guard.r >= xmax) return true;
	if (guard.c < 0 || guard.c >= ymax) return true;
	return false;
}

fn List(<Pos>) part1(Map map, Pos start)
{
	Pos guard = start;
	Pos dir = {-1, 0};
	Pos next;

	usz xmax = map.len();
	usz ymax = map[0].len;

	List(<Pos>) list;
	list.temp_init();

	bool[256][256] visited;

	while (true)
	{
		if (!visited[guard.r][guard.c])
		{
			visited[guard.r][guard.c] = true;
			list.push(guard);
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

	return list;
}

fn long part2(Map map, Pos start)
{
	usz loop = 0;
	foreach (i, opt : part1(map,start))
	{
		if (opt.v == start.v) continue;
		if (is_loop(map, start, opt))
		{
			loop++;
			io::printfn("[%d] loop: %d", i, loop);
		}
	}
	return loop;
}

fn bool is_loop(Map map, Pos start, Pos obs)
{
	Pos guard = start;
	Pos dir = {-1, 0};
	Pos next;

	List(<Pos[2]>) visited;
	visited.temp_init(256);

	usz xmax = map.len();
	usz ymax = map[0].len;

	while (true)
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
			foreach (v : visited)
			{
				if (next.v == v[0].v && dir.v == v[1].v) return true; // we have a loop
			}
			visited.push({next, dir});
			guard = next;
		}
	}
	return false;
}
