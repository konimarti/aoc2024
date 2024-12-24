module aoc2024::app;

import std::io, std::time, std::collections::list, std::collections::map;
import std::collections::tuple;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}


struct Gate
{
	String left;
	String right;
	String op;
}
def Gates = HashMap(<String, Gate>);
def Wires = HashMap(<String, ushort>);

struct Device
{
	Wires w;
	Gates g;
}

fn Device* Device.swap(&self, String a, String b)
{
	Gate! ga = self.g.get(a);
	if (catch ga) 
	{
		// io::printfn("not found in gates: %s", a);
		return self;
	}
	Gate! gb = self.g.get(b);
	if (catch gb) 
	{
		// io::printfn("not found in gates: %s", b);
		return self;
	}
	self.g.set(a, gb);
	self.g.set(b, ga);
	return self;
}

fn ulong Device.num(&self, char c)
{
	ulong result;
	self.w.@each(; String w, ushort v)
	{
		if (w[0] == c)
		{
			ushort pos = w[1..].to_ushort()!!;
			result |= (ulong)v << pos;
		}
	};
	return result;
}

fn void Device.set_num(&self, char c, ulong n)
{
	Wires temp;
	temp.temp_init();
	self.w.@each(; String w, ushort v)
	{
		if (w[0] == c)
		{
			ushort pos = w[1..].to_ushort()!!;
			temp.set(w, (n & ((ulong)1 << pos))>0 ? 1 : 0);
		}
	};
	temp.@each(; String w, ushort v)
	{
		self.w.set(w, v);
	};
}

fn Device load_device()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		$if $feature(TEST2):
			String input = (String)file::load_temp("input_test2")!!;
		$else
			String input = (String)file::load_temp("input")!!;
		$endif
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
fn ulong part2() => solve2(load_device());

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

	HashMap(<String, usz>) cb;
	cb.temp_init();

	while LOOP: (try wire = queue.pop_first())
	{
		// io::printfn("wire: %s", wire);
		if ((cb.get(wire) ?? 0) > 1_000) continue;
		cb.set(wire, 1 + cb.get(wire) ?? 0);

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
				// io::printfn("push (l): %s", gate.left);
				queue.push(gate.left);
				missing = true;
			}

			ushort! right = d.w.get(gate.right);
			if (catch right)
			{
				// io::printfn("push (r): %s", gate.right);
				queue.push(gate.right);
				missing = true;
			}

			if (missing)
			{
				// put top wire back in queue.
				// io::printfn("push (o): %s", wire);
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

	return d.num('z');
}

def Swap = Tuple(<String, String>);
def SwapList = List(<Swap>);
def StringList = List(<String>);

fn ulong solve2(Device d)
{
	ulong x = d.num('x');
	ulong y = d.num('y');
	ulong z = solve(d);
	io::printfn("x: %0d", x);
	io::printfn("y: %0d", y);
	io::printfn("z: %0d", z);
	io::printn("");
	io::printfn("x: %52b", x);
	io::printfn("y: %52b", y);
	io::printfn("w: %52b", x + y);
	io::printfn("z: %52b", z);

	StringList zlist;
	zlist.temp_init();
	d.g.@each(; String w, Gate v)
	{
		if (w[0] == 'z') zlist.push(w);
	};

	StringList considered;
	considered.temp_init();

	SwapList swaps;
	swaps.temp_init();

	String[] keys = d.g.tcopy_keys();

	for (usz i = 0; i < zlist.len(); i++)
	{
		x = (ulong)1 << i;
		y = (ulong)1 << i;
		z = calc(x, y, swaps, considered);

		if (x + y == z)
		{
			io::printfn("step %d: ok", i);
			continue;
		}

		// io::printfn("step %d: looking for swap", i);
		// io::printfn("x: %52b", x);
		// io::printfn("y: %52b", y);
		// io::printfn("z: %52b", z);
		// io::printfn("w: %52b", x + y);

		// collect swap "options"
		io::printn("generate options");
		StringList opts;
		opts.temp_init();
		ulong find = (x + y) ^ z;
		for (int j = 0; j < zlist.len(); j++)
		{
			if (find & (ulong)1 << j == 0) continue;
			StringList queue;
			queue.temp_init();
			queue.push(zlist[j]);
			while (try str = queue.pop())
			{
				if (opts.contains(str)) continue;
				opts.push(str);
				if (try g = d.g.get(str))
				{
					queue.push(g.left);
					queue.push(g.right);
				}
			}
		}

		io::printn("generate swaps");

		// go through all pairwise swaps
		for OUTER: (usz k = 0; k < opts.len(); k++)
		{
			for (usz l = k + 1; l < opts.len(); l++)
			{
			// io::printfn("checking %d, %d", k, l);
				// if (considered.contains(keys[k])) continue;
				// if (considered.contains(keys[l])) continue;
				swaps.push({opts[k], opts[l]});
				if (x + y == calc(x, y, swaps, considered))
				{
					io::printfn("swap: %s <-> %s", opts[k], opts[l]);
					considered.push(opts[k]);
					considered.push(opts[l]);
					// break OUTER;
				}
				swaps.pop()!!;
			}
		}
	}

	return 0;
}

fn ulong calc(ulong x, ulong y, SwapList swaps, StringList considered)
{
	Device t = load_device();
	foreach (swap: swaps)
	{
		t = *t.swap(swap.first, swap.second);
	}
	t.set_num('x', x);
	t.set_num('y', y);
	return solve(t);
}
