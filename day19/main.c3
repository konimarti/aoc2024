module aoc2024::app;

import std::io;
import std::time;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

def StringList = List(<String>);

struct Towels
{
	StringList towels;
	String[] designs;
}

fn Towels load_towels()
{
	$if $feature(TEST):
		File f = file::open("input_test", "r")!!;
	$else
		File f = file::open("input", "r")!!;
	$endif
	defer (void)f.close();

	Towels t;
	t.towels.temp_init();
	if (try available = io::treadline(&f)) t.towels.add_array(available.trim().tsplit(", "));
	(void)io::treadline(&f);

	StringList list;
	list.temp_init();
	while (try line = io::treadline(&f)) list.push(line);
	t.designs = list.to_tarray();

	return t;
}

def Cache = HashMap(<String, long>);

fn long part1() => solve();
fn long part2() => solve2();

fn long solve()
{
	long n;

	Cache c;
	c.temp_init();

	Towels t = load_towels();
	foreach (design : t.designs) n += search(t.towels, design, &c) ? 1 : 0;

	return n;
}

fn long solve2()
{
	long n;

	Cache c;
	c.temp_init();

	Towels t = load_towels();
	foreach (design : t.designs) n += search(t.towels, design, &c);

	return n;
}

fn long search(StringList towels, String s, Cache *c)
{
	if (try n = (*c)[s]) return n;	
	if (s.len == 0) return 1;

	long n;
	foreach (towel : towels)
	{
		if (s.len < towel.len) continue;
		if (s[:towel.len] == towel) n += search(towels, s[towel.len..], c);
	}
	(*c)[s] = n;
	return n;
}
