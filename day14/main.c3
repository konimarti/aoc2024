module aoc2024::app;

import std::io;
import std::math;
import std::collections::priorityqueue;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		io::printfn("result: part 2: %d", part2());
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

fn long part1() @inline => solve(100);
fn long solve(long seconds)
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

	long[<4>] counts;
	foreach (line : s.trim().tsplit("\n"))
	{
		Vec r = parse(line).simulate(seconds, xmax, ymax);
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
	return counts.product();
}

struct Entry
{
	long index;
	double locality;
}

fn int Entry.compare_to(&self, Entry other) => compare_to(self.locality, other.locality); 

fn long part2()
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

	String[] lines = s.trim().tsplit("\n");
	Vec mid = {xmax/2,ymax/2};

	PriorityQueue(<Entry>) heap;
	heap.temp_init();
	for (long i = 1; i < 10000; i++)
	{
		double locality;
		foreach (line : lines)
		{
			Vec r = parse(line).simulate(i, xmax, ymax);
			r -= mid;
			locality += r.dot(r);
		}
		heap.push({i, locality});

	}
	return heap.pop()!!.index;
}
