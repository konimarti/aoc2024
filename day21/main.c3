module aoc2024::app;

import std::io;
import std::time;
import std::math;
import std::collections::list;
import std::collections::map;

fn void! main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
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
		codes.push({line, line[:3].to_long()!!});
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
fn long part2() => solve(26);

fn long solve(usz level)
{
	Cache cache;
	cache.temp_init();

	long score;
	foreach (code: load_codes())
	{
		long n;
		char start = 'A';
		foreach (end: code.str)
		{
			n += min_ways(start, end, level, true, &cache);
			start = end;
		}
		$if $feature(DEBUG):
			io::printfn("code: %s, score: %d * %d", code.str, code.number, n);
		$endif
		score += code.number * n;
	}
	return score;
}

union Hash
{
	char[3] c;
	uint h;
}
fn uint Hash.hash(&self) => self.h;
fn bool Hash.equals(&self, Hash other) => self.h == other.h;

def Cache = HashMap(<Hash, long>);

// level 3: numpad (robot 1)
// level 2: dirpad (robot 2)
// level 1: dirpad (robot 3)
// level 0: dirpad (me)
//
// char s,e can either be chars on numpad or dirpad
fn long min_ways(char s, char e, usz level, bool use_numpad, Cache *cache)
{
	if (level == 0) return 1;

	long min = long.max;

	// memoization
	Hash key = {.c = {s, e, (char)level}};
	if (try m = cache.get(key)) return m;
	defer cache.set(key, min);

	List(<String>) ways =
	{|
		if (use_numpad) return ways_on_pad(numpad[s], numpad[e], numpad[..]);
		return ways_on_pad(dirpad[s], dirpad[e], dirpad[..]);
	|};

	$if $feature(DEBUG):
		if (level == 1) io::printfn("\n%c -> %c (%s)", s, e, use_numpad?"numpad":"dirpad");
	$endif

	foreach (way: ways)
	{
		ulong n;
		char start = 'A';
		foreach (end: way)
		{
			n += min_ways(start, end, level - 1, false, cache);
			start = end;
		}
		if (n < min) min = n;

		$if $feature(DEBUG):
			if (level == 1) io::printfn(" way: %s [min=%d]", way, n);
		$endif
	}

	$if $feature(DEBUG):
		if (level == 1) io::printfn(" selected: %d", min);
		if (use_numpad) io::printfn("min: %d", min);
	$endif


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

// bfs on the given pad from start to end char. The visited list should
// consider the direction, so that we explore the entire solution space. BFS
// would criss-cross towards the goal, but here the straight lines are
// preferred.
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

		int[<4>] visit = {...state.pos, ...state.dir};
		if (visited.contains(visit)) continue;
		visited.push(visit);

		foreach (i, d: dirs)
		{
			DString next = dstring::temp_new(state.walk.tcopy_str());
			next.append(sign[i]);
			queue.push({state.pos + d, d, next});
		}
	}

	return ways;
}
