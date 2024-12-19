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

fn long part1() => solve();
// fn long part2() => reverse();

fn long solve()
{
	Towels t = load_towels();

	long n;
	foreach (design : t.designs) n += possible(t.towels, design) ? 1 : 0;
	return n;
}

struct State
{
	String rem;
}

fn bool possible(StringList towels, String design)
{
	List(<State>) stack;
	stack.temp_init();
	stack.push({design});

	while (try s = stack.pop())
	{
		if (s.rem.len == 0) return true;
		foreach (t : towels)
		{
			if (s.rem.starts_with(t)) stack.push({s.rem[t.len..]});
		}
	}
	return false;
}
