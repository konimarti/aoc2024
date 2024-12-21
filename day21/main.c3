module aoc2024::app;

import std::io;
import std::time;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		// io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

struct Code
{
	String str;
	long number;
}

def Codes = List(<Code>);
def Vec = int[<2>];
def VecList = List(<Vec>);

fn long num(String s) => s[:3].to_long()!!;

fn Codes load_codes()
{
	Codes codes;
	codes.temp_init();

	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	foreach (line: input.trim().tsplit("\n"))
	{
		line = line.trim();
		codes.push({line, num(line)});
	}

	return codes;
}

const Vec INVALID = {9, 9};

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
Vec[*] numpad = {
	[0..255] = INVALID,
	['0'] = {3, 1},
	['1'] = {2, 0},
	['2'] = {2, 1},
	['3'] = {2, 2},
	['4'] = {1, 0},
	['5'] = {1, 1},
	['6'] = {1, 2},
	['7'] = {0, 0},
	['8'] = {0, 1},
	['9'] = {0, 2},
	['A'] = {3, 2},
};

//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
Vec[*] dirpad = {
	[0..255] = INVALID,
	['^'] = {0, 1},
	['A'] = {0, 2},
	['<'] = {1, 0},
	['v'] = {1, 1},
	['>'] = {1, 2},
};


fn long part1() => solve(3);

fn long solve(usz level)
{
	long score;
	foreach (code: load_codes())
	{
		long n;
		char start = 'A';
		foreach (end: code.str)
		{
			n += min_ways(start, end, level, true);
			// io::printfn(" > start=%c end=%c curlen=%d", start, end, n);
			start = end;
		}
		io::printfn("code str: %s, %d: result: %d", code.str, code.number, n);
		score += code.number * n;
	}
	return score;
}

// level 3: numpad (robot 1)
// level 2: dirpad (robot 2)
// level 1: dirpad (robot 3)
// level 0: dirpad (me)
//
// char s,e can either be chars on numpad or dirpad
fn long min_ways(char s, char e, usz level, bool use_numpad)
{
	if (level == 0) return 1;

	List(<String>) ways = {|
		if (use_numpad) return ways_on_pad(numpad[s], numpad[e], numpad[..]);
		return ways_on_pad(dirpad[s], dirpad[e], dirpad[..]);
	|};

	// if (level == 1) io::printfn("\n%c -> %c (%s)", s, e, use_numpad?"numpad":"dirpad");

	long min = long.max;
	foreach (way: ways)
	{
		long n;
		char start = 'A';
		foreach (end: way)
		{
			n += min_ways(start, end, level - 1, false);
			start = end;
		}
		if (n < min) min = n;
		// if (level == 1) io::printfn(" way: %s [min=%d]", way, n);
	}
		// if (level == 1) io::printfn(" selected: %d", min);

		if (use_numpad) io::printfn("min: %d", min);


	return min;
}

struct State
{
	Vec pos;
	Vec dir;
	DString walk;
}

Vec[*] dirs = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
char[*] sign = {'^','v','<','>'};

// bfs on pad from start to end char
fn List(<String>) ways_on_pad(Vec start, Vec end, Vec[] pad_vec)
{
	List(<State>) queue;
	queue.temp_init();
	queue.push({start, {0,0}, dstring::temp_new()});

	List(<int[<4>]>) visited;
	visited.temp_init();

	VecList pad;
	pad.temp_init();
	foreach (pos: pad_vec) if (pos != INVALID) pad.push(pos);

	List(<String>) ways;
	ways.temp_init();

	while (try state = queue.pop_first())
	{
		if (!pad.contains(state.pos)) continue;
		if (state.pos == end) {
			state.walk.append('A');
			String walk = state.walk.tcopy_str();
			ways.push(walk);
			continue;
		}

		if (visited.contains({...state.pos, ...state.dir})) continue;
		visited.push({...state.pos, ...state.dir});

		foreach (i, d: dirs)
		{
			DString next = dstring::temp_new(state.walk.tcopy_str());
			next.append(sign[i]);
			queue.push({state.pos + d, d, next});
		}
	}

	return ways;
}
