module aoc2024::app;

import std::io;
import std::math;
import std::collections::list;

fn void! main()
{
	@pool()
	{
		io::printfn("result: part 1: %s", part1());
		io::printfn("result: part 2: %d", part2());
	};
}

struct Cpu
{
	long[<3>] reg; 
	long[] prog; 
	usz ip;
	List(<long>) output;
	bool no_inc;
}

fn void Cpu.run(&c)
{
	OpCode inst;
	usz index;

	while (c.ip < c.prog.len)
	{
		index = c.prog[c.ip];
		if (index >= instructions.len)
		{
			io::printfn("instruction index out of range: %d. Halt.", index);
			break;
		}
		if (catch instructions[index](c))
		{
			io::printfn("opcode [%d] failed. Halt.", index);
			break;
		}
		if (c.no_inc)
		{
			c.no_inc = false;
			continue;
		}
		c.ip += 2;
	}
}

fn usz Cpu.combo(&self, usz combo_op)
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

fn long dv(Cpu *c) => (long)c.reg.x >> c.combo(c.prog[c.ip+1]);

fn void! adv(Cpu *c)
{
	c.reg.x = dv(c);
}

fn void! bxl(Cpu *c)
{
	c.reg.y ^= c.prog[c.ip+1];
}

fn void! bst(Cpu *c)
{
	long modulo = (c.prog[c.ip+1]) % 8;
	if (modulo < 0) modulo += 8;
	c.reg.y = c.combo(modulo) & 0b111;
}

fn void! jnz(Cpu *c)
{
	if (c.reg.x == 0) return;
	c.ip = c.prog[c.ip+1];
	c.no_inc = true;
}

fn void! bxe(Cpu *c)
{
	c.reg.y ^= c.reg.z;
}

fn void! out(Cpu *c)
{
	long modulo = c.combo(c.prog[c.ip+1]) % 8;
	if (modulo < 0) modulo += 8;
	c.output.push(modulo);
}

fn void! bdv(Cpu *c)
{
	c.reg.y = dv(c);
}

fn void! cdv(Cpu *c)
{
	c.reg.z = dv(c);
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

	long[<3>] reg;
	foreach (i, line : parts[0].tsplit("\n")) reg[i] = ((String)line[12..]).to_int()!!;

	long[32] prog;
	String[] opcodes = ((String)parts[1][9..]).trim().tsplit(",");
	foreach (i, opcode : opcodes) prog[i] = opcode.trim().to_int()!!;

	long[] tprog = mem::temp_new_array(long, opcodes.len);
	tprog[..] = prog[:opcodes.len];

	return {.reg = reg, .prog = tprog, .ip = 0, .output = *List(<long>){}.temp_init(), .no_inc = false};
}

fn String part1() => solve();
fn long part2() => reverse();

fn String solve()
{
	Cpu c = load_cpu();
	io::printfn("CPU:\n%s", c);
	c.run();

	DString s;
	s.temp_init();
	foreach (i, o : c.output)
	{
		if (i>0) s.append(",");
		s.appendf("%d", o);
	}
	return s.str_view();
}

struct State
{
	usz remaining;
	long estimate;
}

// bfs
fn long reverse()
{
	Cpu c = load_cpu();

	List(<State>) stack;
	stack.temp_init();

	stack.push({c.prog.len - 1, 0});

	long a;
	while (stack.len())
	{
		State s = stack.pop_first()!!;

		for (usz i = 0; i < 8; i++)
		{
			a = (s.estimate << 3) + i;
			c.reg[..] = 0;
			c.reg.x = a;
			c.ip = 0;
			c.output.clear();
			c.run();
			if (c.output.to_tarray() == c.prog[s.remaining..])
			{
				if (s.remaining == 0) return a;
				stack.push({s.remaining - 1, a});
			}
		}
	}

	return -1;
}
