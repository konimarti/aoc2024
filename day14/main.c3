module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

def Vec = long[<2>];

struct Robot
{
	Vec p;
	Vec v;
}

fn Vec Robot.simulate(&r, long t, long xmax, long ymax)
{	
	Vec p = r.p + r.v * t;
	p.x %= xmax;
	p.y %= ymax;
	if (p.x < 0) p.x += xmax;
	if (p.y < 0) p.y += ymax;
	return p;
}

fn Robot parse(String line)
{
	String[] parts;
	parts = line.tsplit(" ");
	assert(parts.len == 2);

	String[] p = parts[0][2..].tsplit(",");
	String[] v = parts[1][2..].tsplit(",");

	return { .p = {p[0].to_long()!!, p[1].to_long()!!},
		.v = {v[0].to_long()!!, v[1].to_long()!!}};
}

fn long part1() => solve(100).product();
// fn long part2() => solve2();

fn long[<4>] solve(long seconds)
{
	$if $feature(TEST):
		String s = (String)file::load_temp("input_test")!!;
		long xmax = 11;
		long ymax = 7;
	$else
		String s = (String)file::load_temp("input")!!;
		long xmax = 101;
		long ymax = 103;
	$endif

	List(<Vec>) robots;
	robots.temp_init();

	String[] lines = s.trim().tsplit("\n");
	foreach (line : lines)
	{
		Robot r = parse(line);
		robots.push(r.simulate(seconds, xmax, ymax));
	}

	long[<4>] counts;
	foreach (r : robots)
	{
		if (r.x < xmax/2 && r.y < ymax/2) 
		{
			counts[0]++; // top left
		}
		else if (r.x < xmax/2 && r.y > ymax/2)
		{
			counts[1]++; // bottom left
		}
		else if (r.x > xmax/2 && r.y < ymax/2)
		{
			counts[2]++; // top right
		}
		else if (r.x > xmax/2 && r.y > ymax/2)
		{
			counts[3]++; // bottom right
		}
	}

	return counts;
}
