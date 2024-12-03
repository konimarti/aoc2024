module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result part1: %d", part1());
		io::printfn("result part2: %d", part2());
	};
}

struct Parser
{
	String s;
	int pos;
	bool enabled;
}

fn bool Parser.eof(&self) => self.pos >= self.s.len;
fn char Parser.peek(&self) => self.s[self.pos];
fn bool Parser.advance(&self, char c)
{
	if (!self.eof() && self.peek() == c)
	{
		self.pos++;
		return true;
	}
	return false;
}

fn void Parser.skip_ws(&self)
{
	while (!self.eof() && self.peek() == ' ') self.pos++;
}

fn long Parser.read_int(&self)
{
	usz start = self.pos;
	while (!self.eof() && self.peek() >= '0' && self.peek() <= '9') self.pos++;
	if (self.pos > start)
	{
		return self.s[start..self.pos-1].to_long()!!;
	}
	return 0;
}

fn long Parser.parse_mul(&self)
{
	long sum = 0;
	long v1;
	long v2;

	if (!self.advance('m')) 
	{
		return 0;
	}
	self.skip_ws();
	if (!self.advance('u')) 
	{
		return 0;
	}
	self.skip_ws();
	if (!self.advance('l')) 
	{
		return 0;
	}
	self.skip_ws();
	if (!self.advance('(')) 
	{
		return 0;
	}

	self.skip_ws();
	v1 = self.read_int();

	self.skip_ws();
	if (!self.advance(',')) 
	{
		return 0;
	}

	self.skip_ws();
	v2 = self.read_int();

	self.skip_ws();
	if (self.advance(')')) 
	{
		if (self.enabled) sum += v1 * v2;
	}
	return sum;
}

fn void Parser.parse_dos(&self)
{
	if (!self.advance('d')) 
	{
		return;
	}
	self.skip_ws();
	if (!self.advance('o')) 
	{
		return;
	}
	self.skip_ws();

	// branch between do() and don't()
	switch (self.peek())
	{
		case '(':
			self.parse_do();
		case 'n':
			self.parse_dont();
		default:
		io::printfn("nothing found: %c", self.peek());
	}
}


fn void Parser.parse_do(&self)
{
	if (!self.advance('(')) 
	{
		return;
	}
	self.skip_ws();
	if (self.advance(')')) 
	{
		self.enabled = true;
	}
}

fn void Parser.parse_dont(&self)
{
	if (!self.advance('n')) 
	{
		return;
	}
	self.skip_ws();
	if (!self.advance('\'')) 
	{
		return;
	}
	self.skip_ws();
	if (!self.advance('t')) 
	{
		return;
	}
	self.skip_ws();
	if (!self.advance('(')) 
	{
		return;
	}
	if (self.advance(')')) 
	{
		self.enabled = false;
	}
}

fn long Parser.parse_part1(&self)
{
	long sum = 0;
	while (!self.eof())
	{
		switch (self.peek())
		{
			case 'm': 
				sum += self.parse_mul();
			default:
				self.pos++;
		}
	}
	return sum;
}

fn long Parser.parse_part2(&self)
{
	long sum = 0;
	while (!self.eof())
	{
		switch (self.peek())
		{
			case 'm': 
				sum += self.parse_mul();
			case 'd': 
				self.parse_dos();
			default:
				self.pos++;
		}
	}
	return sum;
}

fn long part1()
{
	// String s = (String)file::load_temp("input_test")!!;
	String s = (String)file::load_temp("input")!!;

	Parser p = { s, 0, true };

	return p.parse_part1();
}

fn long part2()
{
	// String s = (String)file::load_temp("input_test2")!!;
	String s = (String)file::load_temp("input")!!;

	Parser p = { s, 0, true };

	return p.parse_part2();
}
