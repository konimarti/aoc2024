module aoc2024::app;

import std::io;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		solve();
	};
}

def Pos = isz[<2>];
def ListPos = List(<Pos>);
def Map = List(<String>);
def TrailRating = HashMap(<String,int>);

fn void solve()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;
	s = s.trim();

	Map m;
	m.temp_init();

	ListPos trailheads;
	trailheads.temp_init();

	String[] lines = s.tsplit("\n");
	foreach (x, line : lines)
	{
		if (!line.len) continue;
		m.push(line);
		foreach (y, c : line)
		{
			if (c == '0') trailheads.push({x,y});
		}
	}

	ListPos queue;
	usz sum;
	usz rating;
	foreach (th : trailheads)
	{
		queue.clear();
		queue.temp_init();
		queue.push(th);
		TrailRating tr = score(m, queue);
		sum += tr.len();
		tr.@each(; String key, int v){ rating += v; };
	}

	io::printfn("result: part 1: %d", sum);
	io::printfn("result: part 2: %d", rating);
}

Pos[4] directions = {{1,0}, {-1,0}, {0,1}, {0,-1}};

// bfs
fn TrailRating score(Map m, ListPos queue)
{
	Pos p;
	char cur;
	isz xmax = m.len();
	isz ymax = m[0].len;

	HashMap(<String,int>) visited;
	visited.temp_init();

	while OUTER: (queue.len())
	{
		p = queue.pop()!!;
		cur = m[p.x][p.y];
		if (cur == '9')
		{
			String key = string::tformat("%s", p);
			if (!visited.has_key(key)) visited[key] = 0;
			(*visited.get_ref(key)!!)++;
			continue OUTER;
		}

		foreach (dir : directions)
		{
			Pos next = p + dir;
			if (next.x < 0 || next.x >= xmax) continue;
			if (next.y < 0 || next.y >= ymax) continue;
			if (m[next.x][next.y] - cur != 1) continue;
			queue.push(next);
		}
	}

	return visited;
}
