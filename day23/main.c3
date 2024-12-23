module aoc2024::app;

import std::io, std::time, std::collections::map, std::collections::list, std::sort;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %s %s", part2(), c.mark());
	};
}

fn ElementMap load()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	ElementMap map;
	map.temp_init();
	foreach (pair: input.trim().tsplit("\n"))
	{
		map.add(pair[0:2], pair[3:2]).add(pair[3:2], pair[0:2]);
	}
	return map;
}

union Element
{
	char[2] c;
	ushort h;
}
fn uint Element.hash(&self) => self.h;
fn bool Element.equals(&self, Element other) => self.h == other.h;
fn usz! Element.to_format(&self, Formatter *f) @dynamic => f.printf("%s", (String)self.c[..]);
fn int Element.compare_to(&self, Element other) => ((ushort)self.c[0] << 8 + self.c[1]) - ((ushort)other.c[0] << 8 + other.c[1]);

def ElementList = List(<Element>);
def ElementMap = HashMap(<Element, ElementList>);

fn ElementMap* ElementMap.add(&self, char[2] a, char[2] b)
{
	Element key = { .c = a };
	ElementList list = self.get(key) ?? *ElementList{}.temp_init();
	list.push({ .c = b });
	self.set(key, list);
	return self;
}

fn long part1() => find_three(load());
fn String part2() => find_max_clique(load());

fn long find_three(ElementMap m)
{
	Element[] keys = m.tcopy_keys();

	List(<ulong>) visited;
	visited.temp_init();

	long count;
	foreach (a: keys)
	{
		ElementList! alist = m.get(a);
		if (catch alist) continue;

		foreach (b: alist)
		{
			ElementList! blist = m.get(b);
			if (catch blist) continue;

			foreach (c: blist)
			{
				ElementList! clist = m.get(c);
				if (catch clist) continue;

				if (!clist.contains(a)) continue;
				if (a.c[0] != 't' && b.c[0] != 't' && c.c[0] != 't') continue;

				Element[3] seq = {a, b, c};
				sort::quicksort(seq[..]);
				ulong key = (ulong)seq[0].h << 32 + (ulong)seq[1].h << 16 + (ulong)seq[2].h;

				if (visited.contains(key)) continue;
				visited.push(key);

				count++;
			}
		}
	}

	return count;
}

fn String find_max_clique(ElementMap m)
{
	ElementList max;
	max.temp_init();

	Element[] keys = m.tcopy_keys();
	foreach (key: keys)
	{
		ElementList clique = max_clique(key, keys, m);
		if (max.len() < clique.len()) max = clique;
	}

	sort::quicksort(max);

	DString result;
	result.temp_init();

	foreach (i, a: max)
	{
		if (i > 0) result.append(",");
		result.appendf("%s", a);
	}

	return result.str_view();
}

fn ElementList max_clique(Element root, Element[] keys, ElementMap m)
{
	ElementList clique;
	clique.temp_init();
	clique.push(root);

	foreach LOOP: (v: keys)
	{
		if (clique.contains(v)) continue;
		if (try list = m.get(v))
		{
			// clique must be a subset of list
			foreach (c : clique)
			{
				if (!list.contains(c)) continue LOOP;
			}
			clique.push(v);
		}
	}
	return clique;
}
