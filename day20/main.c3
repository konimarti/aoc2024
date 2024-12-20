module aoc2024::app;

import std::io;
import std::time;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

def Vec = usz[<2>];
def VecList = List(<Vec>);
def Map = List(<String>);

struct Race
{
	Map m;
	ushort[142][142] len;
	Vec start;
	Vec end;
	Vec size;
}
fn bool Race.valid(&self, Vec p) => p.comp_ge({0, 0}).and() && p.comp_lt(self.size).and();

fn Race load_race()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Race r;
	foreach (x, line: input.trim().tsplit("\n")) 
	{
		if (try y = line.index_of_char('S')) r.start = {x, y};
		if (try y = line.index_of_char('E')) r.end = {x, y};
		r.m.push(line);
	}
	r.size = {r.m.len(), r.m[0].len};
	return r;
}

fn long part1() => solve(2, 100);
fn long part2() => solve(20, 100);

fn long solve(usz cheat_steps, usz cheats_larger_than)
{
	Race r = load_race();
	VecList steps = find_steps(&r);
	usz count;
	for (usz i = 0; i < steps.len(); i++)
	{
		Vec pos = steps[i];
		for (usz j = i + 1; j < steps.len(); j++)
		{
			Vec n = steps[j];
			usz nsteps = math::abs(n - pos).sum();
			if (nsteps > cheat_steps) continue;
			int cheat = r.len[n.x][n.y] - r.len[pos.x][pos.y] - (ushort)nsteps;
			if (cheat >= cheats_larger_than) count++;
		}
	}
	return count;
}

struct State
{
	Vec pos;
	usz len;
}

Vec[4] dirs = {{0,1}, {0,-1}, {1,0}, {-1,0}};

fn VecList find_steps(Race *r)
{
	List(<State>) queue;
	queue.temp_init();
	queue.push({r.start, 0});

	VecList visited;
	visited.temp_init();

	while (try s = queue.pop_first())
	{
		if (!r.valid(s.pos)) continue;
		if (s.pos == r.end) {
			r.len[s.pos.x][s.pos.y] = (ushort)s.len;
			visited.push(s.pos);
			break;
		}
		if (r.m[s.pos.x][s.pos.y] == '#') continue;
		if (visited.contains(s.pos)) continue;
		visited.push(s.pos);
		r.len[s.pos.x][s.pos.y] = (ushort)s.len;
		foreach (d : dirs) queue.push({s.pos + d, s.len + 1});
	}
	return visited;
}
