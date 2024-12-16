module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		io::printfn("result: part 2: %d", part2());
	};
}

const char BLOCK = '#';
const char BOX = 'O';
const char ROBOT = '@';
const char FREE = '.';

def Vec = long[<2>];

struct Warehouse
{
	List(<String>) map;
	Vec robot;
	char[] moves;
}

struct Field
{
	Vec p;
	char ch;
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
	List(<Field>) fields;
	if (self.move(self.robot, dir, fields.temp_init()))
	{
		foreach (field : fields) self.set(field.p, FREE);
		foreach (field : fields) self.set(field.p + dir, field.ch);
		self.robot += dir;
	}
}

fn void Warehouse.set(&self, Vec p, char c)
{
	String ln = self.map[p.x];
	ln[p.y] = c;
	self.map[p.x] = ln;
}

fn bool Warehouse.move(&self, Vec p, Vec d, List(<Field>)* fields)
{
	fields.push({p, self.map[p.x][p.y]});
	Vec next = p + d;
	switch (self.map[next.x][next.y])
	{
		case FREE: return true;
		case BOX: return self.move(next, d, fields);
		case '[': 
			if (math::abs(d.x) == 0) return self.move(next, d, fields);
			return self.move(next, d, fields) && self.move(next + {0, 1}, d, fields);
		
		case ']':
			if (math::abs(d.x) == 0) return self.move(next, d, fields);
			return self.move(next, d, fields) && self.move(next + {0, -1}, d, fields);
		default: return false;
	}
}

fn long Warehouse.score(&self)
{
	long score;
	foreach (x, line : self.map)
	{
		foreach (y, c : line)
		{
			if (c == BOX || c == '[') score += 100 * x + y;
		}
	}
	return score;
}

fn Warehouse load_warehouse(bool part2 = false )
{
	$if $feature(TEST):
		String in = (String)file::load_temp("input_test")!!;
	$else
		String in = (String)file::load_temp("input")!!;
	$endif

	String[] parts = in.trim().tsplit("\n\n");

	List(<String>) map;
	map.temp_init();

	Vec r;
	foreach (x, line : parts[0].tsplit("\n"))
	{
		DString copy;
		copy.temp_init();
		if (part2)
		{
			foreach (c : line)
			{
				switch (c)
				{
					case BLOCK: copy.append(BLOCK); copy.append(BLOCK);
					case BOX: copy.append('['); copy.append(']');
					case FREE: copy.append(FREE); copy.append(FREE);
					case ROBOT: copy.append(ROBOT); copy.append(FREE);
				}
			}
		}
		else
		{
			copy.append(line);
		}
		String s = copy.str_view();
		if (try y = s.index_of_char(ROBOT))
		{
			r = {x, y};
			s[y] = FREE;
		}
		map.push(s);
	}

	DString moves;
	moves.temp_init();
	foreach (line : parts[1].tsplit("\n")) moves.append(line.trim());

	return {.map = map, .robot = r, .moves = moves.str_view()};
}

fn long part1() => solve(false);
fn long part2() => solve(true);

fn long solve(bool part2)
{
	Warehouse w = load_warehouse(part2);
	foreach (c : w.moves) w.apply(c);
	return w.score();
}
