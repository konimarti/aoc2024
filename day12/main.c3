module aoc2024::app;

import std::io;
import std::collections::map;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", solve());
		// io::printfn("result: part 2: %d", solve(75));
	};
}

def Pos = int[<2>];

struct Region 
{
	char c;
	List(<Pos>) plots;
	long fences;
}

def Garden = List(<Region>);

fn long solve()
{
	$if $feature(TEST):
	String s = (String)file::load_temp("input_test")!!;
	$else
	String s = (String)file::load_temp("input")!!;
	$endif

	String[] lines = s.trim().tsplit("\n");

	Garden garden;
	garden.temp_init();

	Pos[4] dirs = {{1,0}, {-1,0}, {0,1}, {0,-1}};
	Pos max = {lines.len, lines[0].len};
	Pos pos, n;

	List(<Pos>) visited;
	visited.temp_init();

	foreach (x, line : lines)
	{
		foreach (y, c : line)
		{
			pos = {(int)x,(int)y};
			if (visited.contains(pos)) continue;
			Region r = {c, *List(<Pos>){}.temp_init(), 0};
			collect(&r, pos, lines, &visited);
			garden.push(r);
		}
	}

	// loop through garden
	long sum;
	foreach (r : garden)
	{
		io::printfn("region %c, area %d, fences %d", r.c, r.plots.len(), r.fences);
		sum += r.plots.len() * r.fences;
	}

	return sum;
}

fn void collect(Region *r, Pos start, String[] map, List(<Pos>) *visited)
{
	List(<Pos>) queue;
	queue.temp_init();
	queue.push(start);

	Pos[] directions = {{1,0}, {-1,0}, {0,1}, {0,-1}};

	while (queue.len())
	{
		Pos p = queue.pop()!!;
		if (visited.contains(p)) continue;

		visited.push(p);
		r.plots.push(p);
		r.fences += 4;

		foreach (dir : directions)
		{
			Pos n = p + dir;
			if (n.x < 0 || n.x >= map.len) continue;
			if (n.y < 0 || n.y >= map[0].len) continue;
			if (map[n.x][n.y] == r.c)
			{
				r.fences--;
				queue.push(n);
			}
		}
	}
}


