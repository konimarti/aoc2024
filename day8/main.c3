module aoc2024::app;

import std::io;
import std::math; // complex
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part1 %d", part1());
	};
}

def Pos = Complex(<long>);
def ListPos = List(<Pos>);
def Map = HashMap(<char,ListPos>);

fn long part1()
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

	/*
	foreach (k : m.tcopy_keys())
	{
		io::printf("key: %c ", k);
		foreach (p : m[k]!!)
		{
			io::printf("(%d,%d),", p.r, p.c);
		}
		io::printn("");
	}
	*/
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

fn long count_antinodes(ListPos list, usz xmax, usz ymax, ListPos* considered)
{
	usz ctr;
	usz n = list.len();
	for (usz i = 0; i < (n-1); i++)
	{
		for (usz j = i+1; j < n; j++)
		{
			Pos x = list[i];
			Pos y = list[j];
			Pos dir = x.sub(y);
			Pos node = x.add(dir);
			if (in_map(node, xmax, ymax))
			{
				if (!considered.contains(node))
				{
					ctr++;
					considered.push(node);
					io::printfn("node: (%d,%d)", node.r, node.c);
				}
			}
			node = y.sub(dir);
			if (in_map(node, xmax, ymax))
			{
				if (!considered.contains(node))
				{
					ctr++;
					considered.push(node);
					io::printfn("node: (%d,%d)", node.r, node.c);
				}
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
