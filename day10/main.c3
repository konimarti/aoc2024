module aoc2024::app;

import std::io;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

def Pos = isz[<2>];
def ListPos = List(<Pos>);
def Map = List(<String>);

fn long part1()
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

	usz[] memo = mem::temp_new_array(usz, lines.len * lines[0].len);
	memo[..] = 0;

	ListPos queue;
	usz sum;
	usz sc;
	foreach (th : trailheads)
	{
		queue.clear();
		queue.temp_init();
		queue.push(th);
		sc = score(m, queue, memo);
		// io::printfn("th: %s, score: %d", th, sc);
		sum += sc;
	}

	return sum;
}

Pos[4] directions = {{1,0}, {-1,0}, {0,1}, {0,-1}};

fn usz score(Map m, ListPos queue, usz[] memo)
{
	isz xmax = m.len();
	isz ymax = m[0].len;
	char cur;
	Pos p;

	HashMap(<String,bool>) visited;
	visited.temp_init();

	while OUTER: (queue.len())
	{
		p = queue.pop()!!;
		cur = m[p.x][p.y];
		if (cur == '9')
		{
			visited[string::tformat("%s", p)] = true;
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

	return visited.len();
}
