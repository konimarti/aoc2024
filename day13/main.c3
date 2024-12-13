module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %d", part1());
		// io::printfn("result: part 2: %d", sum2);
	};
}

struct Machine
{
	Matrix2 m;
	Vec2 price;
}

Vec2 token_cost = {3, 1};

fn bool Machine.on_price(&m, long a, long b) @inline
{
	if ((long)m.m.m00 * a + (long)m.m.m01 * b != (long)m.price[0]) return false;
	if ((long)m.m.m10 * a + (long)m.m.m11 * b != (long)m.price[1]) return false;
	return true;
}

fn long Machine.play(&m)
{
	double det = m.m.determinant();
	if (math::abs(det) < 1e-7) return 0;
	Matrix2 inv = {.m00=m.m.m11, .m01=-m.m.m01, .m10=-m.m.m10, .m11=m.m.m00};
	inv = inv.component_mul(1.0/det);
	Vec2 v = inv.apply(m.price);
	double tokens = v.dot(token_cost);
	if (math::abs(tokens - math::round(tokens)) > 1e-7) return 0;
	return (long)math::round(tokens);
}

fn long part1()
{
	$if $feature(TEST):
	String s = (String)file::load_temp("input_test")!!;
	$else
	String s = (String)file::load_temp("input")!!;
	$endif

	List(<Machine>) machines;
	machines.temp_init();

	String[] parts;

	String[] lines = s.trim().tsplit("\n");
	for (usz i = 0; i < lines.len; i += 4)
	{
		Matrix2 m;

		parts = lines[i].tsplit(": ");
		assert(parts.len == 2);
		parts = parts[1].tsplit(", ");
		assert(parts.len == 2);

		m.m00 = parts[0].trim()[1..].to_double()!!;
		m.m10 = parts[1].trim()[1..].to_double()!!;

		// io::printfn("row1 %g, %g", m.m00, m.m01);
		
		parts = lines[i+1].tsplit(": ");
		assert(parts.len == 2);
		parts = parts[1].tsplit(", ");
		assert(parts.len == 2);

		m.m01 = parts[0].trim()[1..].to_double()!!;
		m.m11 = parts[1].trim()[1..].to_double()!!;

		// io::printfn("row2 %g, %g", m.m10, m.m11);
		
		Vec2 v;
		parts = lines[i+2].tsplit(": ");
		assert(parts.len == 2);
		parts = parts[1].tsplit(", ");
		assert(parts.len == 2);

		v.x = parts[0].trim()[2..].to_double()!!;
		v.y = parts[1].trim()[2..].to_double()!!;

		// io::printfn("vec %g, %g", v.x, v.y);

		machines.push({m, v});
	}

	long tokens;
	foreach (m : machines) tokens += m.play();

	return tokens;
}
