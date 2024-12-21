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
	String seq;
	long factor;
}
def Codes = List(<Code>);

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
// start on A
fn Codes load_codes()
{
	Codes codes;
	codes.temp_init();

	$if $feature(TEST):
		// String input = (String)file::load_temp("input_test")!!;
		// 029A
		codes.push({"<A^A^^>AvvvA", 29});
		codes.push({"<A^A^>^AvvvA", 29});
		codes.push({"<A^A>^^AvvvA", 29});
		// 980A = ^^^,<,vvv,>
		// codes.push({"^^^,<,vvv,>", 980});
		// 179A = ^<<,^^,>>,vvv
		// codes.push({"^<<,^^,>>,vvv", 179});
		// 456A = ^^<<,>,>,vv
		// codes.push({"^^<<,>,>,vv", 456});
		// 379A = ^,^^<<,>>,vvv
		// codes.push({"^,^^<<,>>,vvv", 379});
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	return codes;
}

struct DirPad
{
	char c;
}
//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
fn String DirPad.move_to(&start, char end)
{
	char temp = start.c;
	*start = {end};
	switch (temp)
	{
		case 'A':
			switch (end)
			{
				case 'A': return "";
				case '^': return "<";
				case 'v': return "v<";
				case '<': return "v<<";
				case '>': return "v";
				default: unreachable();
			}
		case '^':
			switch (end)
			{
				case 'A': return ">";
				case '^': return "";
				case 'v': return "v";
				case '<': return "v<";
				case '>': return ">v";
				default: unreachable();
			}
		case 'v':
			switch (end)
			{
				case 'A': return ">^";
				case '^': return "^";
				case 'v': return "";
				case '<': return "<";
				case '>': return ">";
				default: unreachable();
			}
		case '<':
			switch (end)
			{
				case 'A': return ">>^";
				case '^': return ">^";
				case 'v': return ">";
				case '<': return "";
				case '>': return ">>";
				default: unreachable();
			}
		case '>':
			switch (end)
			{
				case 'A': return "^";
				case '^': return "^<";
				case 'v': return "<";
				case '<': return "<<";
				case '>': return "";
				default: unreachable();
			}
		default:
			unreachable();
	}
}

fn long part1() => solve(1);
// fn long part2() => solve();

fn long solve(usz npad)
{
	Codes codes = load_codes();
	foreach (code: codes)
	{
		io::printfn("\ncode  : %s", code.seq);

		DString result;
		result.temp_init();

		foreach (i, c : code.seq)
		{
			result.append(move(code.seq[i:1], npad));
		}

		io::printfn("result: %s", result.str_view());
		switch (npad)
		{
			case 0: io::printfn("want 0: v<<A>>^A<A>AvA<^AA>A<vAAA>^A");
			case 1: io::printfn("want 1: <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A");
			case 2: io::printfn("want 2: <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>Av<<A>>^A<A>AvA<^AA>A<vAAA>^A<A^A>^^AvvvA");
		}

	}
	return 0;
}

DirPad[*] pads = {{'A'}, {'A'}, {'A'}, {'A'}};

fn String move(String input, usz npad)
{
	DString s;
	s.temp_init();

	foreach (c : input)
	{
		s.append(pads[npad].move_to(c));
		s.append('A');
	}

	String r = s.str_view().tcopy();

	if (npad == 0)
	{
		return r;
	}
	return move(r, npad - 1);
}
