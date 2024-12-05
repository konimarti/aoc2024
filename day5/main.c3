module aoc2024::app;

import std::io;
import std::collections::tuple;
import std::collections::list;
import std::sort;

fn void! main()
{
	@pool()
	{
		part1and2();
	};
}

fault Error { INVALID }

def ListRule = List(<Tuple(<int,int>)>);

fn void part1and2()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	String[] parts = s.tsplit("\n\n");
	assert(parts.len == 2);

	ListRule rules;
	rules.temp_init(256);

	// read rules
	foreach (rule : parts[0].tsplit("\n"))
	{
		String[] pages = rule.tsplit("|");
		assert(pages.len == 2);

		// x must be before y: before[x] = y
		rules.push({pages[0].to_int()!!, pages[1].to_int()!!});
	}

	int[256] pages;
	int sum, sum2;

	// read updates
	foreach (update : parts[1].tsplit("\n"))
	{
		int i = 0;
		foreach (page : update.tsplit(","))
		{
			assert(i <= 256);
			if (!page.len) continue;
			pages[i] = page.to_int()!!;
			i++;
		}
		int! mid = middle_page(pages[:i], rules);
		if (@ok(mid))
		{	sum += mid!!;
		}
		else
		{
			sum2 += fix(pages[:i], rules);
		}
	}

	io::printfn("part1: %d", sum);
	io::printfn("part2: %d", sum2);
}

// update line in pages
fn int! middle_page(int[] pages, ListRule rules)
{
	if (pages.len <= 1) return 0;

	// check if valid; return if invalid
	for (int i = 0; i < (pages.len-1); i++)
	{
		for JLOOP: (int j = i + 1; j < (pages.len); j++)
		{
			foreach (rule : rules)
			{
				if (rule.first == pages[i] && rule.second == pages[j]) continue JLOOP;
				if (rule.first == pages[j] && rule.second == pages[i]) return Error.INVALID?;

			}
			unreachable();
		}
	}

	// if we still here, meaning update is valid
	// return middle page
	return pages[pages.len/2];
}

fn int fix(int[] pages, ListRule rules)
{
	if (pages.len <= 1) return 0;
	return sort::quickselect(pages, pages.len/2, fn int(int a, int b, ListRule rules){
			if (a == b) return 0;
			foreach (rule : rules)
			{
				if (rule.first == a && rule.second == b) return -1;
				if (rule.first == b && rule.second == a) return 1;
			}
			unreachable();
	}, rules)!!;
}


