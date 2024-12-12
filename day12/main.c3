module aoc2024::app;

import std::io;
import std::collections::map;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		solve();
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

fn void solve()
{
	$if $feature(TEST):
	String s = (String)file::load_temp("input_test")!!;
	$else
	String s = (String)file::load_temp("input")!!;
	$endif

	String[] lines = s.trim().tsplit("\n");

	Garden garden;
	garden.temp_init();

	Pos pos;

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

	long sum1;
	foreach (r : garden)
	{
		// io::printfn("region %c, area %d, fences %d", r.c, r.plots.len(), r.fences);
		sum1 += r.plots.len() * r.fences;
	}
	io::printfn("result: part 1: %d", sum1);

	long sum2;
	foreach (r : garden)
	{
		long nfences = bulk(r, lines);
		sum2 += r.plots.len() * nfences;
	}
	io::printfn("result: part 2: %d", sum2);
}

fn long bulk(Region r, String[] m)
{
	return horizontal(r,m) + vertical(r,m);
}

fn long count(bool[] line) @inline
{
	long ctr = 0;
	bool track = false;
	foreach (x, now : line)
	{
		if (!track && now) ctr++;
		track = now;
	}
	return ctr;
}

fn long vertical(Region r, String[] m)
{
	long fences;
	bool[] line = mem::temp_new_array(bool, m.len);

	// left-most line
	foreach (x, &now : line)
	{
		*now = r.plots.contains({(int)x,(int)0});
	}
	fences += count(line);

	// righ-most line
	foreach (x, &now : line)
	{
		*now = r.plots.contains({(int)x,(int)m[0].len-1});
	}
	fences += count(line);

	// in-between line (looking left)
	for (int y = 1; y < m[0].len; y++)
	{
		line[..] = false;
		for (int x = 0; x < m.len; x++)
		{
			line[x] = r.plots.contains({(int)x,(int)y}) && m[x][y-1] != r.c;
		}
		fences += count(line);
	}

	// in-between line (looking right)
	for (int y = 0; y < m[0].len-1; y++)
	{
		line[..] = false;
		for (int x = 0; x < m.len; x++)
		{
			line[x] = r.plots.contains({(int)x,(int)y}) && m[x][y+1] != r.c;
		}
		fences += count(line);
	}

	return fences;
}

fn long horizontal(Region r, String[] m)
{
	long fences;
	bool[] line = mem::temp_new_array(bool, m[0].len);

	// top-most row
	foreach (y, &now : line)
	{
		*now = r.plots.contains({0,(int)y});
	}
	fences += count(line);

	// bootom-most row
	foreach (y, &now : line)
	{
		*now = r.plots.contains({(int)m.len-1,(int)y});
	}
	fences += count(line);

	// in-between line (looking up)
	for (int x = 1; x < m.len; x++)
	{
		line[..] = false;
		for (int y = 0; y < m[0].len; y++)
		{
			line[y] = r.plots.contains({x,y}) && m[x-1][y] != r.c;
		}
		fences += count(line);
	}

	// in-between line (looking right)
	for (int x = 0; x < m.len-1; x++)
	{
		line[..] = false;
		for (int y = 0; y < m[0].len; y++)
		{
			line[y] = r.plots.contains({x,y}) && m[x+1][y] != r.c;
		}
		fences += count(line);
	}

	return fences;

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


