module aoc2024::app;

import std::io;
import std::collections::tuple;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result part1: %d", part1());
		// io::printfn("result part2: %d", part2());
	};
}

fn long part1()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	String[] parts = s.tsplit("\n\n");
	assert(parts.len == 2);

	List(<Tuple(<int, int>)>) rules;
	rules.temp_init(256);

	// read rules
	foreach (rule : parts[0].tsplit("\n"))
	{
		String[] pages = rule.tsplit("|");
		assert(pages.len == 2);
		// io::printn(pages);

		// x must be before y: before[x] = y
		rules.push({pages[0].to_int()!!, pages[1].to_int()!!});
	}


	int[256] pages;
	int sum;
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
		sum += middle_page(pages[:i], rules);
	}

	return sum;
}

// pages in update
fn int middle_page(int[] pages, List(<Tuple(<int,int>)>) rules)
{
	if (pages.len <= 1) return 0;

	// check if valid
	for (int i = 0; i < (pages.len-1); i++)
	{
		for JLOOP: (int j = i + 1; j < (pages.len); j++)
		{
			foreach (rule : rules)
			{
				if (rule.first == pages[i] && rule.second == pages[j]) continue JLOOP;
				if (rule.first == pages[j] && rule.second == pages[i]) return 0;

			}
			// no rule found?
		}
	}

	// if we still here, meaning update is valid
	// return middle page
	return pages[pages.len/2];
}


