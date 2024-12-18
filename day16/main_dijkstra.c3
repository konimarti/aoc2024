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
	Vec end;
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
		if (try y = s.index_of_char(START)) m.start = {x, y};
		if (try y = s.index_of_char(END)) m.end = {x, y};
		m.m.push(s);
	}
	return m;
}

fn long part1()
{
	Map m = load_map();
	Vec east = {0, 1};
	io::printfn("dijstra: %d", dijkstra(m));
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

import std::collections::priorityqueue;

def Entry = PosDir;
fn int Entry.compare_to(&self, Entry other) => compare_to(self.score, other.score); 

def Heap = PriorityQueue(<Entry>);

Vec[4] dirs = {{1,0},{-1,0},{0,1},{0,-1}};
fn long dijkstra(Map m)
{
	Heap min_queue;
	min_queue.temp_init();

	min_queue.push({m.start, {0,1}, 0});
	foreach (x, line : m.m)
	{
		foreach (y, c : line)
		{
			if (c == '.' || c == END)
			{
				foreach (d : dirs) min_queue.push({{x,y},d,long.max});
			}
		}
	}

	io::printfn("min_queue start elements: %d", min_queue.len());

	while (min_queue.len())
	{
		PosDir u = min_queue.pop()!!;
		if (u.p == m.end) return u.score;
		if (u.score == long.max) continue;
		io::printfn("pick u from heap: %d", u.score);

		// adjacent vertex
		Vec[3] dirs = {u.d, {u.d.y, -u.d.x}, {-u.d.y, u.d.x}};
		long[3] cost = {1, 1001, 1001};
		foreach (i, d : dirs)
		{
			Vec n = u.p + d;
			if (m.m[n.x][n.y] == BLOCK) continue;

			usz index;
			PosDir pd;
			for (index = 0; index < min_queue.len(); index++)
			{
				pd = min_queue.get(index);
				if (pd.p == n && pd.d == d)
				{
					// update score
					if (pd.score > u.score + cost[i])
					{
						pd.score = u.score + cost[i];
						min_queue.remove_at(index);
						min_queue.push(pd);
					}
				}
			}

		}
	}
	if (min_queue.len()) return min_queue.first()!!.score;
	return -1;
}
