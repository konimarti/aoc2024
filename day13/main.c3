module aoc2024::app;

import std::io;
import std::math;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", solve());
		io::printfn("result: part 2: %d", solve(10000000000000));
	};
}

struct Machine
{
	Matrix2 m;
	Vec2 price;
}

fn bool Machine.on_price(&m, long a, long b) @inline
{
	return (m.m.apply(Vec2{a,b}) - m.price).length() < 1e-7;
}

fn long Machine.play(&m)
{
	double det = m.m.determinant();
	if (math::abs(det) < 1e-12) return 0;

	Matrix2 inv = {.m00=m.m.m11, .m01=-m.m.m01, .m10=-m.m.m10, .m11=m.m.m00};
	inv = inv.component_mul(1.0/det);

	Vec2 v = inv.apply(m.price);

	long a = (long)math::round(v.x);
	long b = (long)math::round(v.y);
	if (m.on_price(a,b)) return 3 * a + b;
	return 0;
}

fn Vec2 parseline(String line, usz skip = 1)
{
	String[] parts;

	parts = line.tsplit(": ");
	assert(parts.len == 2);

	parts = parts[1].tsplit(", ");
	assert(parts.len == 2);

	return { parts[0].trim()[skip..].to_double()!!, parts[1].trim()[skip..].to_double()!!};
}

fn long solve(long penalty = 0)
{
	$if $feature(TEST):
	String s = (String)file::load_temp("input_test")!!;
	$else
	String s = (String)file::load_temp("input")!!;
	$endif

	long tokens;
	Vec2 v;
	String[] lines = s.trim().tsplit("\n");
	for (usz i = 0; i < lines.len; i += 4)
	{
		Matrix2 m;
		v = parseline(lines[i]);
		m.m00 = v[0];
		m.m10 = v[1];
		v = parseline(lines[i+1]);
		m.m01 = v[0];
		m.m11 = v[1];
		v = parseline(lines[i+2], 2) + (double)penalty;
		tokens += Machine{m,v}.play();
	}

	return tokens;
}
