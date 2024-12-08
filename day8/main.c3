module aoc2024::app;

import std::io;
import std::math; // complex
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		io::printfn("result: %d", solve());
	};
}

def Pos = Complex(<long>);
def ListPos = List(<Pos>);
def Map = HashMap(<char,ListPos>);

fn long solve()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	Map m;
	m.temp_init();

	String[] lines = s.tsplit("\n");
	usz xmax = lines.len - 1;
	usz ymax = lines[0].len;

	foreach (x, line : lines)
	{
		if (!line.len) continue;
		foreach (y, c : line)
		{
			if (c == '.') continue;
			ListPos list;
			if (!m.has_key(c))
			{
				list = ListPos{};
				list.temp_init();
			}
			else
			{
				list = m[c]!!;
			}
			list.push({x,y});
			m[c] = list;
		}
	}

	io::printfn("xmax: %d ", xmax);
	io::printfn("ymax: %d ", ymax);

	ListPos considered;
	considered.temp_init();
	usz count = 0;
	foreach (k : m.tcopy_keys())
	{
		count += count_antinodes(m[k]!!, xmax, ymax, &considered);
	}
	return count;
}

def Checkfn = fn bool(Pos, usz, usz, ListPos*);

fn long count_antinodes(ListPos list, usz xmax, usz ymax, ListPos* c)
{
	Checkfn check_node = fn bool(Pos node, usz xmax, usz ymax, ListPos *c)
	{
		if (!in_map(node, xmax, ymax)) return false;
		if (c.contains(node)) return false;
		c.push(node);
		// io::printfn("node: (%d,%d)", node.r, node.c);
		return true;
	};

	usz ctr;
	usz n = list.len();
	for (usz i = 0; i < (n-1); i++)
	{
		for (usz j = i+1; j < n; j++)
		{
			Pos x = list[i];
			Pos y = list[j];
			Pos dir = x.sub(y);
			for (Pos node = x; in_map(node, xmax, ymax); node = node.add(dir))
			{
				if (check_node(node, xmax, ymax, c)) ctr++;
			}
			for (Pos node = x.sub(dir); in_map(node, xmax, ymax); node = node.sub(dir))
			{
				if (check_node(node, xmax, ymax, c)) ctr++;
			}
		}
	}
	return ctr;
}

fn bool in_map(Pos p, usz xmax, usz ymax)
{
	if (p.r < 0 || p.c < 0) return false;
	if (p.r >= xmax || p.c >= ymax) return false;
	return true;
}
