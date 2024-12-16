module aoc2024::app;

import std::io, std::math, std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

const char BLOCK = '#';
const char START = 'S';
const char END = 'E';

def Vec = long[<2>];

struct Map
{
	List(<String>) m;
	Vec start;
}

fn Map load_map()
{
	$switch
	$case $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$case $feature(TEST2):
		String input = (String)file::load_temp("input_test_2")!!;
	$default:
			String input = (String)file::load_temp("input")!!;
	$endswitch

	Map m;
	m.m.temp_init();
	foreach (x, line : input.tsplit("\n"))
	{
		String s = line.trim().tcopy();
		if (try y = s.index_of_char(START))
		{
			m.start = {x, y};
			
		}
		m.m.push(s);
	}
	return m;
}

fn long part1()
{
	Map m = load_map();
	Vec east = {0, 1};
	return solve(m, m.start, east, 0).score;
}
fn long part2() => 0;

struct PosDir
{
	Vec p;
	Vec d;
	long score;
}
fn bool PosDir.equals(&a, PosDir b) => a.p == b.p && a.d == b.d;

// use dfs to find path through the maze, update visited nodes if score of new
// path is lower.
fn PosDir solve(Map m, Vec p, Vec d, long score)
{
	
	List(<PosDir>) stack;
	stack.temp_init().push({p, d, score});

	List(<PosDir>) visited;
	visited.temp_init();

	PosDir min = {p,d,long.max};

	while LOOP: (stack.len())
	{
		PosDir pd = stack.pop_first()!!;
		p = pd.p;
		d = pd.d;

		if (pd.score > min.score) continue;

		switch (m.m[p.x][p.y])
		{
			case BLOCK:
				continue;
			case END:
				if (pd.score < min.score) min = pd;
				continue;
		}

		if (try index = visited.index_of(pd))
		{
			if (visited[index].score <= pd.score) continue LOOP;
			visited[index] = pd;
		}
		else
		{
			visited.push(pd);
		}

		stack.push({p+d, d, pd.score + 1});
		stack.push({p+{d.y, -d.x}, {d.y, -d.x}, pd.score + 1001});
		stack.push({p+{-d.y, d.x}, {-d.y, d.x}, pd.score + 1001});
	}

	return min;
}
