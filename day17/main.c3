module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %s", part1());
		// io::printfn("result: part 2: %d", part2());
	};
}

struct Cpu
{
	int[<3>] reg; 
	int[] prog; 
	usz ip;
	DString output;
	bool no_inc;
}

fn int Cpu.combo(&self, int combo_op)
{
	switch (combo_op)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			return combo_op;
		case 4: return self.reg.x; 
		case 5: return self.reg.y; 
		case 6: return self.reg.z; 
		default: unreachable();
	}
}

fn usz! Cpu.to_format(&self, Formatter *f) @dynamic
{
	usz! n;
	foreach (i, reg : self.reg) n += f.printf("Reg %d: %d\n", i, reg);
	for (usz i = 0; i < self.prog.len; i+=2)
	{
		n += f.printf("Opcode: %d, Operand: %d\n", self.prog[i], self.prog[i+1]);
	}
	return n;
}

fn void! adv(Cpu *c)
{
	long num = c.reg.x;
	long denom = (int)math::pow(2, c.combo(c.prog[c.ip+1]));
	long result = num / denom;
	c.reg.x = (int)result;
}

fn void! bxl(Cpu *c)
{
	c.reg.y ^= c.prog[c.ip+1];
}

fn void! bst(Cpu *c)
{
	c.reg.y = (c.combo(c.prog[c.ip+1]) % 8) & 0b111;
}

fn void! jnz(Cpu *c)
{
	if (c.reg.x == 0) return;
	c.ip = c.prog[c.ip+1];
	c.no_inc = true;
}

fn void! bxe(Cpu *c)
{
	c.prog[c.ip+1]; // read operand but ignore it
	c.reg.y ^= c.reg.z;
}

fn void! out(Cpu *c)
{
	int operand = c.combo(c.prog[c.ip+1]);
	c.output.append(operand % 8);
	c.output.append(",");
}

fn void! bdv(Cpu *c)
{
	long num = c.reg.x;
	long denom = (int)math::pow(2, c.combo(c.prog[c.ip+1]));
	long result = num / denom;
	c.reg.y = (int)result;
}

fn void! cdv(Cpu *c)
{
	long num = c.reg.x;
	long denom = (int)math::pow(2, c.combo(c.prog[c.ip+1]));
	long result = num / denom;
	c.reg.z = (int)result;
}
fn void! nop(Cpu *c)
{
	return;
}

def OpCode = fn void! (Cpu *c);
OpCode[*] instructions = {
	[0] = &adv,
	[1] = &bxl,
	[2] = &bst,
	[3] = &jnz,
	[4] = &bxe,
	[5] = &out,
	[6] = &bdv,
	[7] = &cdv,
	[8] = &nop,
	[9] = &nop,
};

fn Cpu load_cpu()
{
	$if $feature(TEST):
		String in = (String)file::load_temp("input_test")!!;
	$else
		String in = (String)file::load_temp("input")!!;
	$endif

	String[] parts = in.trim().tsplit("\n\n");

	int[<3>] reg;
	foreach (i, line : parts[0].tsplit("\n")) reg[i] = ((String)line[12..]).to_int()!!;
	int[20] prog;
	String[] opcodes = ((String)parts[1][9..]).trim().tsplit(",");
	foreach (i, opcode : opcodes) prog[i] = opcode.trim().to_int()!!;

	DString output;
	output.temp_init();

	return {.reg = reg, .prog = prog[:opcodes.len], .ip = 0, .output = output, .no_inc = false};
}

fn String part1() => solve();
// fn long part2() => solve(true);

fn String solve()
{
	Cpu c = load_cpu();
	OpCode inst;
	usz index;
	while (c.ip < c.prog.len)
	{
		index = c.prog[c.ip];
		if (index >= instructions.len) break;
		if (catch instructions[index](&c)) break;
		if (c.no_inc)
		{
			c.no_inc = false;
			continue;
		}
		c.ip += 2;
	}
	return c.output.str_view();
}
