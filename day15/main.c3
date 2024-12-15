module aoc2024::app;

import std::io;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

const char BLOCK = '#';
const char BOX = 'O';
const char ROBOT = '@';
const char FREE = '.';

def Vec = int[<2>];

struct Warehouse
{
	List(<String>) map;
	Vec robot;
	String instructions;
}

fn void Warehouse.apply(&self, char d)
{
	Vec dir;
	switch (d)
	{
		case '<': dir = {0, -1};
		case '>': dir = {0, 1};
		case '^': dir = {-1, 0};
		case 'v': dir = {1, 0};
	}
	if (try pos = self.move(self.robot, dir))
	{
		while (pos != self.robot)
		{
			Vec prev = pos - dir;
			self.set(pos, self.map[prev.x][prev.y]);
			pos = prev;
		}
		self.robot += dir;
	}
}

fn void Warehouse.set(&self, Vec p, char c)
{
	String line = self.map[p.x];
	line[p.y] = c;
	self.map[p.x] = line;
}

fn Vec! Warehouse.move(&self, Vec p, Vec d)
{
	Vec next = p + d;
	switch (self.map[next.x][next.y])
	{
		case FREE: return next;
		case BOX: return self.move(next, d);
		default: return SearchResult.MISSING?;
	}
}

fn long Warehouse.score(&self)
{
	long score;
	foreach (x, line : self.map)
	{
		foreach (y, c : line)
		{
			if (c == BOX) score += 100 * x + y;
		}
	}
	return score;
}

fn usz! Warehouse.to_format(&self, Formatter *f) @dynamic
{
	usz! n;
	io::printfn("robot: %s", self.robot);
	foreach (x, line : self.map)
	{
		String copy = line.tcopy();
		if (x == self.robot.x) copy[self.robot.y] = ROBOT;
		n += f.printf("%s\n", copy);
	}
	// n += f.printf("\n%s\n", self.instructions);
	return n;
}

fn Warehouse load_warehouse()
{
	$if $feature(TEST):
		String s = (String)file::load_temp("input_test")!!;
	$else
		String s = (String)file::load_temp("input")!!;
	$endif
	String[] parts = s.trim().tsplit("\n\n");
	assert(parts.len == 2);
	List(<String>) map;
	map.temp_init();
	Vec r;
	foreach (x, line : parts[0].tsplit("\n"))
	{
		String copy = line.tcopy();
		if (try y = line.index_of_char(ROBOT))
		{
			r = {(int)x, (int)y};
			copy[y] = FREE;
		}
		map.push(copy);
	}

	DString instructions;
	instructions.temp_init();
	foreach (line : parts[1].tsplit("\n")) instructions.append(line.trim());

	return {.map = map, .robot = r, .instructions = instructions.str_view()};
}

fn long part1()
{
	Warehouse w = load_warehouse();
	// io::printn("initial statate");
	// io::printfn("%s", w);
	foreach (i, c : w.instructions)
	{
		w.apply(c);
		// io::printfn("\nstep after %c:", c);
		// io::printfn("%s", w);
	}
	return w.score();
}

