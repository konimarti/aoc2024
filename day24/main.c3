module aoc2024::app;

import std::io, std::time, std::collections;
import std::sort;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %s %s", part2(), c.mark());
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

/*
 * To solve part 2, we check every end node if it is a valid two-bit adder.
 *
 * See:
 *   - https://web2.qatar.cmu.edu/cs/15348/labs/02/lab02.pdf
 *   - https://en.wikipedia.org/wiki/Adder_(electronics)
 *
 * The logic to determine wrong nodes is the following:
 * - if 1st level is not an XOR, then this is a wrong gate
 * - if 2nd level is not an OR, then this is a wrong gate (note: need to check
 * 	if these are terminal nodex, starting with either x or y);
 * - if 3rd level is not an AND, then this is a wrong gate
 *
 */
fn void Device.validate(&self, String s, StringList *list, int depth)
{
	if (depth == 0) return;

	Gate! g = self.g.get(s);
	if (catch g) return;

	switch (depth)
	{
		case 3:
			if (g.op != "XOR")
			{
				// io::printfn("node: %s, depth: %d, have op=%s but want XOR", s, depth, (String)g.op[..]);
				list.push(s);
				return;
			}
		case 2:
			String prefix = { g.left[0], g.right[0] };
			if (prefix == "xy" || prefix == "yx")
			{
				if (g.op != "XOR")
				{
					// io::printfn("node: %s, depth: %d, have op=%s but want XOR", s, depth, (String)g.op[..]);
					// io::printfn("left: %s, right: %s", g.left, g.right);
					list.push(s);
					return;
				}
			}
			else
			{
				if (g.op != "OR")
				{
					// io::printfn("node: %s, depth: %d, have op=%s but want OR", s, depth, (String)g.op[..]);
					// io::printfn("left: %s, right: %s", g.left, g.right);
					list.push(s);
					return;
				}
			}
		case 1:
			if (g.op != "AND")
			{
				// io::printfn("node: %s, depth: %d, have op=%s but want AND", s, depth, (String)g.op[..]);
				list.push(s);
				return;
			}
	}

	self.validate(g.left, list, depth - 1);
	self.validate(g.right, list, depth - 1);
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
fn String part2() => solve2(load_device());

fn ulong solve(Device d)
{
	List(<String>) queue;
	queue.temp_init();

	HashMap(<String, int>) cb; // "circuit breaker"
	cb.temp_init();

	d.g.@each(; String name, Gate g)
	{
		if (name[0] == 'z') queue.push(name);
	};

	while LOOP: (try wire = queue.pop_first())
	{
		cb.set(wire, 1 + (cb.get(wire) ?? 0));
		if (cb.get(wire)!! > 100) continue;

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

def StringList = List(<String>);

fn int String.compare_to(&self, String other)
{
	usz i, n;
        n = $$min(self.len, other.len);
        while (i < n && (*self)[i] == other[i]) i++;
        if (i == n) return self.len - other.len;
        return (*self)[i] - other[i];
}

fn String solve2(Device d)
{
	ulong z = solve(d);

	StringList wrong;
	wrong.temp_init();

	for (usz i = 2; i < 44; i++)
	{
		String s = string::tformat("z%02d", i);
		d.validate(s, &wrong, 3);
	}

	sort::quicksort(wrong);

	DString out;
	out.temp_init();
	foreach (i, w: wrong)
	{
		if (i > 0) out.append(",");
		out.append(w);
	}

	return out.str_view();
}
