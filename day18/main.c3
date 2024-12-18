module aoc2024::app;

import std::io, std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		io::printfn("result: part 2: %s", part2());
	};
}

def Vec = long[<2>];
def VecList = List(<long[<2>]>);

struct Mem
{
	char[] m;
	Vec size;
	VecList bytes;
}
fn bool Mem.inside(&self, Vec pos) => pos.comp_ge({0,0}).and() && pos.comp_lt(self.size).and();
fn char Mem.get(&self, Vec pos) => self.m[pos.x * self.size.y + pos.y];

fn usz! Mem.to_format(&self, Formatter *f) @dynamic
{
	usz! n;
	for (usz x = 0; x < self.size.x; x++)
	{
		for (usz y = 0; y < self.size.y; y++)
		{
			n += f.printf("%c", self.get({x, y}));
		}
		n += f.printf("\n");
	}
	return n;
}

fn Mem load_mem()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
		usz w = 7;
		usz h = 7;
		usz len = 12;
	$else
		String input = (String)file::load_temp("input")!!;
		usz w = 71;
		usz h = 71;
		usz len = 1024;
	$endif

	VecList list;
	list.temp_init();

	String[] coords;
	foreach (i, line : input.trim().tsplit("\n"))
	{
		coords = line.tsplit(",");
		list.push({coords[0].to_long()!!, coords[1].to_long()!!});
	}

	char[] mem = mem::temp_new_array(char, w * h);
	mem[..] = '.';
	while (len--)
	{
		Vec corrupt = list.pop_first()!!;	
		mem[corrupt.y * w + corrupt.x] = '#';
	}

	return { .m = mem, .size = Vec{w, h}, .bytes = list };
}

fn long part1() => solve(load_mem());

fn String part2()
{
	Mem m = load_mem();
	foreach (i, corrupt : m.bytes)
	{
		m.m[corrupt.y * m.size.x + corrupt.x] = '#';
		if (solve(m) == 0) return string::tformat("%s", corrupt);
	}
	return "";
}

struct State
{
	Vec p;
	usz n;
}

fn long solve(Mem m)
{
	VecList visited;
	visited.temp_init();

	List(<State>) queue;
	queue.temp_init();
	queue.push({{0,0},0});

	Vec[4] dirs = {{0,1},{0,-1},{1,0},{-1,0}};

	while (queue.len())
	{
		State s = queue.pop_first()!!;
		if (!m.inside(s.p)) continue;
		if (m.get(s.p) == '#') continue;
		if (s.p == m.size - 1) return s.n;
		if (visited.contains(s.p)) continue;
		visited.push(s.p);
		foreach (d: dirs) queue.push({s.p + d, s.n + 1});
	}
	return 0;
}
