module aoc2024::app;

import std::io, std::math, std::collections::list;
import std::collections::priorityqueue;

fn void! main()
{
	@pool()
	{
		part1and2();
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

fn void part1and2()
{
	Map m = load_map();
	Vec east = {0, 1};
	solve(m, m.start, east, 0);
}


struct PosDir
{
	Vec p;
	Vec d;
	long score;
}
fn bool PosDir.equals(&a, PosDir b) => a.p == b.p && a.d == b.d;

def Heap = PriorityQueue(<PosDir>);
def Entry = PosDir;
fn int Entry.compare_to(&self, Entry other) => compare_to(self.score, other.score); 


fn void solve(Map m, Vec p, Vec d, long score)
{
	List(<PosDir>) stack;
	stack.temp_init().push({p, d, score});

	List(<PosDir>) visited;
	visited.temp_init();

	Heap heap;
	heap.temp_init();

	while LOOP: (stack.len())
	{
		PosDir pd = stack.pop_first()!!;
		p = pd.p;
		d = pd.d;

		if (heap.len() > 0 && pd.score > heap.first()!!.score) continue;
		if (m.m[p.x][p.y] == BLOCK) continue;

		if (try index = visited.index_of(pd))
		{
			if (visited[index].score <= pd.score) continue LOOP;
			visited[index] = pd;
		}
		else
		{
			visited.push(pd);
		}

		if (m.m[p.x][p.y] == END)
		{
			heap.push(pd);
			continue;
		}

		stack.push({p+d, d, pd.score + 1});
		stack.push({p+{d.y, -d.x}, {d.y, -d.x}, pd.score + 1001});
		stack.push({p+{-d.y, d.x}, {-d.y, d.x}, pd.score + 1001});
	}

	io::printfn("result: part 1: %d", heap.first()!!.score);
	io::printfn("result: part 2: %d", backwards(m, visited, heap.first()!!.score));
}

fn long backwards(Map m, List(<PosDir>) visited, long lowest)
{
	List(<PosDir>) stack;
	stack.temp_init();

	foreach (v : visited)
	{
		if (v.p == m.end && v.score == lowest) stack.push(v);
	}

	bool[200][200] path;
	path[0][..] = false;
	path[..] = path[0];

	path[m.start.x][m.start.y] = true;

	while LOOP: (stack.len())
	{
		PosDir pd = stack.pop_first()!!;
		Vec p = pd.p;
		Vec d = pd.d;

		switch (m.m[p.x][p.y])
		{
			case BLOCK: continue;
			case START: continue;
		}

		if (try index = visited.index_of(pd) && visited[index].score == pd.score)
		{
			stack.push({p-d, d, pd.score - 1});
			stack.push({p-d, {d.y, -d.x}, pd.score - 1001});
			stack.push({p-d, {-d.y, d.x}, pd.score - 1001});
			path[p.x][p.y] = true;
			visited.remove_at(index);
		}
	}

	long counts;
	for (usz i = 0; i < 200; i++)
	{
		for (usz j = 0; j < 200; j++)
		{
			if (path[i][j]) counts++;

		}
	}

	return counts;
}

