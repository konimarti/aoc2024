module aoc2024::app;

import std::io;

fn void! main()
{
	@pool()
	{
		// for part 1 solution, uncomment the || operator in
		// operators.
		io::printfn("result: %d", solve());
	};
}

def Ops = fn long(long,long);
fn long add(long a, long b) => a + b;
fn long mul(long a, long b) => a * b;
fn long con(long a, long b)
{
	String as = string::tformat("%d", a);
  	String bs = string::tformat("%d", b);
	return as.tconcat(bs).to_long()!!;
}

Ops[] operators = {
	&add,
	&mul,
	&con,
};

fn long solve()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	long[64] operands;
	long sum;
	foreach (line : s.tsplit("\n"))
	{
		if (!line.len) continue;
		String[] parts = line.tsplit(":");
		assert(parts.len == 2, "line: %s", line);
		long result = parts[0].to_long()!!;
		usz i;
		foreach (op : parts[1].tsplit(" "))
		{
			if (!op.len) continue;
			operands[i++] = op.trim().to_long()!!;
		}
		// io::printfn("result: %d, operands: %s", result, operands[:i]);
		if (valid_calibration(result, operands[:i])) sum += result;
	}
	return sum;
}

fn bool valid_calibration(long result, long[] operands)
{
	return dfs(result, operands, 1, operands[0]);
}

fn bool dfs(long result, long[] operands, usz pos, long cur)
{
	if (pos >= operands.len) return result == cur;
	bool r;
	foreach (ops : operators)
	{
		r = dfs(result, operands, pos+1, ops(cur, operands[pos]));
		if (r) return true;
	}
	return false;
}
