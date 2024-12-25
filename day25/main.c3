module aoc2024::app;

import std::io, std::time, std::collections;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		// io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

def Device = char[<5>];
def DeviceList = List(<Device>);

struct Schematics
{
	DeviceList keys;
	DeviceList locks;
}

fn usz! Schematics.to_format(&self, Formatter *f) @dynamic
{
	usz! n;
	n += f.printf("Keys:\n");
	foreach (key: self.keys)
	{
		n += f.printf("%s\n", key);
	}
	n += f.printf("Locks:\n");
	foreach (lock: self.locks)
	{
		n += f.printf("%s\n", lock);
	}
	return n;
}

<*
 @require s.len == 5
*>
fn Device parse_line(String s) @inline
{
	Device d;
	foreach (i, c: s) d[i] = (c == '#') ? 1 : 0;
	return d;
}

fn Schematics load_schematics()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Schematics s;
	s.keys.temp_init();
	s.locks.temp_init();

	foreach (block: input.trim().tsplit("\n\n"))
	{
		Device d;
		foreach (line: block.trim().tsplit("\n"))
		{
			d += parse_line(line);
		}

		if (block[0] == '#')
		{
			s.locks.push(d - 1);
		}
		else
		{
			s.keys.push(d - 1);
		}
	}

	return s;
}

fn ulong part1() => solve(load_schematics());
// fn ulong part2() => solve2(load_device());

fn ulong solve(Schematics s)
{
	long count;

	// io::printfn("%s", s);

	foreach (key: s.keys)
	{
		foreach (lock: s.locks)
		{
			if ((key + lock).comp_le({5,5,5,5,5}).and()) count++;
		}
	}
	return count;
}
