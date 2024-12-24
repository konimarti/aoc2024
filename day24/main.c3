module aoc2024::app;

import std::io, std::time, std::collections::list, std::collections::map;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		// io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}


struct Gate
{
	String left;
	String right;
	String out;
	String op;
}
def Gates = HashMap(<String, Gate>);
def Wires = HashMap(<String, ushort>);

struct Device
{
	Wires w;
	Gates g;
}

fn Device load_device()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Device d;
	d.w.temp_init();
	d.g.temp_init();

	String[] parts = input.trim().tsplit("\n\n");

	// read wires
	foreach (line: parts[0].trim().tsplit("\n"))
	{
		d.w.set(line[:3], line[5..].to_ushort()!!);
	}

	// read gates
	foreach (line: parts[1].trim().tsplit("\n"))
	{
		String[] items = line.tsplit(" ");
		Gate g = {
			.left = items[0],
			.right = items[2],
			.out = items[4],
			.op = items[1],
		};
		d.g.set(items[4], g);
	}

	return d;
}

fn ushort and(ushort l, ushort r) => (ushort)(l && r);
fn ushort or(ushort l, ushort r) => (ushort)(l || r);
fn ushort xor(ushort l, ushort r) => (ushort)((l && !r) || (r && !l));

fn ulong part1() => solve(load_device());
// fn ulong part2() => solve2();

fn ulong solve(Device d)
{
	List(<String>) zlist;
	zlist.temp_init();
	d.g.@each(; String w, Gate v)
	{
		if (w[0] == 'z') zlist.push(w);
	};

	List(<String>) queue;
	queue.temp_init();

	foreach (z: zlist) queue.push(z);

	while LOOP: (try wire = queue.pop_first())
	{
		io::printfn("wire: %s", wire);
		// if we have a value for this wire already, continue.
		if (d.w.has_key(wire)) continue;
		// get gate for wire output, try to evaluate it, if
		// input is missing, put back into queue.
		if (try gate = d.g.get(wire))
		{
			bool missing = false;

			ushort! left = d.w.get(gate.left);
			if (catch left)
			{
				io::printfn("push (l): %s", gate.left);
				queue.push(gate.left);
				missing = true;
			}

			ushort! right = d.w.get(gate.right);
			if (catch right)
			{
				io::printfn("push (r): %s", gate.right);
				queue.push(gate.right);
				missing = true;
			}

			if (missing)
			{
				// put top wire back in queue.
				io::printfn("push (o): %s", wire);
				queue.push(wire);
				continue LOOP;
			}

			switch (gate.op)
			{
				case "AND": d.w.set(wire, and(left!!, right!!));
				case "XOR": d.w.set(wire, xor(left!!, right!!));
				case "OR": d.w.set(wire, or(left!!, right!!));
				default: unreachable("unknown operation");
			}
		}
	}

	ulong result;
	foreach (z: zlist)
	{
		ulong v = d.w.get(z)!!; 
		ushort pos = z[1..].to_ushort()!!;
		result |= v << pos;
	}

	return result;
}
