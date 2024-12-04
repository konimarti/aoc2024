module aoc2024::app;

import std::io;

fn void! main()
{
	@pool()
	{
		io::printfn("result part1: %d", part1());
		io::printfn("result part2: %d", part2());
	};
}

fn usz right(String s, usz p, usz n)
{
	if (p+3 >= s.len) return 0;
	if (s[p+1] != 'M') return 0;
	if (s[p+2] != 'A') return 0;
	if (s[p+3] != 'S') return 0;
	return 1;
}

fn usz left(String s, usz p, usz n)
{
	if (p - 3 < 0) return 0;
	if (s[p-1] != 'M') return 0;
	if (s[p-2] != 'A') return 0;
	if (s[p-3] != 'S') return 0;
	return 1;
}

fn usz up(String s, usz p, usz n)
{
	if (p - 3 * n < 0) return 0;
	if (s[p-n] != 'M') return 0;
	if (s[p-2*n] != 'A') return 0;
	if (s[p-3*n] != 'S') return 0;
	return 1;
}

fn usz down(String s, usz p, usz n)
{
	if (p+3*n >= s.len) return 0;
	if (s[p+n] != 'M') return 0;
	if (s[p+2*n] != 'A') return 0;
	if (s[p+3*n] != 'S') return 0;
	return 1;
}

fn usz upright(String s, usz p, usz n)
{
	if (p - 3 * n + 3 < 0) return 0;
	if (s[p-n+1] != 'M') return 0;
	if (s[p-2*n+2] != 'A') return 0;
	if (s[p-3*n+3] != 'S') return 0;
	return 1;
}

fn usz upleft(String s, usz p, usz n)
{
	if (p - 3 * n - 3 < 0) return 0;
	if (s[p-n-1] != 'M') return 0;
	if (s[p-2*n-2] != 'A') return 0;
	if (s[p-3*n-3] != 'S') return 0;
	return 1;
}


fn usz downright(String s, usz p, usz n)
{
	if (p + 3 * n + 3 >= s.len) return 0;
	if (s[p+n+1] != 'M') return 0;
	if (s[p+2*n+2] != 'A') return 0;
	if (s[p+3*n+3] != 'S') return 0;
	return 1;
}

fn usz downleft(String s, usz p, usz n)
{
	if (p + 3 * n - 3 >= s.len) return 0;
	if (s[p+n-1] != 'M') return 0;
	if (s[p+2*n-2] != 'A') return 0;
	if (s[p+3*n-3] != 'S') return 0;
	return 1;
}

fn usz part1()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	usz count = 0;

	// line length
	usz n = s.index_of_char('\n')!! + 1;

	foreach (i, c : s)
	{
		if (c != 'X') continue;
		count += right(s, i, n);
		count += left(s, i, n);
		count += up(s, i, n);
		count += down(s, i, n);
		count += upright(s, i, n);
		count += upleft(s, i, n);
		count += downright(s, i, n);
		count += downleft(s, i, n);
	}

	return count;
}

fn usz part2()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	usz count = 0;

	usz n = s.index_of_char('\n')!! + 1; // line length

	foreach (i, c : s)
	{
		if (c != 'A') continue;
		count += xcross(s, i, n);
	}

	return count;
}

fn usz xcross(String s, usz p, usz n)
{
	// top left
	if (p - n - 1 < 0) return 0;

	// bottom right
	if (p + n + 1 >= s.len) return 0;

	char [2] d;
	String diag;

	d = { s[p-n-1], s[p+n+1] };
	diag = (String)&d;
	if (diag != "MS" && diag != "SM") return 0;

	d = { s[p-n+1], s[p+n-1] };
	diag = (String)&d;
	if (diag != "MS" && diag != "SM") return 0;

	return 1;
}
